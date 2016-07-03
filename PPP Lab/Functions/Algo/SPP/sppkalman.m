function sAlgo = sppkalman(sAlgo, TOW, DOY, WD )
%SPPKALMAN Summary of this function goes here
%   Detailed explanation goes here


    % Runs SPP for initialization
    if sAlgo.count < userparams('initialconv')
        sAlgo = sppalgo( sAlgo, TOW, DOY, WD);
        return;
%     else
%         sAlgo = sppalgo( sAlgo, TOW, DOY, WD);    
    end

     % INIT
    userxyz = sAlgo.userxyz;
    rcvclk  = sAlgo.rcvclk;
    sats    = sAlgo.availableSat;
    nSat    = sAlgo.nSat;
    eph     = sAlgo.eph;
    ura     = sAlgo.eph.ura';
    flags   = sAlgo.flags;
    tropo   = sAlgo.flags.usetropo;
    snr     = sAlgo.ranges.SNR;    
    code    = sAlgo.ranges.PRL1;
    phase   = sAlgo.ranges.CPL1;
    comb    = 0.5*(sAlgo.ranges.PRL1+sAlgo.ranges.CPL1);
    nParams = 4;

    
    % Obtain satellite coordinates
    [ satxyz, satclk, ~, satxyzdiff, satclkdiff] =  precisepos(sAlgo.iEpoch,userxyz, eph, WD, TOW, flags, sAlgo.antex, sAlgo.sun); %precisepos(userxyz,eph,WD,TOW,flags,[]); 

    % Obtain corrections
    [cosvec, enuvec, satenu, nvec] = directorcos(userxyz,satxyz,'enu');
    satelv                         = elevation(enuvec,'rad');
    sataz                          = azimuth(satenu,'rad');
    
    % Obtain tropo delay
    lla               = eceftolla(userxyz);
    [zpd,drycomp,mw]  = zenithdelay(lla(1),lla(3),satelv,DOY); 
    if tropo, zpd     = drycomp; end;
    % Init new sats
    
    P = zeros(nParams,nParams);
    Q = zeros(nParams,nParams);
    X = zeros(nParams,1);
    
%     sAlgo.tempcount(sats) = sAlgo.tempcount(sats)+1;
    
    
    Z = code  + satclk - (nvec + zpd + rcvclk); %-218.763454401;%*sAlgo.count;  
    
%     if any(abs(Z) > 200 & abs(Z) < 1000)
%         disp('iuuupi\n');     
%         
%         suspects = abs(Z) > 200;
%         
%         gt2=Z > 200 & abs(Z) < 1000;
%         if any(gt2)
%             %Z(gt2)-218.763454401
%              removebias(Z(gt2 & suspects),-218.763454401.*ones(size(Z(gt2 & suspects),1),1));
%         end
%          
%         lt2=Z < 200 & abs(Z) < 1000;
%         if any(lt2)
%             try
%              removebias(Z(lt2 & suspects),+218.763454401.*ones(size(Z(lt2 & suspects),1),1));
%             catch
%                 disp('nin')
%             end
%         end
%         
%     end
    
    
    H = [-cosvec ones(nSat,1)];
    R = diag(ura.^2./(sin(satelv+0.1).^2));
    X(1:nParams,1)     = [sAlgo.userxyz';sAlgo.rcvclk];
    
    
    
    
    P(1:nParams,1:nParams)         = sAlgo.covariance{1};
%     P(nParams+1:end,nParams+1:end) = sAlgo.covariance{2}(sats,sats);
    
    Q(1:nParams,1:nParams)         = sAlgo.noise{1};
%     Q(nParams+1:end,nParams+1:end) = sAlgo.noise{2}(sats,sats);
    
    % Measurement update
    K  = P*H'/(H*P*H'+R);  % Kalman Gain
    X  = X + K*Z;K*Z          % Estimate update
    P  = P - K*H*P;        % Update the error covariance     

    % Time update (next state)
%     Edt = sAlgo.iEpoch-sAlgo.lastseen;
%     if ~isnan(Edt), Q = Q.*Edt; end;
%     Q(4,4) = mean(X(4))/sAlgo.rcvclk;
    Phi    = eye(nParams);          
    Xnew   = Phi*X;
    P      = Phi*P*Phi'+Q;
        
    
        
    residuals = Z;
    sAlgo.residuals = zeros(nSat,2);
    % ESTIMATED
    sAlgo.userxyz                   = Xnew(1:3)';
    sAlgo.rcvclk                    = Xnew(4);
%     sAlgo.ambiguities(sats)         = X(nParams+1:end);
    sAlgo.residuals(:,1)            = residuals(1:nSat);
%     sAlgo.windup(sats)              = windup;
%     sAlgo.rcvclk = rcvclk;
    % PREDITECD
    sAlgo.estimate{1}               = Xnew(1:nParams);
    sAlgo.covariance{1}             = P(1:nParams,1:nParams);
    sAlgo.noise{1}                  = Q(1:nParams,1:nParams);
    sAlgo.satxyz(sats,:)            = satxyzdiff;
    sAlgo.satclk(sats)              = satclkdiff;
    sAlgo.satelv(sats)              = satelv;
    sAlgo.sataz                     = sataz;
    sAlgo.cosH                      = H;
end



function ret = removebias(value,sub)

    ret = value +sub;
    
    if any(abs(ret)>200)
        ret = removebias(ret,sub);
    end

end



% 
% function sAlgo = sppkalman(sAlgo, TOW, DOY, WD )
% %SPPKALMAN Summary of this function goes here
% %   Detailed explanation goes here
% 
% 
%     % Runs SPP for initialization
%     if sAlgo.count < userparams('initialconv')
%         sAlgo = sppalgo( sAlgo, TOW, DOY, WD);
%         return;
%     end
% 
%      % INIT
%     userxyz = sAlgo.userxyz;
%     rcvclk  = sAlgo.rcvclk;
%     sats    = sAlgo.availableSat;
%     nSat    = sAlgo.nSat;
%     eph     = sAlgo.eph;
%     ura     = sAlgo.eph.ura';
%     flags   = sAlgo.flags;
%     tropo   = sAlgo.flags.usetropo;
%     snr     = sAlgo.ranges.SNR;    
%     code    = sAlgo.ranges.PRL1;
%     phase   = sAlgo.ranges.CPL1;
%     comb    = 0.5*(sAlgo.ranges.PRL1+sAlgo.ranges.CPL1);
%     nParams = 4;
%    
%     
%     % Obtain satellite coordinates
%     [satxyz, satclk] = precisepos(userxyz,eph,WD,TOW,flags,[]); 
% 
%     % Obtain corrections
%     [cosvec, enuvec, satenu, nvec] = directorcos(userxyz,satxyz,'enu');
%     satelv                         = elevation(enuvec,'rad');
%     sataz                          = azimuth(satenu,'rad');
%     
%     % Obtain tropo delay
%     lla               = eceftolla(userxyz);
%     [zpd,drycomp,mw]  = zenithdelay(lla(1),lla(3),satelv,DOY); 
%     if tropo, zpd     = drycomp; end;
%     % Init new sats
%     
%         P                              = zeros(nParams+nSat,nParams+nSat);
%     Q                              = zeros(nParams+nSat,nParams+nSat);
%     X                              = zeros(nParams+nSat,1);
%     
%     amb = sAlgo.estimate{2}(sats,:);
%     newsats           = amb == amb;
%     if any(newsats)
%         amb(newsats)  = (phase(newsats) - nvec(newsats) + satclk(newsats) - zpd(newsats) - rcvclk);
% %         amb(newsats)  = (amb+2*(comb(newsats) - nvec(newsats) + satclk(newsats) - zpd(newsats) - rcvclk))/2;
%     end
%     
%     Z = [...
% %         comb  + satclk - (nvec + zpd + 0.5*amb + rcvclk );    
%         code  + satclk - (nvec + zpd + rcvclk );    
%         phase + satclk - (nvec + zpd + amb + rcvclk );    
%         ];
%         
%         
%     H = [ ...
% %         -cosvec ones(nSat,1) 0.5*ones(nSat,nSat);
%         -cosvec ones(nSat,1) zeros(nSat,nSat);
%         -cosvec ones(nSat,1) ones(nSat,nSat);
%         ];
%     
%     
% %     
%     R(1:nSat,1:nSat) = diag(ura.^2./(sin(satelv+0.1).^2).*snr);
%     R(nSat+1:nSat+nSat,nSat+1:nSat+nSat) = diag(ura.^2./(sin(satelv+0.1).^2).*snr);
% %     R(nSat*2+1:nSat*3,nSat+1:nSat+nSat) = diag(ura.^2./(sin(satelv+0.1).^2).*snr);
% %     R = eye(nSat*2);
% %     R = diag([ura.^2./(sin(satelv+0.1).^2).*snr;ura.^2./(sin(satelv+0.1).^2).*snr;ura.^2./(sin(satelv+0.1).^2).*snr]);
%     X(1:nParams,1)                 = sAlgo.estimate{1};
%     X(nParams+1:end,1)             = amb;
%     
%     
%     P(1:nParams,1:nParams)         = sAlgo.covariance{1};
%     P(nParams+1:end,nParams+1:end) = sAlgo.covariance{2}(sats,sats);
%     
%     
%     Q(1:nParams,1:nParams)         = sAlgo.noise{1};
%     Q(nParams+1:end,nParams+1:end) = sAlgo.noise{2}(sats,sats);
%     
%     % Measurement update
%     K  = P*H'/(H*P*H'+R);  % Kalman Gain
%     X  = X + K*Z;          % Estimate update
%     P  = P - K*H*P;        % Update the error covariance    
% 
%     % Time update (next state)
%     Edt = sAlgo.iEpoch-sAlgo.lastseen;
%     if ~isnan(Edt), Q = Q.*Edt; end;
%     Q(4,4) = mean(X(4))/sAlgo.rcvclk;
%     Phi    = eye(nParams + nSat);          
%     Xnew   = Phi*X;
%     P      = Phi*P*Phi'+Q;
%         
%     % ESTIMATED
%     sAlgo.userxyz                   = X(1:3)';
%     sAlgo.rcvclk                    = Xnew(4);
%     sAlgo.ambiguities(sats)         = X(nParams+1:end);
%     sAlgo.residuals                 = Z;
% %     sAlgo.windup(sats)              = windup;
%     
%     % PREDITECD
%     sAlgo.estimate{1}               = Xnew(1:nParams);
%     sAlgo.estimate{2}(sats,:)       = Xnew(nParams+1:end);
%     sAlgo.covariance{1}             = P(1:nParams,1:nParams);
%     sAlgo.covariance{2}(sats,sats)  = P(nParams+1:end,nParams+1:end);
%     sAlgo.noise{1}                  = Q(1:nParams,1:nParams);
%     sAlgo.noise{2}(sats,sats)       = Q(nParams+1:end,nParams+1:end);
%     sAlgo.satxyz                    = satxyz;
%     sAlgo.satelv(sats)              = satelv;
%     sAlgo.sataz                     = sataz;
%     sAlgo.cosH                      = H;
% end
% % 
