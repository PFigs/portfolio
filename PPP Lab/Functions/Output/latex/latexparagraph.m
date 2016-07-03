function latexparagraph(fid,str,varargin)
%LATEXPARAGRAPH writes str as a paragraph to file pointed by fid
%   The functions parses the string for '\' and escapes them
%
%   TODO: Escape the other chars
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012

    % Parses '\' and escapes it
    str = latexcheckstring(str); 
    
    fprintf(fid,[str,'\\\\\r\n'],varargin{:});
    
end