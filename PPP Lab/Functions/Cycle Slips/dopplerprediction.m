function [ output_args ] = dopplerprediction( sEpoch, sAlgo, sStat, sats )
%DOPPLERPREDICTION Summary of this function goes here
%   Detailed explanation goes here


        % Compute predicted Code and Phase
    % Satellite velocity
    eph                = buildsEph(sEpoch.eph.data(:,sats)); 
    [cosvec,~,~,nvec]  = directorcos(sAlgo.userxyz,satpos(eph,sAlgo.userxyz,sEpoch.TOW),'enu');
    [ ~, ~, ~, iTime ] = satpos(eph,sAlgo.userxyz,sEpoch.TOW);    
    
    % use precise pos to compute satellite coordinates
    % use velocity information from professor Sanguino
    
    satv    = (satcoord(eph,iTime'-1,1) - satcoord(eph,iTime'+1,1))./2;
    satv    = diag(satv*cosvec');
    rcvv    = sum(sEpoch.IMU.windowVEL(:,end));
    if any(isnan(rcvv))
        rcvv = 0;
    end
    sAlgo.dDopL1(sats,sEpoch.iEpoch) = -(satv-rcvv)./gpsparams('lbdf1');
    sAlgo.dDopL2(sats,sEpoch.iEpoch) = -(satv-rcvv)./gpsparams('lbdf2');

    
    valid = sStat.lifetime(sats) > 1;
    % Check if already initialised or not!
    if any(valid)
        topredict = sStat.lifetime(1:maskGNSS) > 1 & sats';
        sAlgo.pCPL1(topredict)    = sAlgo.pCPL1(topredict) + inttrap(sAlgo.dDopL1(topredict,sEpoch.iEpoch-1:sEpoch.iEpoch));
        sAlgo.pCPL2(topredict)    = sAlgo.pCPL2(topredict) + inttrap(sAlgo.dDopL2(topredict,sEpoch.iEpoch-1:sEpoch.iEpoch));
        sAlgo.pPRL1(topredict)    = sAlgo.pPRL1(topredict) + inttrap(sAlgo.dDopL1(topredict,sEpoch.iEpoch-1:sEpoch.iEpoch)).*gpsparams('lbdf1');
        sAlgo.pPRL2(topredict)    = sAlgo.pPRL2(topredict) + inttrap(sAlgo.dDopL2(topredict,sEpoch.iEpoch-1:sEpoch.iEpoch)).*gpsparams('lbdf2');
            
        if sEpoch.iEpoch  == 100
            sEpoch.ranges.CPL1(iEpoch,topredict) = (sEpoch.ranges.CPL1(iEpoch,topredict)+2);
            sEpoch.ranges.CPL2(iEpoch,topredict) = (sEpoch.ranges.CPL2(iEpoch,topredict));   
        end

        try
%         (sEpoch.ranges.CPL1(iEpoch,topredict)' - sStat.OBSCPL1(topredict,iEpoch-1)) - sAlgo.dDopL1(sats,sEpoch.iEpoch)
%         (sEpoch.ranges.CPL2(iEpoch,topredict)' - sStat.OBSCPL2(topredict,iEpoch-1)) - sAlgo.dDopL2(sats,sEpoch.iEpoch)% - sAlgo.pPRL1(topredict)
        catch
            pause(0.1);
        end
        sAlgo.pPRL1(topredict) - sEpoch.ranges.PRL1(iEpoch,topredict)';
    end
    if any(~valid)
        initsatdop           = sStat.lifetime(1:maskGNSS) == 1 & sats';

        if caflag
        sAlgo.pCPL1(initsatdop)    = sEpoch.ranges.CPCA(iEpoch, initsatdop)';%+ sAlgo.dDopL1(sats,sEpoch.iEpoch).*gpsparams('lbdf1');
        end
        sAlgo.pCPL2(initsatdop)    = sEpoch.ranges.CPL2(iEpoch, initsatdop)';%+ sAlgo.dDopL2(sats,sEpoch.iEpoch).*gpsparams('lbdf2');
        sAlgo.pPRL1(initsatdop)    = sEpoch.ranges.PRL1(iEpoch, initsatdop)';%+ sAlgo.dDopL1(sats,sEpoch.iEpoch).*gpsparams('lbdf1');
        sAlgo.pPRL2(initsatdop)    = sEpoch.ranges.PRL2(iEpoch, initsatdop)';%+ sAlgo.dDopL2(sats,sEpoch.iEpoch).*gpsparams('lbdf2');
    end
    



end

