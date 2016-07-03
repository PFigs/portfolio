function [ seconds ] = getweeksec( wd, varargin )
%GETWEEKSEC calculates the number of seconds since the beggining of the
%week until the given time
%   Weekday - with Sunday being 0 and Saturday being 6
%   h,m,s   - hours, minutes and seconds of the partial day
%
%   Pedro Silva, Instituto Superior Tecnico, October 2011   
%   Last revision: Jauary 2012

    if nargin == 1
        h = 0; m = 0; s = 0;
    elseif nargin == 2
        h = varargin{1};
        m = 0; s = 0;
    elseif nargin == 3
        h = varargin{1};
        m = varargin{2};
        s = 0;
    elseif nargin == 4
        h = varargin{1};
        m = varargin{2};
        s = varargin{3};
    end
    seconds = wd*24*60*60 + h*60*60 + m*60 + s;
end

