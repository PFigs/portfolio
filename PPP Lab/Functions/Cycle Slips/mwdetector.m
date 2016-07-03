function [sAlgo, sStat, flag, slipsats, cs] = mwdetector( sAlgo, sStat)
%MWDETECTOR detects and corrects (if wanted) cycle slips in the phase
%mesurements
%   
%   This function uses the Melbourne-Wubbena combination to detect cycle
%   slips in real time
%
%   REFERENCES
%   Fang, R., SHI, C., LOU, Y., Real-time Cycle-slip detection of GPS 
%   undifferenced Carrier-phase, International conference on Earth
%   Observation Data Processing and Analysis, 2008
%
%   Pedro Silva, Instituto Superior Tecnico, April 2012
%   Last Revision: July 2012

% CHANGE to moving std

    % Initializations
    f1    = gpsparams('f1');
    f2    = gpsparams('f2');
    lbdfw = gpsparams('lbdfw');
    lbdf1 = gpsparams('lbdf1');
    lbdf2 = gpsparams('lbdf2');
    CPL1  = sAlgo.ranges.CPL1;
    CPL2  = sAlgo.ranges.CPL2;   
    PRL1  = sAlgo.ranges.PRL1;
    PRL2  = sAlgo.ranges.PRL2;
    TH    = userparams('TH');
    sats  = sAlgo.availableSat;
    
    cs       = 0;
    flag     = 0;
    slipsats = [];
  
    assert(all(CPL1 ~= 0 ))
    assert(all(CPL2 ~= 0 ))
    assert(all(PRL1 ~= 0 ))
    assert(all(PRL2 ~= 0 ))
    
    % ATTENTION TO POSSIBLE ZEROS!
    Lw     = (f1.*lbdf1.*CPL1 - f2.*lbdf2.*CPL2)./(f1-f2);
    Pw     = (f1.*PRL1 + f2.*PRL2)./(f1+f2);
    mwcomb = 1/lbdfw.*( Lw - Pw );
    

    % Are we able to test this epoch for a cycle slip?
    valid = sStat.mwstd(sats,4) >  1;
    if any(valid)
        compsats  = sats(valid);
        omc       = sqrt(sum((sStat.mwstd(compsats,2)-mwcomb(valid)).^2,2)); % Computes the difference for every satellite
        withslip  = omc > TH*sStat.mwstd(compsats,1);
        

        % SAVE DATA TO PLOT
        sStat.mwomc(compsats,sAlgo.iEpoch) = omc;
        sStat.mwth(compsats,sAlgo.iEpoch)  = TH*sStat.mwstd(compsats,1);
        sStat.mwtemp1(compsats,sAlgo.iEpoch) = mwcomb(valid);
        sStat.mwtemp2(compsats,sAlgo.iEpoch) = sStat.mwstd(compsats,2);
        
        
        if any(withslip)
            slipsats = compsats(withslip);
            flag     = 1;
            cs = mwcomb(withslip) - sStat.mwcombination(slipsats,end);
%             fprintf('MW slip for sats:');fprintf(' %d ',compsats(withslip));
%             fprintf('\n');
%             fprintf('%f ',cs);
%             fprintf('\n');
            sStat.mwstd(slipsats,4) = 1; % N observation
            sStat.mwstd(slipsats,3) = (lbdfw).^2; % N observation
            if sStat.mwstd(slipsats,2) == Inf
                disp('parou!');
            end
            
            sStat.mwstd(slipsats,1) = sqrt(sStat.mwstd(slipsats,3)).*2; % Standard deviation
        end
        
        compsats  = compsats(~withslip);
        % Remember to compute mean after variance as it needs the k-1 value
        sStat.mwstd(compsats,4) = sStat.mwstd(compsats,4) + 1; % Number of observations
        sStat.mwstd(compsats,3) = calcvar(mwcomb(~withslip),sStat.mwstd(compsats,2),...
                                  sStat.mwstd(compsats,3),sStat.mwstd(compsats,4));
        sStat.mwstd(compsats,2) = calcmean(mwcomb(~withslip),sStat.mwstd(compsats,2),...
                                  sStat.mwstd(compsats,4));
        sStat.mwstd(compsats,1) = sqrt(sStat.mwstd(compsats,3));%std(sStat.mwcombination(sats,end-sum(~isnan(sStat.mwcombination))+1:end),0,2); % Standard deviation

    end

    % FILTER OUT NEW COMERS - but not for the observation counter
    newsat = ~valid;
    if any(newsat)
        newsatid                          = sAlgo.availableSat(newsat); % get the ids for the new sats
        sStat.mwstd(newsatid,4)           = sStat.mwstd(newsatid,4) + 1; % N observation
        sStat.mwstd(newsatid,3)           = (lbdfw).^2; % N observation
%         sStat.mwstd(newsatid,3)           = calcvar(mwcomb(newsat),sStat.mwstd(newsatid,2),...
%                                             sStat.mwstd(newsatid,3),sStat.mwstd(newsatid,4));
        sStat.mwstd(newsatid,2)           = calcmean(mwcomb(newsat),sStat.mwstd(newsatid,2),...
                                            sStat.mwstd(newsatid,4));
        sStat.mwstd(newsatid,1)           = sqrt(sStat.mwstd(newsatid,3)); % Standard deviation
    end
    sStat.mwcombination(sats,:) = insertsl(mwcomb,sStat.mwcombination(sats ,:),1);
end


% function mean = calcmean(k,value,mean)
% %CALCMEAN computes the filtered mean
%     mean = (k-1)./k.*mean + 1./k.*value; % From navipedia
% end
% 
% function var = calcvar(k,value,mean,var)
% %CALCVAR computes the filtered variance
%     var  = (k-1)./k.*var + 1./k.*((value-mean).^2);
% end
