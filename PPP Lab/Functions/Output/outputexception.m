function outputexception( exception )
%OUTPUTEXCEPTION Summary printouts the exception details
%
%   Output format
%   @ line : file - name : message
%
% Pedro Silva, Instituto Superior Tecnico, May 2012

    disp(['@ ',sprintf('%d',exception.stack(1).line),...
         ' : ',exception.stack(1).file]);
     
    fprintf('\t%s\n\n',exception.message);
end

