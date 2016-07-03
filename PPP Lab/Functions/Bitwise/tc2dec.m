function dec = tc2dec( tc, bits, varargin )
%DEC2TC converts two complement representation to a decimal value
%   The function receives a number in two complement representation and
%   converts it to the respective decimal value.
%
%   For example, 
%       TC = 255 with BITS = 8 results in DEC = -1
%       TC = 255 with BITS = 16 results in DEC = 255
%
%   INPUT
%   TC   - Two complement representation in decimal number
%   BITS - Accepts any number of bits
%   VARARGIN - Modifier for lut size
%
%   OUTPUT
%   DEC  - The converted value of TC
%
% Pedro Silva, Instituto Superior Tecnico, January 2011

    % Due to bitget limitation of 52 
    if bits <= 52
        b = bitget(tc, 1:bits); % get bit representation from lsb to msb
    else
        b = dec2bin(tc,bits);   % gets string representation
        b = b(end:-1:1);        % reverse the order
        b = b=='1';             % converts string to decimal
        if length(b) > bits
            bits = length(b);
        end
    end

    % if already positive then job is done
    if b(end) == 0
        dec = tc;

    % Need to convert it
    else
        
        % Create lut
        k   = 0:bits;
        lut = 2.^k;
        
        % until the first 1 is reached
        k=1;
        while ~b(k)
           k=k+1;
        end 
        
        % Flip the other ones
        b(k+1:end) = ~b(k+1:end);
        
        % Converts to the decimal value
        dec = -1 * sum(b .* lut(1:bits));
    end


end

