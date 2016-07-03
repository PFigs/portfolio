function [ tsv, dtr ] = dtsv( eph, eccanomaly, tow, mode)
%DTSV Obtains de delta TSV correction
%   For each operating mode this function returns the clock correction
%
%   INPUT 
%   EPH - Ephemerides data
%   ECCANOMALY - Eccentric anomaly
%   TOW - Time of week
%   MODE - Operation mode
%          L1
%          L2
%          L1L2
%
%   OUTPUT
%   TSV - Offset for SV clock correction

    if ~ischar(mode)
        error('dtsv: must be string');
    end

    F   = -2*sqrt(3.986005e14)/(2.99792458e8^2);        
    dtr = F.*eph.ecc'.*eph.sqra'.*sin(eccanomaly');
    tsv = eph.af0' + eph.af1'.*(tow-eph.toc') + eph.af2'.*((tow-eph.toc').^2) + dtr;
    
    if strcmpi(mode,'L1')
        tsv = tsv - eph.tgd';
    elseif strcmpi(mode, 'L2')
        tsv = tsv - gpsparams('gama').*eph.tgd';
    end

end

