function tsv = clockcorrection( eph, tow, mode)
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

    tsv = eph.af0' + eph.af1'.*(checktime(tow-eph.toc')) + eph.af2'.*((checktime(tow-eph.toc')).^2);
    
    if strcmpi(mode,'L1')
        tsv = tsv - eph.tgd';
    elseif strcmpi(mode, 'L2')
        tsv = tsv - (77/60)^2.*eph.tgd';
    end

end

