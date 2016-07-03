function [ sAlgo, sStat, health] = iondetector( sAlgo, sStat )
%IONDETECTOR Summary of this function goes here
%   Detailed explanation goes here


    % Initializations
    TH   = 6;
    sats = sAlgo.availableSat;
    CPL1 = sAlgo.ranges.CPL1.*gpsparams('lbdf1');
    CPL2 = sAlgo.ranges.CPL2.*gpsparams('lbdf2');   
    PRL1 = sAlgo.ranges.PRL1;
    PRL2 = sAlgo.ranges.PRL2;
    
    CPION  = CPL1 - CPL2;
    PRION  = PRL2 - PRL1;
    health = NaN;
   
    nValid                 = sum(~isnan(sStat.ionprcombination(sats,:)),2);
    valid                  = nValid >= 1;
    if any(valid)
        % Construct Poly fit to PIONO
        try
        Q           = npolyfit(sum(valid),nValid(valid),sStat.ionprcombination(sats(valid),:),2,nValid); % sAlgo keeps it then its passed to sStat
        catch
            pause(0.2)
        end
        predictedpr = npolyfit(sum(valid),nValid(valid),sStat.ionprcombination(sats(valid),:),4,nValid+1); % Extrapolate
        predictedcp = npolyfit(sum(valid),nValid(valid),sStat.ionprcombination(sats(valid),:),4,nValid+1); % Extrapolate
        
        outlier   = (CPION(valid) - Q) - (sStat.ioncpcombination(sats(valid),end-1) - sStat.ionprcombination(sats(valid),end-1)) > TH;
        cycleslip = (predictedpr - predictedcp) - (CPION(valid) - Q) < 1;
        
        if any(cycleslip == 0 | outlier == 0 )
            temp = sats(valid);
            disp(['Got a cycle slip ION in sats ',sprintf('%d ',temp(~cycleslip | ~outlier))]); 
        end
        
        sStat.ionprcombination(sats,:) = insertsl(Q,sStat.ionprcombination(sats,:),1);
    else
        sStat.ionprcombination(sats,:) = insertsl(PRION,sStat.ionprcombination(sats,:),1);
    end
    sStat.ioncpcombination(sats,:) = insertsl(CPION,sStat.ioncpcombination(sats,:),1);
    
end

