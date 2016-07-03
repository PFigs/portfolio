function exception = ppplabexceptions(name)
%PPPLABEXCEPTIONS stores the exceptions to throw during PPPLab execution
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012

    persistent exc404;
    persistent excSample;
    persistent openfailure;
    persistent exceptioneof;
    
    % Create exceptions
    if isempty(exc404)
        exc404      = MException('PPPLab:precisepos', ...
                    'Failed to pull file, defaulting to broacast information');
        excSample   = MException('PPPLab:precisepos', ...
                    'Resample data');
        openfailure = MException('PPPLAB:ReportGenerator', ...
                    'Failed to open file');
        exceptioneof = MException('PPPLab:readbinfile', ...
        'No more information is left to read on the file');
    end
    
    
    % Switch exception to throw
    if strcmpi(name,'404')
        exception = exc404;
        
    elseif strcmpi(name,'resample')
        exception = excSample;
        
    elseif strcmpi(name,'openfile')
        exception = openfailure;
        
    elseif strcmpi(name,'binfilend')
        exception = exceptioneof;
    else
        error('unknown exception');
    end


end