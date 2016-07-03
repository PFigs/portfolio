function [ num ] = r8( addr, varargin )
%R8 merges bytes into a double precision format
%   a, b ... h the eight bytes read in
%   little endian notation, that means 
%        addr(a) < addr(b) < addr(c) < addr(d)
%
%  Verification tool: http://www.h-schmidt.net/FloatApplet/IEEE754.html
%  Verification tool: http://www.binaryconvert.com/result_double.html?hexadecimal=00107056507DC108
%
%   INPUT
%   ADDR - Bytes for merging
%   VARARGIN - Operation mode: Default little endian
%
%   OUTPUT
%   Long - 32 bit unsigned short
%
% Pedro Silva, Instituto Superior Tecnico, Julho 2011
% Last revision: May 2012
    
    % Checks if big or little endian notation
    if nargin == 2 && strcmpi(varargin(1),'bigendian')
        addr = addr(end:-1:1);
    end
    
    num = double(typecast(addr,'double'));
    
end