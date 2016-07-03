function [sAlgo, sStat, dopflag, dopsats, dopcs] = dopdetector( sEpoch, sAlgo, sStat, l2flag )
%DOPDETECTOR detects cycle slips using doopler measurements
    
    TH         = userparams('TH');
    sats       = sAlgo.availableSat;
    dopflag    = 0;
    dopcs{1}   = [];
    dopcs{2}   = [];
    dopsats{1} = [];
    dopsats{2} = [];    
    
    % Check which satellites have been nitialise
    valid  = sStat.dopl1std(sats,4) > 1;
    withdata = (sAlgo.imuCPL1(sats,end-1) ~= 0 & sAlgo.imuCPL1(sats,end) ~= 0 );
    if l2flag
        valid    = valid & sStat.dopl2std(sats,4) > 1;
        withdata = withdata &  (sAlgo.imuCPL2(sats,end-1) ~= 0 & sAlgo.imuCPL2(sats,end) ~= 0 );
    end
    if any(valid & withdata)
        topredict = sats(valid & withdata); % only has information for SATS
        driftL1   = abs(sAlgo.imuCPL1(topredict,end) - sAlgo.imuCPL1(topredict,end-1)) - abs(sAlgo.dDopL1(topredict,sEpoch.iEpoch))*gpsparams('f1')/gpsparams('c');
        withslip  = abs(abs(driftL1) -abs(sStat.dopl1std(topredict,2))) > TH*sStat.dopl1std(topredict,1)+0.1;
        
                
        % SAVE DATA TO PLOT
        sStat.dopomcl1(topredict,sAlgo.iEpoch) = abs(abs(driftL1) -abs(sStat.dopl1std(topredict,2)));
        sStat.dopthl1(topredict,sAlgo.iEpoch)  = TH.*sStat.dopl1std(topredict,1)+abs(sStat.dopl1std(topredict,2));
        sStat.doptemp1(topredict,sAlgo.iEpoch) = abs(sAlgo.imuCPL1(topredict,end) - sAlgo.imuCPL1(topredict,end-1));
        sStat.doptemp2(topredict,sAlgo.iEpoch) = abs(sAlgo.dDopL1(topredict,sEpoch.iEpoch))*gpsparams('f1')/gpsparams('c');
        
        if any(withslip & sStat.lifetime(topredict) > 2)
            withslip(abs(driftL1)<1) = 0;
            sStat.dopomcl1(topredict(abs(driftL1)<2),sAlgo.iEpoch) = 0;
            if any(withslip)
                dopsats{1}        = sEpoch.getids(topredict(withslip));
                dopflag           = 1;
                dopcs{1}          = round(driftL1(withslip)).* sign( sAlgo.dDopL1(topredict(withslip),sEpoch.iEpoch));
                driftL1(withslip) = driftL1(withslip) - dopcs{1};
                sStat.dopl1std(topredict(withslip),4) = 0;
                sStat.dopl1std(topredict(withslip),1) = gpsparams('lbdf1')*TH;
            end
        end
        savepred  = topredict;
        topredict = topredict(~withslip);
        driftL1   = driftL1(~withslip);
        sStat.dopl1std(topredict,4) = sStat.dopl1std(topredict,4) + 1; % Number of observations
        sStat.dopl1std(topredict,3) = calcvar(driftL1,sStat.dopl1std(topredict,2),...
                                      sStat.dopl1std(topredict,3),sStat.dopl1std(topredict,4));
        sStat.dopl1std(topredict,2) = calcmean(driftL1,sStat.dopl1std(topredict,2),...
                                      sStat.dopl1std(topredict,4));
        sStat.dopl1std(topredict,1) = sqrt(sStat.dopl1std(topredict,3));
        
        
        if l2flag
            topredict = savepred;
            driftL2  = abs(sAlgo.imuCPL2(topredict,end) - sAlgo.imuCPL2(topredict,end-1)) - abs(sAlgo.dDopL2(topredict,sEpoch.iEpoch))*gpsparams('f2')/gpsparams('c');
            withslip = (abs(driftL2)-abs(sStat.dopl2std(topredict,2)))  > TH*sStat.dopl2std(topredict,1)+0.1;
                        
            % SAVE DATA TO PLOT
            sStat.dopomcl2(topredict,sAlgo.iEpoch) = (abs(driftL2)-abs(sStat.dopl2std(topredict,2)));
            sStat.dopthl2(topredict,sAlgo.iEpoch)  = TH.*sStat.dopl2std(topredict,1);
            
            if any(withslip & sStat.lifetime(topredict) > 2)
                withslip(abs(driftL2)<1) = 0;
                sStat.dopomcl2(topredict(abs(driftL2)<2),sAlgo.iEpoch) = 0;
                if any(withslip)
                    dopsats{2}        = sEpoch.getids(topredict(withslip));
                    dopflag           = 1;
                    dopcs{2}          = round(driftL2(withslip)).* sign( sAlgo.dDopL2(topredict(withslip),sEpoch.iEpoch));
                    driftL2(withslip) = driftL2(withslip) - dopcs{2};
                    sStat.dopl2std(topredict(withslip),4) = 0;
                    sStat.dopl2std(topredict(withslip),1) = gpsparams('lbdf2')*TH;
                end
            end
            topredict = topredict(~withslip);
            driftL2   = driftL2(~withslip);
            % Statistics update
            sStat.dopl2std(topredict,4) = sStat.dopl2std(topredict,4) + 1; % Number of observations
            sStat.dopl2std(topredict,3) = calcvar(driftL2,sStat.dopl2std(topredict,2),...
                                          sStat.dopl2std(topredict,3),sStat.dopl2std(topredict,4));
            sStat.dopl2std(topredict,2) = calcmean(driftL2,sStat.dopl2std(topredict,2),...
                                          sStat.dopl2std(topredict,4));
            sStat.dopl2std(topredict,1) = sqrt(sStat.dopl2std(topredict,3));
            
        end
        
        
    end
    
    if any(~valid)
        initsatdop = sats(~valid);
        sStat.dopl1std(initsatdop,4) = sStat.dopl1std(initsatdop,4) + 1;
        sStat.dopl1std(initsatdop,1) = gpsparams('lbdf1');
        
        if l2flag
            sStat.dopl2std(initsatdop,4) = sStat.dopl2std(initsatdop,4) + 1;
            sStat.dopl2std(initsatdop,1) = gpsparams('lbdf2');
        end
    end
    
end
