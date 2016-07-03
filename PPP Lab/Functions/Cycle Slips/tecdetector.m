function [ sAlgo, sStat, flagcs, slipsats, cs ] = tecdetector(iEpoch, sAlgo, sStat)
%TECDETECTOR Summary of this function goes here
%   This function uses the carrier phase information to estimate and
%   compute the TECR. This method alongside with MW should be able to
%   detect all cycle slips, even under strong ionosphere activity as well
%   as several special cases.
%
% REFERENCE:
%   [1] Z. Liu, �A new automated cycle slip detection and repair ...
%   method for a single dual-frequency GPS receiver,� Journal of Geodesy,...
%   vol. 85, no. 3, pp. 1�13, Nov. 2010.    
    
    % Needed constants
    slipsats = [];
    flagcs   = 0;
    cs       = 0;
    sats     = sAlgo.availableSat;        
    TH       = userparams('TH');

    % Check delta t for each satellite
    init  = sStat.tecstd(sats,5)==0;
    if any(init)
        dt(init,1) = 1;
    end
    dt(~init,1)           = iEpoch - sStat.tecstd(sats(~init),5);
    sStat.tecstd(sats,5)  = iEpoch;
    sStat.teccpl1(sats,:) = insertsl(sAlgo.ranges.CPL1,sStat.teccpl1(sats,:),1);
    sStat.teccpl2(sats,:) = insertsl(sAlgo.ranges.CPL2,sStat.teccpl2(sats,:),1);

    
    % If enough data compute and estimates TECR
    valid    =  sStat.tecstd(sats,4) > 2;
    compsats = sats(valid);
    
    if any(~valid)
        sStat.tecstd(sats(~valid),4) = sStat.tecstd(sats(~valid),4) + 1;    
        sStat.tecstd(sats(~valid),3) = 0.01;
        sStat.tecstd(sats(~valid),2) = 0.01;
        sStat.tecstd(sats(~valid),1) = 0.01;
    end
    
    if any(valid)
        TECR = calcTECR(sStat.teccpl1(compsats,1:end),sStat.teccpl2(compsats,1:end),dt(valid));
        
        % ESTIMATE TECR -- Needs at least 2 epochs
        valid     = sStat.tecstd(compsats,4) > 3;
        checksats = compsats(valid);
        if any(valid)
            A = calcTECR(sStat.teccpl1(checksats,1:end-1),sStat.teccpl2(checksats,1:end-1),dt(valid));
            B = calcTECR(sStat.teccpl1(checksats,1:end-2),sStat.teccpl2(checksats,1:end-2),dt(valid));
            TECRest = A + A - B;
        
            omc      = sqrt(sum( ( TECR(valid) - TECRest ).^2,2));
            withslip = abs( omc - sStat.tecstd(checksats,2))  > abs(TH*sStat.tecstd(checksats,1));
            
            % SAVE DATA TO PLOT
            sStat.tecomc(checksats,sAlgo.iEpoch) = omc;
            sStat.tecth(checksats,sAlgo.iEpoch)  = TH*sStat.tecstd(checksats,1);
            sStat.tectemp1(checksats,sAlgo.iEpoch) = TECR(valid);
            sStat.tectemp2(checksats,sAlgo.iEpoch) = TECRest;
            
            if any(withslip)
                % got a cycle slip
                flagcs   = 1;
                slipsats = checksats(withslip);
                cs       = calccycleslip( TECR(withslip), sStat.teccpl1(checksats(withslip),end-1:end),...
                                    sStat.teccpl2(checksats(withslip),end-1:end), dt(withslip));
                                
                % Check carrier difference between epochs, should provide the jump
                % Correct the jump

                TECR(withslip) = TECRest(withslip);
%                 sStat.tecstd(slipsats,4) = 1;
%                 sStat.tecstd(slipsats,3) = 0.01;%calcvar(TECRest(withslip),sStat.tecstd(slipsats,2),...
%                                    sStat.tecstd(slipsats,3),sStat.tecstd(slipsats,4)); % Variance 
%                 sStat.tecstd(slipsats,2) = 0.01;%calcmean(TECRest(withslip),sStat.tecstd(slipsats,2),...
%                                    sStat.tecstd(slipsats,4)); % Mean
%                 sStat.tecstd(slipsats,1) = 0.01;%sqrt(sStat.tecstd(slipsats,3));
                
            end
            
            %Update only satellites without slips
            compsats = compsats(~withslip);
            TECR     = TECR(~withslip);
        end
        
        
        
        % Compute mean and var for the next epoch
        sStat.tecstd(compsats,4) = sStat.tecstd(compsats,4) + 1;
        sStat.tecstd(compsats,3) = calcvar(TECR,sStat.tecstd(compsats,2),...
                                   sStat.tecstd(compsats,3),sStat.tecstd(compsats,4)); % Variance 
        sStat.tecstd(compsats,2) = calcmean(TECR,sStat.tecstd(compsats,2),...
                                   sStat.tecstd(compsats,4)); % Mean
        sStat.tecstd(compsats,1) = sqrt(sStat.tecstd(compsats,3));

        % Save TECR
%         sStat.TECR(compsats,iEpoch)    = TECR;
%         sStat.TECRest(compsats,iEpoch) = TECRest;
    end

    
end

function jump = calccycleslip( TECR, CPL1, CPL2, dt)

    f1    = gpsparams('f1');
    gama  = gpsparams('gama');
    lbdf1 = gpsparams('lbdf1');
    lbdf2 = gpsparams('lbdf2');
    
    A = smooth(CPL1(~isnan(CPL1(:,end)),end));
    B = smooth(CPL1(~isnan(CPL1(:,end-1)),end-1));
    C = smooth(CPL2(~isnan(CPL2(:,end)),end));
    D = smooth(CPL2(~isnan(CPL2(:,end-1)),end-1));
    
    jump = dt.*(40.3e16*(gama-1)*TECR)/(f1^2) ...
           - lbdf1.*(A - B) ...
           + lbdf2.*(C - D);
    
end

function value = calcTECR( CPL1, CPL2, dt )
%TECR computes the TECR value using the carrier phase information
%   Only previous information regarding the current epoch is used
%   TECR(k) = {TEC(k) - TEC(k-1)}/dt
%
%   INPUT
%   CPLi - Vector with [ ... CPL1(k-1), CPL1(k)] % only the last two are
%          used, i=1,2
%
%   dt   - Time between epochs
%
%   Pedro Silva, Instituto Superior Tecnico, July 2012

    % [TECR(k-1) - TECR(k-2)]/dt
    f1    = gpsparams('f1');
    gama  = gpsparams('gama');
    lbdf1 = gpsparams('lbdf1');
    lbdf2 = gpsparams('lbdf2');

    A = CPL1(:,end);
    B = CPL1(:,end-1);
    C = CPL2(:,end);
    D = CPL2(:,end-1);  
    
    K  = (f1^2)./(40.3e16.*(gama-1)).*1./dt;
    L1 = lbdf1.*(A - B);
    L2 = lbdf2.*(C - D);
    value = (L1 - L2)./K;
    
end
