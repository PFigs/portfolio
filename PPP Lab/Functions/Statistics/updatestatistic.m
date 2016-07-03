function [sStat, sAlgo] = updatestatistic( sStat, sAlgo, sEpoch )
%UPDATESTATISTIC computes the statistic for the current epoch
%   This function only makes updates to the error statistics when there's
%   available data, this means, when there are more than 4 satellites.
%
%   The only required input is iEpoch which is used to index the data
%   structures.
%
% Pedro Silva, Instituto Superior Tecnico, December 2011
% Last revision: February 2012

%TODO STAT Definition?

    sStat.hit = sStat.hit + 1;
    iEpoch    = sEpoch.iEpoch;
    sats      = sAlgo.availableSat;
    
    % Checks size - Save them to the disk instead of growing them : create
    % a persistent index (mod iepoch?)
    if iEpoch == length(sStat.userxyz)-1
        expand            = userparams('largearray'); 
        sStat.userxyz     = [sStat.userxyz; NaN(expand,3)];
        sStat.userenu     = [sStat.userenu; NaN(expand,3)];
        
        sStat.rcvclk      = [sStat.rcvclk; NaN(expand,1)];
        sStat.sigmaclk    = [sStat.sigmaclk; NaN(expand,1)];
        
        sStat.ambiguities = [sStat.ambiguities NaN(userparams('MAXSAT'),expand)];
        sStat.sigmaamb    = [sStat.sigmaamb  NaN(userparams('MAXSAT'),expand)];
        
        sStat.usedsats    = [sStat.usedsats NaN(userparams('MAXSAT'),expand)];
        sStat.satelv      = [sStat.satelv  NaN(userparams('MAXSAT'),expand)];
        sStat.sataz       = [sStat.sataz   NaN(userparams('MAXSAT'),expand)];
%         sStat.satclk      = [sStat.satclk   NaN(userparams('MAXSAT'),expand)];
%         sStat.residuals   = [sStat.residuals NaN(userparams('MAXSAT'),expand)];
        
        sStat.pdop        = [sStat.pdop; NaN(expand,1)];
        sStat.hdop        = [sStat.hdop; NaN(expand,1)];
        sStat.vdop        = [sStat.vdop; NaN(expand,1)];
        sStat.gdop        = [sStat.gdop; NaN(expand,1)];
        
        sStat.sigmaeast   = [sStat.sigmaeast; NaN(expand,1)];
        sStat.sigmanorth  = [sStat.sigmanorth; NaN(expand,1)];
        sStat.sigmaup     = [sStat.sigmaup; NaN(expand,1)];
        
        sStat.pdop        = [sStat.pdop; NaN(expand,1)];
        sStat.hdop        = [sStat.hdop; NaN(expand,1)];
        sStat.vdop        = [sStat.vdop; NaN(expand,1)];
        sStat.gdop        = [sStat.gdop; NaN(expand,1)];
        
    end
    
    ref  = sStat.refpoint(1,:);
    % Computes error for diff control points
    S                           = inv(sAlgo.cosH(:,1:4)'*sAlgo.cosH(:,1:4));
    sStat.userxyz(iEpoch,:)     = sAlgo.userxyz;
    sStat.userenu(iEpoch,:)     = eceftoenu(sAlgo.userxyz,ref);
    sStat.rcvclk(iEpoch,:)      = sAlgo.rcvclk;
    
    sStat.ambiguities(sats,iEpoch) = sAlgo.ambiguities(sats);
    try
    sStat.ambiguitiesL1(sats,iEpoch) = sAlgo.ambiguitiesL1(sats);
    sStat.ambiguitiesL2(sats,iEpoch) = sAlgo.ambiguitiesL2(sats);
    end    
    
    valid =~ isnan(sStat.userxyz(:,1));
    
    sStat.sigmaclk(iEpoch)      = std(sStat.rcvclk(valid));
    sAlgo.sigmaclk              = sStat.sigmaclk(iEpoch);
    sStat.sigmaeast(iEpoch)     = std(sStat.userenu(valid,1));
    sStat.sigmanorth(iEpoch)    = std(sStat.userenu(valid,2));
    sStat.sigmaup(iEpoch)       = std(sStat.userenu(valid,3));
    
    sStat.pdop(iEpoch)          = sqrt(trace(S(1:3,1:3)));  
    sStat.hdop(iEpoch)          = sqrt(trace(S(1:2,1:2)));
    sStat.vdop(iEpoch)          = sqrt(S(3,3));
    sStat.gdop(iEpoch)          = sqrt(trace(S(1:4,1:4)));
    
    
    %tdop
    sStat.residuals{1}(sats,iEpoch) = sAlgo.residuals(:,1); % Range
    try
    sStat.residuals{2}(sats,iEpoch) = sAlgo.residuals(:,2); % Range
    end
    sStat.usedsats(sats,iEpoch)     = sats;
    sStat.satelv(sats,iEpoch)       = sAlgo.satelv(sats);
    sStat.sataz(sats,iEpoch)        = sAlgo.sataz;
    sStat.satclk(sats,iEpoch)       = sAlgo.satclk(sats);

    sStat.satx(sats,iEpoch)   = sAlgo.satxyz(sats,1);
    sStat.saty(sats,iEpoch)   = sAlgo.satxyz(sats,2);
    sStat.satz(sats,iEpoch)   = sAlgo.satxyz(sats,3);
    
%     try
%         sStat.SNRCA(sats,iEpoch)    = sEpoch.ranges.SNRCA(sats)';
%         sStat.SNRL1(sats,iEpoch)    = sEpoch.ranges.SNRL1(sats)';
%         sStat.SNRL2(sats,iEpoch)    = sEpoch.ranges.SNRL2(sats)';
%     end
end
