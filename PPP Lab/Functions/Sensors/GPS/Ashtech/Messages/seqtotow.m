function tow = seqtotow( seq, UTCoffset, varargin)
%SEQTOTOW converts magellan SEQ to TOW
% Attention! This will not work for offline conversion! unless a reference
% time is given
% This function converts the SEQ number which is a 30 minute counter that
% starts every hour/hour and half. Thus, if the next half hour is not
% reached the function uses the actual hour to compute the initial tow
% adding the offset provided by the receiver
%
% The function only needs a seq number to work and assumes that the user is
% operating under UTC time. A time offset can be provided as a second
% argument, which should indicate the hour offset to UTC. For a user that
% is using UTC-4 clocks the function should be called as
%
%       seqnumber = 29860
%       tow       = seqtotow(29860,-4) 
%
% A user running in GMT+0 can also suffer daylight adjustments in the
% summer, thus changing to GMT+1. The function then needs to be called as
%
%       seqnumber = 29860
%       tow       = seqtotow(29860,1)
%
% In offline operation a reference time can be provided as follows
%       
%       % Operating in GMT+1
%       seqnumber = 29860
%       refhour   = 14
%       refmin    = 21
%       tow       = seqtotow(29860,1,14,21)
%
% INPUT
%   SEQ - Sequence number in units of 50ms modulo 30 min
%   DAYLIGHTSAVING - An hour offset to UTC time
%   HOUR - Reference hour for offline processing
%   MIN  - Reference minutes for offline processing
%
% OUTPUT
%   TOW - Time of week in seconds
% 
% Pedro Silva, Instituto Superior Tecnico, January 2012
    
    % For online operation
    if nargin == 3
        clk    = clock();
        hour   = clk(4);
        min    = clk(5);
        wd     = varargin{1}; 
    
    elseif nargin == 2
        clk    = clock();
        hour   = clk(4);
        min    = clk(5);
        wd     = weekday(datenum(date))-1; 
        
    % For offline operation
    elseif nargin == 5
        hour   = varargin{1};
        min    = varargin{2};
        wd     = varargin{3}; 

    % neither
    else
        error('seqtotow: insufficient arguments');
    end
    
    
    if min < 30
        tow = getweeksec(wd,hour-UTCoffset) + seq*50e-03;
    else
        tow = getweeksec(wd,hour-UTCoffset,30) + seq*50e-03;
    end

end

