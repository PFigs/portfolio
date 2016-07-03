function [Z,amb,h] = getObservedMinusComputed(nSat,nvec,satclk,rcvclk,zpd,code,phase,amb,windup)
%GETOBSERVEDMINUSCOMPUTED Summary of this function goes here
%   Detailed explanation goes here
    
    % Init new sats
    newsats           = amb == 0;
    if any(newsats)
        amb(newsats)  = phase(newsats) - nvec(newsats) + satclk(newsats) - zpd(newsats) - rcvclk;
    end
    
    % Compute residuals
    h = zeros(nSat*2,1);
    h(1:nSat,1)        = nvec + zpd + rcvclk;
    h(nSat+1:nSat*2,1) = nvec + zpd + amb + rcvclk + windup;
    
    Z = zeros(nSat*2,1);
    Z(1:nSat,1)        = code  + satclk - h(1:nSat,1);  
    Z(nSat+1:nSat*2,1) = phase + satclk - h(nSat+1:nSat*2,1);      
end