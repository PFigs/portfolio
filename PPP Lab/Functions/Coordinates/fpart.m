function [ i, f ] = fpart( frac )
%FPART returns the fractional and integer part of a number
% 
% Pedro Silva, Instituto Superior Tecnico, Maio 2011
    
    if ceil(frac)-frac < 1e-06
        frac = ceil(frac);
    end
    
    i = fix(frac);
    f = frac - i;

end

