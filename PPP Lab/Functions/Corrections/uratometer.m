function [ mura ] = uratometer( vec )
%URATOMETER translates URA information into meters
%   URA information can be found on page 93 of the IS-GPS200F
%
%   The computations are done using 2^(1+N/2) for N less than 7 and 2^(N-2)
%   for N bigger or equal to 7
%
%   Pedro Silva, Instituto Superior Tecnico, July 2011
%   Last revision: May 2012

    % Check input
    [k,l] = size(vec);
    if k > 1
        error('uratometer: VEC must be a row');
    end

    uramapper = [...
                 2;...
                 2.828427124746190;...
                 4;...
                 5.656854249492380;...
                 8;...
                 11.31370849898476;...
                 16;32;64;128;256;1024;4096;inf];
    
    inputsz = l;
    mura    = vec;
    counter = 0;
    i       = 0;
    
    while counter < inputsz
        index = vec == i;
        i = i + 1;
        if any(index)
            if i > 14, i = 14; disp('URA:uratometer:something went wrong');end;
            mura(index) = uramapper(i);
            counter = counter + sum(index);
        end
    end
end

