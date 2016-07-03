function data = rinextodata( filepath, data )
%RINEXTODATA parses a RINEX file to the used data structures
%   Several versions of RINEX can and should be supported but this code
%   was developed for version 2.11.
%   
%   INPUT
%   FILEPATH - RINEX filepath
%   TYPE     - O:observation, N:navigation, ... (can also be checked by
%              file extension)
%   VERSION  - RINEX file version
%
%   OUTPUT
%   DATA     - Structure with the parsed information
%
%   Pedro Silva, Instituto Superior Técnico, June 2012

    % Open file and read file
    fid = fopen(filepath);
    if fid == -1
       error(['readigs: file not found: ' sprintf('%s',filepath)]); 
    end
    file  = textscan(fid,'%s','Delimiter','\n','whitespace','');
    fclose(fid);
    file  = file{1};
    fSize = size(file,1);

    % Search for header end
    count = 0;
    for k=1:fSize
        count = count+1;
        
        idx = strfind(file{k},'RINEX VERSION / TYPE');
        if ~isempty(idx)
            info  = regexp(file{k}(1:idx-1),'\s*','split');
            info(1) = [];
            version = str2double(info{1});
            type    = info{2}(1);
        end
        
        idx = strfind(file{k},'# / TYPES OF OBSERV');
        if ~isempty(idx)
            obs  = regexp(file{k}(1:idx-1),'\s*','split');
            obs(1) = [];
            nObs = str2double(obs{1});
            obs(1) = [];
        end
        
        idx = strfind(file{k},'APPROX POSITION XYZ');
        if ~isempty(idx)
            info     = regexp(file{k}(1:idx-1),'\s*','split');
            info(1)  = [];
            refpoint = zeros(1,3);
            refpoint(1,1) = str2double(info{1});
            refpoint(1,2) = str2double(info{2});
            refpoint(1,3) = str2double(info{3});
            data.refpoint = refpoint;
        end
        
        idx = strfind(file{k},'END OF HEADER');
        if ~isempty(idx)            
            break;
        end
    end
    
    % SWITCH FILE TYPE
    if strcmpi(type,'O') % OBTAIN OBSERVATION
        data = parserinexobservation(file,k,fSize,data, obs, nObs);
        fprintf('finished parsing observation file\n');
    elseif strcmpi(type,'N') % OBTAIN NAVIGATION
        data = parserinexnavigation(file,k,fSize,data,version);
        fprintf('finished parsing observation file\n');
    end

end


