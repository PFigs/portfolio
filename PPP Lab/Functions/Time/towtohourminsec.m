function [ hour, minute, second ] = towtohourminsec( TOW )
%TOWTOHOURMINSEC converts TOW to hour, minute and second
%
% INPUT
%   TOW - Time of Week
%
% OUTPUT
%   Hour, minute, second
%
% Pedro Silva, Instituto Superior Tecnico, Janeiro 2012

    WD  = towtoweekday(TOW);
    BOD = WD*24*60*60; % beggining of day
    
    hour            = (TOW-BOD)/3600;
    [hour,minute]   = fpart(hour);
    minute          = minute*60;
    [minute,second] = fpart(minute);
    second          = round(second*60);
    
end

