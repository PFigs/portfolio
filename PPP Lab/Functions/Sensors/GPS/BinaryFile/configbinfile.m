function sFile = configbinfile( inputpath, varargin)
%CONFIGBINFILE opens and reads to memory the binary file
%   The function returns a struct with the file's contents as well as some
%   other usefull information such as the current reading position, size of
%   the file, and so on.
%   
%   INPUT
%   INPUTPATH - Contains the path to the binary file
%   VARARGIN  - Modifiers for default values
%
%   OUTPUT
%   BINFILE - Returns the binary file
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    
    fid = fopen(inputpath);
    if fid == -1
        error('configbinfile: failed to open file');
    end
    binfile = fread(fid);
    
    sFile = struct(...
                   'content',binfile,...
                   'depth',max(size(binfile)),...
                   'position',1, ...
                   'eof',0 ...
                   );
    
    fclose(fid);
    
    
    
end
