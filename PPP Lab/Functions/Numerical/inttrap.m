function value = inttrap(f,dt)
%INTTRAP computes the trapezoid integration
%
%   The function has 2 inputs, f is the data vector which will be used as A
%   and B on equation 1. dt is the data rate, that is, the time spacing
%   between each observation. Default is one.
%
%   Equation 1.
%       A + B
%       ----- * dt
%         2
%
%   Pedro Silva, Instituto Superior Técnico, June 2012

    if nargin == 1
        dt = 1;
    end
    
    [~,n] = size(f);
    assert(n==2);
    
    value = dt.*(f(:,1)+f(:,2))./2;

end
