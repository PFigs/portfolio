function [ num ] = r4( addr, varargin )
%R4 merges bytes into a double precision format
%   a, b, c and d the four bytes read in
%   little endian notation, that means 
%        addr(a) < addr(b) < addr(c) < addr(d)
%
%   NOTE:
%   Verification tool: http://www.h-schmidt.net/FloatApplet/IEEE754.html
%
%   INPUT
%   ADDR - Bytes for merging
%   VARARGIN - Operation mode: Default little endian
%
%   OUTPUT
%   NUM - 32 bit float IEEE754 number
%
% Pedro Silva, Instituto Superior Tecnico, Julho 2011
% Last revision: January 2012

    % Checks if big or little endian notation
    if nargin == 2 && strcmpi(varargin(1),'bigendian')
        addr = addr(end:-1:1);
    end
    
    % Joins the bytes and converts them
    num = double(typecast(addr,'single'));
   
end
