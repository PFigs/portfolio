function str = latexcheckstring( str )
%LATEXCHECKSTRING escapes special chaaracters in the strings to write to
%the latex files in order to avoid corruption of the printf function
%
%   OBJECTIVE
%   The function makes sure that no ilegal characters are left to escape by
%   the user. This means that the user can write under MATLAB normal latex
%   commands, as they will be correct.
%
%   CHARACTERS ESCAPED
%   \ - backslash
%
%   TODO: Add more characters
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012
    
    numvec    = 1:length(str);
    backslash = str =='\';
    backslash = numvec(backslash);
    offset    = 0;
    for each  = backslash
       str    = [str(1:each+offset),str(each+offset:end)];
       offset = offset + 1;
    end

end

