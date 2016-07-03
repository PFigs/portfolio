function H = getDesignMatrix(nSat,cosvec,tropo,mw)
%GETDESIGNMATRIX Summary of this function goes here
%   Detailed explanation goes here

    % Design and OMC calculations
    if tropo
        H  = [ 
              -cosvec ones(nSat,1) zeros(nSat,nSat) ; % Code
              -cosvec ones(nSat,1) eye(nSat)          % Phase
             ];
    else
        H  = [ 
              -cosvec ones(nSat,1) ones(nSat,1).*mw zeros(nSat,nSat); % Code
              -cosvec ones(nSat,1) ones(nSat,1).*mw eye(nSat)         % Phase
             ];
    end
end

