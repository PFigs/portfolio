function [sAlgo, sStat, flag, slipsats] = lgdetector( iEpoch, sAlgo, sStat )
%LGDETECTOR detects and corrects (if wanted) cycle slips in the phase
%mesurements
%   
%   This function uses the geometry free combination (LG) to detect cycle
%   slips in real time
%
%   The lgcombination is stored in a 10 position window where each line
%   represent a satellite and each row a time position. The windows is
%   shifted left everytime a new data arrives and reset when the satellite
%   is lost/has cycle slip.
%
%   Please keep in mind how the window works:
%   
%       SATID  T-9 T-8 T-7 ... T-0
%         1     0   0   0       0
%         2     0  132 151 ...  129
%         3    191 200 201 ...  189
%
%   REFERENCES
%   Fang, R., SHI, C., LOU, Y., Real-time Cycle-slip detection of GPS 
%   undifferenced Carrier-phase, International conference on Earth
%   Observation Data Processing and Analysis, 2008
%
%   Pedro Silva, Instituto Superior Tecnico, April 2012

% CHECK NAVIPEDIA FOR CORRECTING THIS
% http://www.navipedia.net/index.php/Detector_based_in_carrier_phase_data:_The_geometry-free_combination

    slipsats = [];
    sats = sAlgo.availableSat;
    CPL1 = sAlgo.ranges.CPL1;
    CPL2 = sAlgo.ranges.CPL2;
    flag = 0;
    init = sStat.tecstd(sats,5)==0;
    if any(init)
        dt(init,1) = 1;
    end
    dt(~init,1)          = iEpoch -( sStat.tecstd(sats(~init),5)-1);
    sStat.lgstd(sats,5)  = iEpoch;
        
    
    assert(all(CPL1 ~= 0 ))
    assert(all(CPL2 ~= 0 ))
%     assert(all(PRL1 ~= 0 ))
%     assert(all(PRL2 ~= 0 ))
    
    
    % LG combination
    lgcomb  = gpsparams('lbdf1').*CPL1 - gpsparams('lbdf2').*CPL2;
    
    % Are we able to test this epoch for a cycle slip?
    valid = sStat.lgstd(sats,4) > 10;%sStat.lifetime(sats) >  10;
    if any(valid)
        TH   = (3/2*(gpsparams('lbdf2') - gpsparams('lbdf1')))*(1-exp(-dt(valid)./60)/2);
        compsats   = sats(valid);
        tocompare  = sAlgo.lgpredicted(compsats);
       
        % COMPARE
        withslip  = sqrt(sum((tocompare - lgcomb(valid)).^2,2)) > TH;
        
        % SAVE DATA TO PLOT
        sStat.lgtemp1(compsats,sAlgo.iEpoch) = tocompare;
        sStat.lgtemp2(compsats,sAlgo.iEpoch) = lgcomb(valid);
        
        sStat.lgomc(compsats,sAlgo.iEpoch) = sqrt(sum((tocompare - lgcomb(valid)).^2,2));
        sStat.lgth(compsats,sAlgo.iEpoch)  = TH;
        if any(withslip)
            flag     = 1;
            slipsats = sats(withslip);
            % reset this sat
%             sStat.lgstd(compsats(withslip),4)           = 1; % N observation
%             sStat.lgstd(compsats(withslip),1)           = 2;
%             sStat.lgstd(compsats(withslip),3)           = 2;
%             sStat.lgstd(compsats(withslip),2)           = 2;
            
            sStat.lgstd(compsats(withslip),4)  = 1; % N observation
            sStat.lgstd(compsats(withslip),3)  = calcvar(tocompare(withslip),sStat.lgstd(compsats(withslip),2),...
                                                 sStat.lgstd(compsats(withslip),3),sStat.lgstd(compsats(withslip),4));
            sStat.lgstd(compsats(withslip),2)  = calcmean(tocompare(withslip),sStat.lgstd(compsats(withslip),2),...
                                                 sStat.lgstd(compsats(withslip),4)); 
            sStat.lgstd(compsats(withslip),1)  = sqrt(sStat.lgstd(compsats(withslip),3));
            sStat.lgcombination(compsats(withslip),:)   = NaN;
            sStat.lgcombination(compsats(withslip),end) = tocompare(withslip);
            sAlgo.lgpredicted(compsats(withslip),end)   = tocompare(withslip);
            lgcomb(withslip)                            = tocompare(withslip);
        end 
        

    end
    
    % FILTER OUT NEW COMERS - but not for the observation counter
    newsat = ~valid;
    if any(newsat)
        newsatid                          = sAlgo.availableSat(newsat); % get the ids for the new sats
        sAlgo.lgpredicted(newsatid)       = lgcomb(newsat); % initializes window
        sStat.lgcombination(newsatid,end) = lgcomb(newsat); 
        sStat.lgstd(newsatid,4)           = sStat.lgstd(newsatid,4) + 1;
    end
    
    valid = sStat.lgstd(sats,4) > 1;
    if any(valid)
        newsatid                        = sAlgo.availableSat(valid); % get the ids for the new sats
        sStat.lgcombination(newsatid,:) = insertsl(lgcomb(valid),sStat.lgcombination(newsatid ,:),1);
        D                               = sum(~isnan(sStat.lgcombination(newsatid ,:)),2);
        sAlgo.lgpredicted(newsatid)     = npolyfit(sum(valid),D,sStat.lgcombination(newsatid ,:),2,D+1); %
        sStat.lgstd(newsatid,4)         = sStat.lgstd(newsatid ,4) + 1; % N observation
        sStat.lgstd(newsatid,3)         = calcvar(lgcomb(valid),sStat.lgstd(newsatid,2),...
                                          sStat.lgstd(newsatid,3),sStat.lgstd(newsatid,4));
        sStat.lgstd(newsatid,2)         = calcmean(lgcomb(valid),sStat.lgstd(newsatid,2),...
                                          sStat.lgstd(newsatid,4)); 
        sStat.lgstd(newsatid,1)         = sqrt(sStat.lgstd(newsatid,3));
    end
end