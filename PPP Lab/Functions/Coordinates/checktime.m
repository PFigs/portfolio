function dt = checktime(dt)
%CHECKTIME checks if time needs compensation for half a week
%   
%   INPUT
%   DT - Vector of time to check
%
%   OUTPUT
%   DT - Vector with time corrected
%
% Pedro Silva, Instituto Superior Tecnico, Setembro 2011
    
    % Checks conditions
    bigger  = dt >  302400;
    smaller = dt < -302400;

    % Corrects values
    if any(bigger);
        dt(bigger) = dt(bigger) - 604800;
    elseif any(smaller)
        dt(smaller) = dt(smaller) + 604800;
    end
end