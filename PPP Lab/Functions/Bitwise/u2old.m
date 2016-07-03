function short = u2old( addr, varargin )
%U2 merges bytes into an unsigned short using little endian or big endian
%notation
%   The function can interpret the input as little or big endian. Little
%   endian is the default and can be changed by stating in the input which
%   mode shall be used.
%
%   NOTE:
%   a and b are the two bytes read in little endian notation, that means 
%        addr(a) < addr(b)
%
%   INPUT
%   ADDR - Bytes for merging
%   VARARGIN - Operation mode: Default little endian
%
%   OUTPUT
%   SHORT - 16 bit unsigned short
%
% Pedro Silva, Instituto Superior Tecnico, Julho 2011
% Last revision: January 2012

    % Checks if big or little endian notation
    if nargin == 2 && strcmpi(varargin(1),'bigendian')
        addr = addr(end:-1:1);
    end
    short  = bitor( bitshift(addr(2),8), addr(1) );  
%     short = uint8(addr);
%     short = typecast(short,'uint16');
    
end

    % Joins the bytes
%     short   = bitor( bitshift(addr(2),8), addr(1) );  