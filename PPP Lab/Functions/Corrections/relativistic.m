function [ dtr ] = relativistic( eph, eccanomaly )
%RELATIVISTIC obtains the relativistic correction

    F   = -2*sqrt(3.986005e14)/(2.99792458e8^2);        
    dtr = F.*eph.ecc'.*eph.sqra'.*sin(eccanomaly');
    
end

