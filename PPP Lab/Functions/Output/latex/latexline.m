function latexline(fid,str,varargin)
%LATEXLINE writes str as newline to file pointed by fid
%   The functions parses the string for '\' and escapes them
%
%   TODO: Escape the other chars
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012
    
    % Parses '\' and escapes it
    str = latexcheckstring(str);
    
    %TODO other characters
    if nargin > 2 && strcmpi(varargin{1},'double')
        spacing = '\r\n\r\n';
        varargin(1) = [];
    else
        spacing = '\r\n';
    end
    fprintf(fid,[str,spacing],varargin{:});
end
