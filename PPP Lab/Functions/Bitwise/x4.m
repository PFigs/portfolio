function [ bitfield ] = x4( addr, varargin )
%X4 returns a vector with the corresponding bitfield for the input
%   The function can interpret the input as little or big endian. Little
%   endian is the default and can be changed by stating in the input which
%   mode shall be used.
%
%   NOTE:
%   a, b, c and d are the four bytes read in little endian notation
%        addr(a) < addr(b) < addr(c) < addr(d)
%
%   INPUT
%   ADDR - Bytes for merging
%   VARARGIN - Operation mode: Default little endian
%
%   OUTPUT
%   Long - 32 bit unsigned short
%
% Pedro Silva, Instituto Superior Tecnico, Julho 2011
% Last revision: January 2012

    % Checks if big or little endian notation
    if nargin == 2 && strcmpi(varargin(1),'bigendian')
        addr = addr(end:-1:1);
    end
    
    % Converts input to vector
    addr     = dec2bin(addr,8);
    bitfield = [addr(4,:) addr(3,:) addr(2,:) addr(1,:)];
    bitfield = (bitfield=='1');

end
