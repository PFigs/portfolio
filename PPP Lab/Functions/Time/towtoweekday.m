function [ wkd ] = towtoweekday( TOW )
%OBSWEEKDAY returns the week day for the given TOW
%   TOW is a wekkly counter of the number of seconds between Sunday
%   midnight and the time of observation.
%
%   INPUT
%   TOW - Time of week in seconds ( 0 < TOW <  604800)
%
%   OUTPUT
%   WKD - Week day 
%       0 - Sunday          
%       1 - Monday 
%       2 - Tuesday
%       3 - Wednesday
%       4 - Thursday
%       5 - Friday
%       6 - Saturday
%
%   Pedro Silva, Instituto Superior Técnico, November 2011
    
    % Check input
    if ~isscalar(TOW)
        error('towtoweekday: TOW must be a scalar');
    end
    
    if TOW < 0 || TOW >= 604800
        error('towtoweekday: TOW bust be an integer between 0 and 604800');
    end

    if TOW < 86400,      wkd = 0; 
    elseif TOW < 172800, wkd = 1;
    elseif TOW < 259200, wkd = 2;
    elseif TOW < 345600, wkd = 3;
    elseif TOW < 432000, wkd = 4;
    elseif TOW < 518400, wkd = 5;
    else                 wkd = 6;
    end;
    
end
