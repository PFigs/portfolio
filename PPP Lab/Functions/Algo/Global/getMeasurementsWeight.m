function  R = getMeasurementsWeight(nSat,ura,satelv,snr)
%GETMEASUREMENTSWEIGHT Summary of this function goes here
%   Detailed explanation goes here

% %     % Variance Matrix R 
%     if all(~isinf(snr))
%         R(1:nSat,1:nSat)               = diag(ura.^2./(sin(satelv-0.1).^2).*1./snr); % Code csc(satelv)
%         R(nSat+1:nSat*2,nSat+1:nSat*2) = diag(ura.^2./(sin(satelv-0.001).^2).*1./snr); % Phase
%     else
%         R(1:nSat,1:nSat)               = diag(ura.^2./(sin(satelv-0.1).^2)); % Code csc(satelv)
%         R(nSat+1:nSat*2,nSat+1:nSat*2) = diag(ura.^2./(sin(satelv-0.001).^2)); % Phase
%     end

%     % Variance Matrix R 
%     if all(~isinf(snr))
%         R(1:nSat,1:nSat)               = diag(ura.^2./(sin(satelv).^2).*1./snr); % Code csc(satelv)
%         R(nSat+1:nSat*2,nSat+1:nSat*2) = diag(ura.^2./(sin(satelv1).^2).*1./snr); % Phase
%     else
        R(1:nSat,1:nSat)               = diag(ura.^2./(sin(satelv).^2)); % Code csc(satelv)
        R(nSat+1:nSat*2,nSat+1:nSat*2) = diag(ura.^2./(sin(satelv).^2)); % Phase
%     end



%         R(1:nSat,1:nSat)               = diag(ura.^2./(sin(satelv).^2)); % Code csc(satelv)
%         R(nSat+1:nSat*2,nSat+1:nSat*2) = diag(ura.^2./(sin(satelv).^2)); % Phase

end

