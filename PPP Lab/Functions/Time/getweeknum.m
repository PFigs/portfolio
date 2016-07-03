function [ week ] = getweeknum(cyear,sdate)
%GETWEEKNUM Obtains current week number
%   This function uses a reference year to compute the current week. This 
%   means that observations regarding years previous to 2011 will not work.
%
%   INPUT
%   CYEAR - Current year
%   SDATE - Date in serial format
%
%   OUTPUT
%   WEEK - Current week number
%
%   Pedro Silva, Instituto Superior Tecnico, October 2011
    
    % YEAR REFERENCE
    refyear = userparams('Reference Year'); % Reference year
    refweek = userparams('Reference Week'); % Years's first week number
    
    % Adjust first week number for later years - 52 weeks each year
    if cyear ~= refyear, refweek = refweek + (cyear - refyear)*52; end
    
    % Credits to MATHWORKS
    dFirst = datenum(cyear,1,1);   % Date number of first day of year
    nDay   = mod(fix(dFirst)-2,7);  % Weekday number offset (Sunday first day)
    wkn    = fix((sdate - dFirst + nDay)./7)+1; % Get date number relative to days in year of entered date
    
    week = refweek + wkn;

end
