function [sEpoch, sAlgo, sStat] = processgnss( sEpoch, sAlgo, sStat )
% PROCESSGNSS describes the general flow of the GNSS processing
%   The function receives a structure with the data known for the current
%   epoch (or all of them if processing offline data)
%  
%   The structure is defined by CONFIGPPPLAB
%  
%   WARNING
%   IT IS EXPECTED TO RECEIVE DATA IN MATRIX FORMAT TO EXPEDITE THE SEARCH
%   FOR SATELLITES WITH DATA. Thus, saving satellite data and ephemerides
%   must be done in a consistent way, for example, matrix Nx32.
%
%   INPUT
%   sEpoch - Structure with relevant data for data processing
%   sAlgo  - Structure with Algorithm(s) results
%   sStat  - Structure with Statistic results
%
%   OUTPUT
%   sEpoch - Structure updated with relevant data for data processing
%   sAlgo  - Structure updated with Algorithm(s) results
%   sStat  - Structure updated with Statistic results
%  
%   Pedro Silva, Instituto Superior Tecnico, December 2011
%   Last revision: January 2012

    % Retrieves data for the available satellites and applies masks
    [sEpoch, sAlgo, sStat] = masksatellites(sEpoch, sAlgo, sStat); % to improve
   
    % Check if there is enough satellites to obtain a position fix and
    % retrieve measurements for the available satellites
    if sAlgo.nSat >= 4
        sAlgo.iEpoch   = sEpoch.iEpoch;
        [sAlgo,health] = getposition( sAlgo, sEpoch.TOW, sEpoch.DOY, sEpoch.WD);
        if health
            sAlgo.count    = sAlgo.count + 1;
            [sStat,sAlgo]  = updatestatistic(sStat,sAlgo,sEpoch);
        end
        sAlgo.lastseen = sEpoch.iEpoch;
    else
        % Marks structure for caller to know nothing was done
        fprintf('Not enough satellites (%d) at epoch: %d\n',sAlgo.nSat,sEpoch.iEpoch);
%         sAlgo.lastavailableSat = [];
%         sAlgo.lastnSat         = NaN;
    end
        
end


function [sEpoch, sAlgo, sStat] = masksatellites(sEpoch, sAlgo, sStat)
%MASKSATELLITES will mask the unwanted satellites for the algorithm
%processing
%
%   The function has been largely rewritten to better accomodate ONLINE and
%   OFFLINE processing (iEpoch is always set to 1).
%
%   Available ranges are also assigned as long as there are enough
%   satellites availbe. The pseudoranges fields are filled with P data if
%   it is available, otherwise CA data will be used (if available)
%
%
%  IMPORTANT:
%  http://www.igs.org/mail/igsmail/2000/msg00084.html
%
%   DCB = [-67 -308  52  458  -195   172  -296 -240 117 -465 ...
%          -35  0    526 172  -297  -202  -266   52  70    0 ...
%          -84 -469 -147 132   242   433  -7      0 296  541 -183] ;
%     
%   Pedro Silva, Instituto Superior Tecnico, December 2011
%   Last Revision: May 2012


% WAHT A BIG MESS! CLEAN THIS UP!

    caflag   = 0; % Handle this better with file info
    l2flag   = strcmpi(sAlgo.flags.freqmode,'L1L2');
    maskGNSS = userparams('maskGNSS'); % use only GPS satellites
    maskSNR  = userparams('maskSNR');  % set minimum snr value
    
    if sEpoch.operation
        iEpoch = 1;
    else
        iEpoch   = sEpoch.iEpoch;%%% CHECK IF THIS DOES NOT RESULT IN ANY ISSUES
    end
    % Check which ephemerides are available and add cycle slips if required 
    if sAlgo.addartificialcs
        sEpoch = insertcycleslips(sEpoch,sAlgo,caflag,l2flag);
    end
      

    % Retrieves available satellites
    [sEpoch,sAlgo,sStat,sats,pr1sats,l1cpsats,pr2sats,l2cpsats,ephsats] = getavailablesatellites(sEpoch,sAlgo,sStat,maskGNSS,maskSNR,caflag,iEpoch);
    [sEpoch,sAlgo,sStat,sats] = restoredatagaps(sEpoch,sAlgo,sStat,sats,ephsats,caflag,l2flag,maskGNSS,iEpoch);  
    [sEpoch,sAlgo,sStat,sats] = restorecycleslips(sEpoch,sAlgo,sStat,sats,caflag,l2flag,iEpoch); 
    sAlgo                     = resetprediction(sEpoch,sAlgo,sats,caflag,l2flag,iEpoch,pr1sats,l1cpsats,pr2sats,l2cpsats);
    sAlgo                     = qualitycontrol(sEpoch,sAlgo,sStat,sats,maskGNSS,caflag,l2flag,iEpoch);
 
end



function smrange = smooth(PR,CP,CPp,PRs,Ns)
%SMOOTH performs data smoothing using carrier phase data

    smrange = PR./Ns + (PRs + CP - CPp).*(Ns-1)./Ns;
   
end


function n = saturate(n,lim)
%SATURATE assures that N is always less or equal to LIM

    if n>lim
        n = lim;
    end

end


function sEpoch = insertcycleslips(sEpoch,sAlgo,caflag,l2flag)
%INSERTCYCLESLIPS handles the addition of cycle slips

    if sEpoch.iEpoch>=sAlgo.artificialepoch
        A = sAlgo.artificialcsl1;
        B = sAlgo.artificialcsl2;
        psat = sAlgo.cssatellites; %sats;
        if caflag
            sEpoch.ranges.CPCA(sEpoch.iEpoch,psat) = sEpoch.ranges.CPCA(sEpoch.iEpoch,psat)+A;
        else
            sEpoch.ranges.CPL1(sEpoch.iEpoch,psat) = sEpoch.ranges.CPL1(sEpoch.iEpoch,psat)+A;
        end
        
        if l2flag
            sEpoch.ranges.CPL2(sEpoch.iEpoch,psat) = sEpoch.ranges.CPL2(sEpoch.iEpoch,psat)+B;
        end
    end 
end


function [sEpoch,sAlgo,sStat,sats,pr1sats,l1cpsats,pr2sats,l2cpsats,ephsats] = getavailablesatellites(sEpoch,sAlgo,sStat,maskGNSS,maskSNR,caflag,iEpoch)

    pr2sats=[];l2cpsats=[];
    ephsats = sEpoch.eph.data(1,1:maskGNSS) ~= 0; 
    % L1 DATA
    if caflag
        % Retrieves satellites with information
        pr1sats  = sEpoch.ranges.PRCA(iEpoch,1:maskGNSS) ~= 0 & ~isnan(sEpoch.ranges.PRCA(iEpoch,1:maskGNSS));
        l1cpsats = sEpoch.ranges.CPCA(iEpoch,1:maskGNSS) ~= 0 & ~isnan(sEpoch.ranges.CPCA(iEpoch,1:maskGNSS));     
        sEpoch.visibleSatsPCA(1:maskGNSS,iEpoch) = pr1sats; % it is okay do not change to sats
        sEpoch.visibleSatsCCA(1:maskGNSS,iEpoch) = l1cpsats;
        sEpoch.ranges.CPCA(iEpoch,l1cpsats)      = sEpoch.ranges.CPCA(iEpoch,l1cpsats) + sEpoch.slipl1(l1cpsats)';
        sAlgo.ranges.PRL1                        = sEpoch.ranges.PRCA(iEpoch,pr1sats)';
        sAlgo.ranges.CPL1                        = sEpoch.ranges.CPCA(iEpoch,l1cpsats)';
        sAlgo.SNRCA(pr1sats,iEpoch)              = sEpoch.ranges.SNRCA(iEpoch,pr1sats)';
        
        %Check SNR values
        if any(isnan(sAlgo.SNRCA(pr1sats,iEpoch)))
            goodSNR                        = 1;
            sAlgo.SNRCA(pr1sats,iEpoch)    = 1;
        else
            goodSNR                        = sEpoch.ranges.SNRCA(iEpoch,1:maskGNSS) > maskSNR;
        end
        
        %Obtains valid satellites
        sats                               = ephsats & pr1sats & goodSNR & l1cpsats;  

    else
        % Retrieves satellites with information
        pr1sats  = sEpoch.ranges.PRL1(iEpoch,1:maskGNSS) ~= 0 & ~isnan(sEpoch.ranges.PRL1(iEpoch,1:maskGNSS));
        l1cpsats = sEpoch.ranges.CPL1(iEpoch,1:maskGNSS) ~= 0 & ~isnan(sEpoch.ranges.CPL1(iEpoch,1:maskGNSS));
        sEpoch.visibleSatsPL1(1:maskGNSS,iEpoch) = pr1sats;
        sEpoch.visibleSatsCL1(1:maskGNSS,iEpoch) = l1cpsats;
        sEpoch.ranges.CPL1(iEpoch,l1cpsats)      = sEpoch.ranges.CPL1(iEpoch,l1cpsats) + sEpoch.slipl1(l1cpsats)';
        sAlgo.ranges.PRL1                        = sEpoch.ranges.PRL1(iEpoch,pr1sats)';
        sAlgo.ranges.CPL1                        = sEpoch.ranges.CPL1(iEpoch,l1cpsats)';
        sAlgo.SNRL1(pr1sats,iEpoch)              = sEpoch.ranges.SNRL1(iEpoch,pr1sats)';
        
        %Check SNR values
        if any(isnan(sAlgo.SNRL1(pr1sats,iEpoch))) || all(sAlgo.SNRL1(pr1sats,iEpoch)==0)
            goodSNR                        = 1;
            sAlgo.SNRL1(pr1sats,iEpoch) = 1;
        else
            goodSNR                        = sEpoch.ranges.SNRL1(iEpoch,1:maskGNSS) > maskSNR;
        end
        
        %Obtains valid satellites
        sats                               = ephsats & pr1sats & goodSNR & l1cpsats;
    end
    
    % Statistic information regarding L1 data
    sStat.OBSPRL1(pr1sats,iEpoch)  = sEpoch.ranges.PRL1(iEpoch,pr1sats)';
    sStat.OBSCPL1(l1cpsats,iEpoch) = sEpoch.ranges.CPL1(iEpoch,l1cpsats)';
                                    
    % L2 DATA
    if strcmpi(sAlgo.flags.freqmode,'L1L2') || strcmpi(sAlgo.flags.freqmode,'L2')
        pr2sats  = sEpoch.ranges.PRL2(iEpoch,1:maskGNSS) ~= 0;
        l2cpsats = sEpoch.ranges.CPL2(iEpoch,1:maskGNSS) ~= 0;
        sEpoch.visibleSatsPL2(1:maskGNSS,iEpoch)   = pr2sats;
        sEpoch.visibleSatsCL2(1:maskGNSS,iEpoch)   = l2cpsats;
        
        sEpoch.ranges.CPL2(iEpoch,l2cpsats) = sEpoch.ranges.CPL2(iEpoch,l2cpsats) + sEpoch.slipl2(l2cpsats)';

        sAlgo.ranges.PRL2                     = sEpoch.ranges.PRL2(iEpoch,pr2sats)';
        sAlgo.ranges.CPL2                     = sEpoch.ranges.CPL2(iEpoch,l2cpsats)';
        
        sAlgo.SNRL2(pr2sats,iEpoch)    = sEpoch.ranges.SNRL2(iEpoch,pr2sats)';
        if all(isnan(sAlgo.SNRL2(pr2sats,iEpoch))) || all(sAlgo.SNRL2(pr2sats,iEpoch)==0)
            goodSNR                           = 1;
        else
            goodSNR                           = sEpoch.ranges.SNRL2(iEpoch,1:maskGNSS) > maskSNR;
        end
        sats                                  = sats & pr2sats & goodSNR & l2cpsats;
        
        % Stat L2
        sStat.OBSPRL2(pr2sats,iEpoch) = sEpoch.ranges.PRL2(iEpoch,pr2sats)';
        sStat.OBSCPL2(l2cpsats,iEpoch) = sEpoch.ranges.CPL2(iEpoch,l2cpsats)';
    end
    
    % updates available sats
    sats                  = sats';
    sAlgo.availableSat    = sEpoch.getids(sats);
    
end


function [sEpoch,sAlgo,sStat,sats] = restoredatagaps(sEpoch,sAlgo,sStat,sats,ephsats,caflag,l2flag,maskGNSS,iEpoch)

   if sAlgo.flags.datagaps || sAlgo.flags.usecycleslip
        eph     = buildsEph(sEpoch.eph.data(:,ephsats)); 
        cosvec  = directorcos(sAlgo.userxyz,satpos(eph,sAlgo.userxyz,sEpoch.TOW),'enu');
        if  strcmpi(sAlgo.satvelocity,'ephemerides')
            [ ~, ~, satv, ~ ] = satpos(eph,sAlgo.userxyz,sEpoch.TOW);
        elseif strcmpi(satvelocity,'igs')
            temp=sAlgo.flags.usepreciseorbits;
            sAlgo.flags.usepreciseorbits=1;
            satv = (precisepos(iEpoch,sAlgo.userxyz, eph, sEpoch.WD, sEpoch.TOW+1, sAlgo.flags, [], []) - precisepos(iEpoch,sAlgo.userxyz, eph, sEpoch.WD, sEpoch.TOW-1, sAlgo.flags, [], []))./2;
            sAlgo.flags.usepreciseorbits=temp;
        else
            satv = (satcoord(eph,sEpoch.TOW+1,1) - satcoord(eph,sEpoch.TOW-1,1))./2;
        end

        % Retrieve receiver dynamics information
        rcvv          = checknan(norm(sEpoch.IMU.velocity));
        dynamicoffset = checknan(sEpoch.IMU.position);

        % Corrects carrier phase - 0 might appear as every known satellite is
        % being used (with ephemerides information) regardless of having
        % information from the receiver or not
        if caflag
            imuCPL1 = sEpoch.ranges.CPCA(iEpoch,ephsats)'-dynamicoffset; %minus?
        else
            imuCPL1 = sEpoch.ranges.CPL1(iEpoch,ephsats)'-dynamicoffset; %minus?
        end

        sAlgo.imuCPL1(ephsats,:) = insertsl(imuCPL1,sAlgo.imuCPL1(ephsats,:),1);

        satv = diag(satv*cosvec');    
        sAlgo.dDopL1(ephsats,iEpoch) = -(satv-rcvv);
        
        %%% Use receiver values
        %sAlgo.dDopL1(ephsats,iEpoch) = sEpoch.ranges.DOL1(iEpoch,ephsats)'*gpsparams('lbdf1');
        
        if l2flag
            imuCPL2 = sEpoch.ranges.CPL2(iEpoch,ephsats)'-dynamicoffset; %minus?
            sAlgo.imuCPL2(ephsats,:) = insertsl(imuCPL2,sAlgo.imuCPL2(ephsats,:),1);
            sAlgo.dDopL2(ephsats,iEpoch) = -(satv-rcvv);%./gpsparams('lbdf2');
        end    
    
        valid = sStat.lifetime > 0;
        valid = valid' & ephsats;
        if any(valid)
            topredict = sEpoch.getids(valid); % only has information for SATS
            pPRL1     = sAlgo.pPRL1(topredict,end) - inttrap(sAlgo.dDopL1(topredict,iEpoch-1:iEpoch));
            pCPL1     = sAlgo.pCPL1(topredict,end) - inttrap(sAlgo.dDopL1(topredict,iEpoch-1:iEpoch))./gpsparams('lbdf1');
            sAlgo.pPRL1(topredict,:) = insertsl(pPRL1,sAlgo.pPRL1(topredict,:),1);
            sAlgo.pCPL1(topredict,:) = insertsl(pCPL1,sAlgo.pCPL1(topredict,:),1);

            if l2flag
                pPRL2 = sAlgo.pPRL2(topredict,end) - inttrap(sAlgo.dDopL1(topredict,iEpoch-1:iEpoch));
                pCPL2 = sAlgo.pCPL2(topredict,end) - inttrap(sAlgo.dDopL2(topredict,iEpoch-1:iEpoch))./gpsparams('lbdf2');
                sAlgo.pPRL2(topredict,:) = insertsl(pPRL2,sAlgo.pPRL2(topredict,:),1);
                sAlgo.pCPL2(topredict,:) = insertsl(pCPL2,sAlgo.pCPL2(topredict,:),1);  
            end
        end

        if any(~valid)
            initsatdop = sEpoch.getids(~valid);
            if caflag
                pPRL1  = sEpoch.ranges.PRCA(iEpoch, initsatdop)';
            else
                pPRL1  = sEpoch.ranges.PRL1(iEpoch, initsatdop)';
            end
            pCPL1      = sAlgo.imuCPL1(initsatdop,end);
            sAlgo.pPRL1(initsatdop,:) = insertsl(pPRL1,sAlgo.pPRL1(initsatdop,:),1);
            sAlgo.pCPL1(initsatdop,:) = insertsl(pCPL1,sAlgo.pCPL1(initsatdop,:),1);

            if l2flag
                pPRL2 = sEpoch.ranges.PRL2(iEpoch, initsatdop)';
                pCPL2 = sAlgo.imuCPL2(initsatdop,end);
                sAlgo.pPRL2(initsatdop,:) = insertsl(pPRL2,sAlgo.pPRL2(initsatdop,:),1);
                sAlgo.pCPL2(initsatdop,:) = insertsl(pCPL2,sAlgo.pCPL2(initsatdop,:),1);        
            end
        end
        
    end
    % Update life table and retrieve sat ids (might still change)
    sStat.lifetime(sats)  = sStat.lifetime(sats) + 1;
    

    % DATA GAPS
    %TODO reset lifetime to zero otherwise error will increase indefinetly
    if sAlgo.flags.datagaps && any(sAlgo.lastavailableSat)
        % keeps tabs on the satellites to avoid error propagation due to
        % the prediction step
        sAlgo.visibleSats       = sAlgo.visibleSats - 1;
        sAlgo.visibleSats(sats) = userparams('visiblewatchdog');
        
        
        sAlgo.tempcountregen(sats) = 1;
        
        activesats           = sAlgo.visibleSats(1:maskGNSS) > -1;

        % constellation changed?
        constchanges = sats ~= sAlgo.lastavailableSat;
        constchanges = constchanges & ~sats & activesats; % only new sats
        
        if any(constchanges)
            % add them to the new sats
            sats = sats | constchanges;
            sAlgo.availableSat    = sEpoch.getids(sats); 
            
            % sanity checking I believe :)
%            aux  = sAlgo.pPRL1(:,end-1)-sEpoch.ranges.PRL1(iEpoch-1, :)';
%            temp = abs(aux) < 5;
%            sats = sats & temp;
                      
            % fills prediction values into the input structure
            if caflag
                sEpoch.ranges.PRCA(iEpoch,constchanges) = sAlgo.pPRL1(constchanges,end);
                sEpoch.ranges.CPCA(iEpoch,constchanges) = sAlgo.pCPL1(constchanges,end);
            else
                %%REMOVE ME
                sEpoch.ranges.PRL1(iEpoch,constchanges) = sAlgo.pPRL1(constchanges,end) + 218.763454401*sAlgo.tempcountregen(constchanges);
                sEpoch.ranges.CPL1(iEpoch,constchanges) = sAlgo.pCPL1(constchanges,end) + 218.763454401*sAlgo.tempcountregen(constchanges);
            end
            sStat.OBSPRL1(constchanges,iEpoch)        = sAlgo.pPRL1(constchanges,end);
            sStat.OBSCPL1(constchanges,iEpoch)        = sAlgo.pCPL1(constchanges,end);
            sAlgo.imuCPL1(constchanges,end)           = sAlgo.pCPL1(constchanges,end);
            sEpoch.ranges.SNRL1(iEpoch,constchanges)  = sEpoch.ranges.SNRL1(iEpoch,constchanges).*2; 
            
            if l2flag
                sEpoch.ranges.PRL2(iEpoch,constchanges)   = sAlgo.pPRL2(constchanges,end);
                sEpoch.ranges.CPL2(iEpoch,constchanges)   = sAlgo.pCPL2(constchanges,end);
                sStat.OBSPRL2(constchanges,iEpoch)        = sAlgo.pPRL2(constchanges,end);
                sStat.OBSCPL2(constchanges,iEpoch)        = sAlgo.pCPL2(constchanges,end);
                sAlgo.imuCPL2(constchanges,end)           = sAlgo.pCPL2(constchanges,end);
                sEpoch.ranges.SNRL2(iEpoch,constchanges)  = sEpoch.ranges.SNRL2(iEpoch,constchanges).*2; 
            end
            
            
            sAlgo.tempcountregen(sats) = sAlgo.tempcountregen(sats)+1;
            
            
        end
    end

end


function [sEpoch,sAlgo,sStat,sats] = restorecycleslips(sEpoch,sAlgo,sStat,sats,caflag,l2flag,iEpoch)

    cssats = sats;
    % CYCLE SLIP
    if sAlgo.flags.usecycleslip && l2flag
        
        % Retrieve possibly new values
        sAlgo.availableSat = sEpoch.getids(cssats); 
        if caflag
            sAlgo.ranges.CPL1 = sEpoch.ranges.CPCA(iEpoch,cssats)';
            sAlgo.ranges.PRL1 = sEpoch.ranges.PRCA(iEpoch,cssats)';
        else
            sAlgo.ranges.CPL1 = sEpoch.ranges.CPL1(iEpoch,cssats)';
            sAlgo.ranges.PRL1 = sEpoch.ranges.PRL1(iEpoch,cssats)';
        end

        sAlgo.ranges.CPL2     = sEpoch.ranges.CPL2(iEpoch,cssats)';
        sAlgo.ranges.PRL2     = sEpoch.ranges.PRL2(iEpoch,cssats)';
        
        % DETECT Cycle slip
        [sAlgo, sStat, tecflag] = tecdetector(iEpoch, sAlgo, sStat); % TEC method Liu
        [sAlgo, sStat, mwflag]  = mwdetector(sAlgo, sStat);  % melbourne-wubbena        
        [sAlgo, sStat, lgflag]  = lgdetector(iEpoch, sAlgo, sStat);  % geometry-free combination
        [sAlgo, sStat, dopflag, dopsats, dopcs] = dopdetector(sEpoch, sAlgo, sStat, l2flag);

        % Correct cycle slip
        controlcs = tecflag + mwflag + dopflag + lgflag; 
        
%         if tecflag
%             sEpoch.counters.tec = sEpoch.counters.tec + 1;
%         end
%         
%         if mwflag
%             sEpoch.counters.mw  = sEpoch.counters.mw  + 1;
%         end
%         
%         if lgflag
%             sEpoch.counters.lg  = sEpoch.counters.lg  + 1;
%         end
%         
%         if dopflag
%             sEpoch.counters.dop = sEpoch.counters.dop + 1;
%         end
        
        if controlcs > 1 && dopflag
            fprintf('High certainity of a cycle slip, %d\n',iEpoch);
            fprintf('tec\t%d\n',tecflag);
            fprintf('mw \t%d\n',mwflag);
            fprintf('lg \t%d\n',lgflag);
            fprintf('dop\t%d\n',dopflag);
            fprintf('\n\n');
            if ~isempty(dopcs{1})
%                 sEpoch.counters.correctedL1 = sEpoch.counters.correctedL1+1;
                fprintf('L1 sat'); fprintf(' %d ',dopsats{1}); fprintf('\n');
                fprintf('\taccum');  fprintf(' %d ',sEpoch.slipl1(dopsats{1})); fprintf('\n');
                fprintf('\tjump');   fprintf(' %d ',dopcs{1});fprintf('\n');
                
                if caflag
                    sEpoch.ranges.CPCA(iEpoch,dopsats{1})   = sEpoch.ranges.CPCA(iEpoch,dopsats{1}) + dopcs{1}';
                    sStat.OBSCPL1(dopsats{1},iEpoch) = sEpoch.ranges.CPCA(iEpoch,dopsats{1});%+ sEpoch.slipl1(dopsats{1})';
                else
                    sEpoch.ranges.CPL1(iEpoch,dopsats{1})   = sEpoch.ranges.CPL1(iEpoch,dopsats{1}) + dopcs{1}';
                    sStat.OBSCPL1(dopsats{1},iEpoch) = sEpoch.ranges.CPL1(iEpoch,dopsats{1});% + sEpoch.slipl1(dopsats{1})';
                end
                sAlgo.imuCPL1(dopsats{1},end)           = sAlgo.imuCPL1(dopsats{1},end) +sEpoch.slipl1(dopsats{1});
                sStat.teccpl1(dopsats{1},end)           = sEpoch.ranges.CPL1(iEpoch,dopsats{1});
                sEpoch.slipl1(dopsats{1}) = sEpoch.slipl1(dopsats{1}) + dopcs{1};
            end
            
            if ~isempty(dopcs{2})
                sEpoch.counters.correctedL2 = sEpoch.counters.correctedL2 +1;
                fprintf('L2 sat'); fprintf(' %d ',dopsats{2}); fprintf('\n');
                fprintf('\taccum');  fprintf(' %d ',sEpoch.slipl2(dopsats{2})); fprintf('\n');
                fprintf('\tjump');   fprintf(' %d ',dopcs{2});fprintf('\n');
                
                sEpoch.ranges.CPL2(iEpoch,dopsats{2})   = sEpoch.ranges.CPL2(iEpoch,dopsats{2})+dopcs{2}';
                sStat.OBSCPL2(dopsats{2},iEpoch) = sEpoch.ranges.CPL2(iEpoch,dopsats{2});%+sEpoch.slipl2(dopsats{2})';
                sAlgo.imuCPL2(dopsats{2},end)           = sAlgo.imuCPL2(dopsats{2},end) + sEpoch.slipl2(dopsats{2});
                sStat.teccpl2(dopsats{2},end)           = sEpoch.ranges.CPL2(iEpoch,dopsats{2});
                sEpoch.slipl2(dopsats{2})               = sEpoch.slipl2(dopsats{2}) + dopcs{2};
            end
        end
    elseif sAlgo.flags.usecycleslip
        
        if caflag
            sAlgo.ranges.CPL1 = sEpoch.ranges.CPCA(iEpoch,cssats)';
            sAlgo.ranges.PRL1 = sEpoch.ranges.PRCA(iEpoch,cssats)';
        else
            sAlgo.ranges.CPL1 = sEpoch.ranges.CPL1(iEpoch,cssats)';
            sAlgo.ranges.PRL1 = sEpoch.ranges.PRL1(iEpoch,cssats)';
        end
        
        % DETECT Cycle slip
        [sAlgo, sStat, dopflag, dopsats, dopcs] = dopdetector(sEpoch, sAlgo, sStat, l2flag);
        
        % Correct cycle slip
        if dopflag
            disp('High certainity of a cycle slip');
            
            % Sats to be corrected
            if l2flag 
                cssats =  dopsats{2};
            else
                cssats = dopsats{1};
            end
            if dopflag
                if ~isempty(dopcs{1})
                   sEpoch.slipl1(cssats) = sEpoch.slipl1(cssats) + dopcs{1};
                   
                   if caflag
                        sEpoch.ranges.CPCA(iEpoch,cssats) = sEpoch.ranges.CPCA(iEpoch,cssats) + sEpoch.slipl1(cssats)';
                   else
                        sEpoch.ranges.CPL1(iEpoch,cssats) = sEpoch.ranges.CPL1(iEpoch,cssats) + sEpoch.slipl1(cssats)';
                   end
                   
                end
                if ~isempty(dopcs{2})
                   sEpoch.slipl2(cssats) = sEpoch.slipl2(cssats) + dopcs{2};
                   sEpoch.ranges.CPL2(iEpoch,cssats) = sEpoch.ranges.CPL2(iEpoch,cssats)+sEpoch.slipl2(cssats)';
                end                   
            else
                disp('Not reliable');    
            end
        end

    end
    
end


function sAlgo = resetprediction(sEpoch,sAlgo,sats,caflag,l2flag,iEpoch,pr1sats,l1cpsats,pr2sats,l2cpsats)


    if sAlgo.flags.datagaps || sAlgo.flags.usecycleslip
        %DO SAVE IF ZERO!
        %%%% RESET DOPPLER PREDICTION    
        % Do not reset those which just experienced a cycle slip
        prresetsats = sats & pr1sats';
        cpresetsats = sats & l1cpsats';

        if caflag
            pPRL1  = sEpoch.ranges.PRCA(iEpoch, prresetsats)';
        else
            pPRL1  = sEpoch.ranges.PRL1(iEpoch, prresetsats)';
        end
        pCPL1      = sAlgo.imuCPL1(cpresetsats,end);
        sAlgo.pPRL1(prresetsats,:) = insertsl(pPRL1,sAlgo.pPRL1(prresetsats,:),1);
        sAlgo.pCPL1(cpresetsats,:) = insertsl(pCPL1,sAlgo.pCPL1(cpresetsats,:),1);

        if l2flag
            prresetsats = sats & pr2sats';
            cpresetsats = sats & l2cpsats';
            pPRL2 = sEpoch.ranges.PRL2(iEpoch, prresetsats)';
            pCPL2 = sAlgo.imuCPL2(cpresetsats,end);
            sAlgo.pPRL2(prresetsats,:) = insertsl(pPRL2,sAlgo.pPRL2(prresetsats,:),1);
            sAlgo.pCPL2(cpresetsats,:) = insertsl(pCPL2,sAlgo.pCPL2(cpresetsats,:),1);    
        end        
    end

end


function sAlgo = qualitycontrol(sEpoch,sAlgo,sStat,sats,maskGNSS,caflag,l2flag,iEpoch)



%     fprintf('Sats before elevation filter: ');
%     fprintf(' %d',sEpoch.getids(sats));
%     fprintf('\n');
   % ELEVATION MASK & URA MASK & RESIDUAL MASK
    satwithelv = ~isnan(sAlgo.satelv) & sats;
    if any(satwithelv)
        goodelv = sAlgo.satelv(1:maskGNSS) >= userparams('MASKELV'); % in rad
        sats    = sats | (satwithelv & goodelv);
    end
    satquality  = sEpoch.eph.data(ephidx('ura'),1:maskGNSS)' < userparams('MASKURA');
    
%     if iEpoch > 1 && isstruct(sAlgo.eph) && sAlgo.count > 50
%        res = abs(sStat.residuals{1}(:,iEpoch-1));
%        res(isnan(res))=0;
%        resquality =  res < userparams('reslimit');
%        sStat.residuals{1}(~resquality,iEpoch)=inf;
%     else
%        resquality = satquality;
%     end
%     satquality = satquality & resquality;
%     fprintf('Sats before URA filter: ');
%     fprintf(' %d',sEpoch.getids(sats));
%     fprintf('\n');
    sats    = sats & satquality;
%     fprintf('Sats being used: ');
%     fprintf(' %d',sEpoch.getids(sats));
%     fprintf('\n');
    
    % RETRIEVE SAT ID
    sAlgo.availableSat     = sEpoch.getids(sats);
    sAlgo.lastavailableSat = sats;
    sAlgo.lastnSat         = sAlgo.nSat;
    sAlgo.nSat             = sum(sats);
    
%     disp(sum(sats))
    % SMOOTH
    if sAlgo.flags.smooth
        if l2flag || strcmpi(sAlgo.flags.freqmode,'L2')
            % Create Iono Free carrier phase
            CPL1(:,1) = sEpoch.ranges.CPL1(iEpoch,sats).*gpsparams('lbdf1');
            CPL2(:,1) = sEpoch.ranges.CPL2(iEpoch,sats).*gpsparams('lbdf2');
            CP        = (CPL2 - gpsparams('gama').*CPL1)./(1-gpsparams('gama'));
            if iEpoch > 1
                CPpL1(:,1) = sStat.OBSCPL1(sats,iEpoch-1).*gpsparams('lbdf1');
                CPpL2(:,1) = sStat.OBSCPL2(sats,iEpoch-1).*gpsparams('lbdf2');
                CPp        = (CPpL2 - gpsparams('gama').*CPpL1)./(1-gpsparams('gama'));
                aux= CPp(:,1) == 0 & sAlgo.scountL1(sats)>1;
                if any(aux)
                    sAlgo.scountL1(sAlgo.availableSat(aux))=1;
                    sAlgo.scountL2(sAlgo.availableSat(aux))=1;
                end
            else
                CPp(:,1) = CP.*0;
            end

            % Smooth L1
            Ns(:,1)  = sAlgo.scountL1(sats);
            PRs(:,1) = sAlgo.smoothPR1(sats);
            PR(:,1)  = sEpoch.ranges.PRL1(iEpoch,sats);
            PRs      = smooth(PR,CP,CPp,PRs,Ns);
            sAlgo.scountL1(sats)  = saturate(Ns+1,userparams('smooth'));
            sAlgo.smoothPR1(sats) = PRs;

            % Smooth L2
            Ns(:,1)  = sAlgo.scountL2(sats);
            PRs(:,1) = sAlgo.smoothPR2(sats);
            PR(:,1)  = sEpoch.ranges.PRL2(iEpoch,sats);
            PRs      = smooth(PR,CP,CPp,PRs,Ns);
            sAlgo.scountL2(sats)  = saturate(Ns+1,userparams('smooth'));
            sAlgo.smoothPR2(sats) = PRs;

        else
            % Smooth L1
            Ns(:,1)  = sAlgo.scountL1(sats);
            PRs(:,1) = sAlgo.smoothPR1(sats);
            PR(:,1)  = sEpoch.ranges.PRL1(iEpoch,sats);
            CP(:,1)  = sEpoch.ranges.CPL1(iEpoch,sats).*gpsparams('lbdf1');
            if iEpoch > 1
                CPp(:,1) = sStat.OBSCPL1(sats,iEpoch-1).*gpsparams('lbdf1');
                aux= CPp(:,1) == 0 & Ns(:,1)>1;
                if any(aux)
                    Ns(aux) = 1;
                    sAlgo.scountL1(sAlgo.availableSat(aux))=1;
                end
            else
                CPp(:,1) = PR.*0;
            end
            PRs = smooth(PR,CP,CPp,PRs,Ns);
            sAlgo.scountL1(sats)  = saturate(Ns+1,userparams('smooth'));
            sAlgo.smoothPR1(sats) = PRs;    
        end
    end
    
    % ASSIGN RANGES to the algorithm structure
    % PRL1/2 and CPL1/L2 are the only fields set
    if sAlgo.nSat >= 4
        sAlgo.ranges.PRL1 = zeros(sAlgo.nSat,1);
        sAlgo.ranges.CPL1 = zeros(sAlgo.nSat,1);
        sAlgo.ranges.PRL2 = zeros(sAlgo.nSat,1);
        sAlgo.ranges.CPL2 = zeros(sAlgo.nSat,1);
        sAlgo.ranges.SNR  = zeros(sAlgo.nSat,1);
        mes        = sEpoch.ranges;
        if ~caflag
            if sAlgo.flags.smooth
                sAlgo.ranges.PRL1 = sAlgo.smoothPR1(sats); % if no cycle slips
            else
                sAlgo.ranges.PRL1 = mes.PRL1(iEpoch,sats)';   
            end
            sAlgo.ranges.CPL1 = mes.CPL1(iEpoch,sats)';
            sAlgo.ranges.SNR  = mes.SNRL1(iEpoch,sats)';
        else
            if sAlgo.flags.smooth
                sAlgo.ranges.PRL1 = sAlgo.smoothPR1(sats); % if no cycle slips
            else
                sAlgo.ranges.PRL1 = mes.PRCA(iEpoch,sats)';
            end
            sAlgo.ranges.CPL1 = mes.CPCA(iEpoch,sats)'; 
            sAlgo.ranges.SNR  = mes.SNRCA(iEpoch,sats)';
        end
        try
        assert(all(sAlgo.ranges.PRL1 ~= 0) && all(~isnan(sAlgo.ranges.PRL1)));
        assert(all(sAlgo.ranges.CPL1 ~= 0) && all(~isnan(sAlgo.ranges.CPL1)));
        catch
            sAlgo.nSat = -1;
        end
        if l2flag || strcmpi(sAlgo.flags.freqmode,'L2')
            if sAlgo.flags.smooth
                sAlgo.ranges.PRL2 = sAlgo.smoothPR2(sats); % if no cycle slips
            else
                sAlgo.ranges.PRL2 = mes.PRL2(iEpoch,sats)';
            end
            sAlgo.ranges.CPL2 = mes.CPL2(iEpoch,sats)';
            sAlgo.ranges.SNR  = (3.5./(sAlgo.ranges.SNR)+ 2*4.5./(mes.SNRL2(iEpoch,sats)'));
            try
            assert(all(sAlgo.ranges.PRL2 ~= 0) && all(~isnan(sAlgo.ranges.PRL2)));
            assert(all(sAlgo.ranges.CPL2 ~= 0) && all(~isnan(sAlgo.ranges.CPL2)));
            catch
                sAlgo.nSat = -1;
            end
        else
            sAlgo.ranges.SNR  = sAlgo.ranges.SNR;
        end

        % Save klobuchars if they are available
        if isstruct(sEpoch.iono)
            sAlgo.iono = sEpoch.iono;
        end

        % Converts ephemerides matrix to struct - decide with TOW
        sAlgo.eph     = buildsEph(sEpoch.eph.data(:,sats)); 
        sAlgo.eph.tow = sEpoch.TOW;
        assert(all(sAlgo.eph.satid ~= 0))
    end

end


function [sAlgo,health] = getposition( sAlgo, TOW, DOY, WD )
%GETPOSITION uses a GPS position algorithm to process the given data
%   For the given data RANGES and EPH the algorithm specified by ALGTYPE
%   will be used to evaluate the data at the current TOW
%
%   Pedro Silva, Instituto Superior Tecnico, Dezembro 2011

    % For future development
    % Compute corrected ranges
    distance = sAlgo.distance;
    if isnan(distance)
        distance = 5;
    end
    sAlgo.ignore = 0; 
    previous = sAlgo;
    % Combination
    
    % Process data - Receiver independent 
    algtype = sAlgo.algtype;
    if strcmpi(algtype,'SPP')
        sAlgo = sppalgo( sAlgo, TOW, DOY, WD );
    
    elseif strcmpi(algtype,'SPPDF')
        sAlgo = sppalgodf( sAlgo, TOW, DOY, WD );            

    elseif strcmpi(algtype,'sppkalman')
        sAlgo = sppkalman( sAlgo, TOW, DOY, WD);
        
    elseif strcmpi(algtype,'PPPKalman')
        sAlgo = pppkalman( sAlgo, TOW, DOY, WD );        

    elseif strcmpi(algtype,'PPPkouba')
        sAlgo = pppkouba( sAlgo, TOW, DOY, WD );
        
    elseif strcmpi(algtype,'PPPgao')
        sAlgo = pppgao( sAlgo, TOW, DOY, WD );                

    elseif strcmpi(algtype,'recursivels')
        sAlgo = ppprecursivels( sAlgo, TOW, DOY, WD );        
        
%NEEDS REVIEW        
    elseif strcmpi(algtype,'itKalman')
        sAlgo = pppitkalman( sAlgo, TOW, DOY, WD );   

    %    elseif strcmpi(algtype,'')   
    end
    
    % UPDATES LAST SEEN EPOCH
    newdistance  = norm(sAlgo.refpoint-sAlgo.userxyz);
    
    % STATISTICAL TEST
    if abs(newdistance - distance) > userparams(sAlgo.type) % +/ 200km/h
%     if newdistance > userparams(sAlgo.type) % +/ 200km/h        
        health = 0;
        disp(abs(newdistance - distance))
        disp(['not healthy ',sprintf('%d (epoch:%d)',distance - sAlgo.distance,sAlgo.iEpoch)])
        sAlgo = previous;
%         sAlgo = sppalgodf( sAlgo, TOW, DOY, WD);
        sAlgo.ignore = 1;
        sAlgo.epignored(sAlgo.iEpoch) = 1;
    else
        sAlgo.distance = newdistance;
        health = 1;
    end
    
    if sAlgo.ignore
        sAlgo.count = sAlgo.count +1;
        health = 0;
    end
    
    % Keep information on last used satellites
%     sAlgo.lastavailableSat = sAlgo.availableSat;
%     sAlgo.lastnSat         = sAlgo.nSat;
    
end

