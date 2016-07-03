function [ data ] = readigs( filepath, WD )
%READSP3C reads an sp3 formated file
%   This functions allows the user to obtain a structure with the position
%   and clock report of an sp3 file for a given time range.
%   A struct is returned with the corresponding epochs for every satellite  
%
%   Note that some fields are ignored
%
%   parsed_file = readigs( filepath, WD )
%
% Pedro Silva, Instituto Superior Tecnico, December 2011
% Last Revision: March 2012
    
    %fprintf('Reading file %s\n',filepath);
    
    % Open file and read file
    fid = fopen(filepath);
    if fid == -1
       error(['readigs: file not found: ' sprintf('%s',filepath)]); 
    end
    file  = textscan(fid,'%s','delimiter',sprintf('\n'));
    fclose(fid);
    fSize = size(file{1},1);
    
    % Read line 1
    % #cP2011 12 14  0  0  0.00000000      96 ORBIT IGS08 HLM  IGS
    [parsed,count] = sscanf(file{1}{1},'#%c%c%d  %d %d %d %d %f %d %s\n');
    if count == 0
        error('No data read from igs sp3 file');
    end
    nbepochs = parsed(9);

%     Read line 2
%     ## 1666 259200.00000000   900.00000000 55909 0.0000000000000
    [parsed,count] = sscanf(file{1}{2},'## %d  %f %f %d %f\n');
    if count == 0
        error('No data read from igs sp3 file');
    end
    secweek  = parsed(2);  % Starting tow
    epochint = parsed(3); % Epoch interval

%     % Sanity check
%     if range(1) < secweek
%         error('readigs: Range not valid');
%     end
%     
%     if range(2) > secweek + nbepochs*epochint
%         error('readigs: Range too big');
%     end
    
    % Read lines 3 to 7 - Sat id
    % Read lines 8 to 12 - Accuracy
    % Read lines 13 to 14 - Constants %c
    
    % Read lines 15 to 16 - Constants %f
    % f  1.2500000  1.025000000  0.00000000000  0.000000000000000
    [parsed,count] = sscanf(file{1}{15},'%%f %f %f %f %f %f\n');
    if count == 0
        error('No data read from igs sp3 file');
    end 
    bPos = parsed(1);
    bClk = parsed(2);
    
    % Read lines 17 to 18 - Constants %i
    % Read lines 19 to 22 - Comment lines

    % Init struct
    iEpoch   = 0;
    st(1:32) = struct('epoch',ones(nbepochs,8));
    data     = struct('TOW', zeros(nbepochs,1),...
                      'IDX', NaN,...
                      'sat', st);
    for l = 23:fSize
        % New record 
        % *  2011 12 14  0  0  0.00000000
        if file{1}{l}(1) == '*'
            iEpoch = iEpoch + 1;
            [parsed,count] = sscanf(file{1}{l},'* %d %d %d %d %d %f\n');
            if count == 0
                error('No data read from igs sp3 file');
            end
            data.TOW(iEpoch) = secweek+(iEpoch-1)*epochint; %time in seconds

        % Position record 
        % PG01 -13351.260103  17201.802142  15184.322787    140.656800  9  8 10 135  
        elseif file{1}{l}(1) == 'P'
            [parsed,count] = sscanf(file{1}{l},'P%c%d %e %e %e %e %d %d %d %d\n');
            if count == 0
                error('No data read from igs sp3 file');
            end            
            id                              =  parsed(2); %satid    
            data.sat(id).epoch(iEpoch,1)    =  parsed(3)*1e03; % x - km
            data.sat(id).epoch(iEpoch,2)    =  parsed(4)*1e03; % y - km
            data.sat(id).epoch(iEpoch,3)    =  parsed(5)*1e03; % z - km
            data.sat(id).epoch(iEpoch,4)    =  parsed(6)*1e-6; % clk - mili
            if data.sat(id).epoch(iEpoch,4) == 0
               data.sat(id).epoch(iEpoch,4) =  999999.999999;
            end
            if count == 10
               data.sat(id).epoch(iEpoch,5) =  bPos^parsed(7)*1e-3; % dx
               data.sat(id).epoch(iEpoch,6) =  bPos^parsed(8)*1e-3; % dy
               data.sat(id).epoch(iEpoch,7) =  bPos^parsed(9)*1e-3; % dz   % atencao caso esteja VAZIO!
               data.sat(id).epoch(iEpoch,8) =  bClk^parsed(10)*1e-12;% dz  % atencao caso esteja VAZIO!
            end
        end
    end;
end

