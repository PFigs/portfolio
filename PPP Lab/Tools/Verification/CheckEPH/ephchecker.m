%READEPH obtains data from the files in the given PATH
%   The data is saved in a 31 by M matrix, being 31 the number of arguments
%   present in the ephemerides message. Note that more that can be saved
%   upon the 31st parameter and file reading can be further expanded to
%   save this information.
%
%   Below is the index <-> param translation made within this function.
%   The order used is the same used by Prof. José Sanguino in his GPS Basic
%   Exercises from Navigation Systems.
%
%   (1)   - SVID                         (17)  - MEAN ANOMALY (Mo)
%   (2)   - WEEK NUMBER                  (18)  - ECCENTRICITY (e)
%   (3)   - CODE ON L2                   (19)  - SQRT OF THE SEMI-MAJOR AXIS (sqrt(A))
%   (4)   - URA                          (20)  - MEAN MOTION (delta N)
%   (5)   - HEALTH                       (21)  - LONGITUDE OF ASCENDING NODE (Omega0)
%   (6)   - IODC                         (22)  - INCLINATION ANGLE (i0)
%   (7)   - L2P                          (23)  - ARGUMENT OF PERIGEE
%   (8)   - TGD                          (24)  - RATE OF ASCENCION (OmegaDot)
%   (9)   - TOC                          (25)  - RATE OF INCLINATION ANGLE (IDOT)
%   (10)  - AF2                          (26)  - CRC 
%   (11)  - AF1                          (27)  - CRS
%   (12)  - AF0                          (28)  - CUC
%   (13)  - IODE SF2                     (29)  - CUS
%   (14)  - IODE SF3                     (30)  - CIC
%   (15)  - TIME OF EPHEMERIDES (TOE)    (31)  - CIS
%   (16)  - FIT INTERVAL FLAG
%
%
%   INPUT
%     PATH - Directory with observation files
%
%   OUTPUT
%     FADATA - Data retrieved from the files (31 by M matrix)
%              Each collumn represents a satellite and each row is a
%              message parameter
%
%              Example:
%                   Collumn  - | SATID1 | SATID2 |
%                   Line #1  - | SVID   | SVID   |
%                      ...
%                   Line #31 - | CIS    | CIS    |
%                           
%   Pedro Silva, Instituto Superior Técnico, Novembro 2011
clc
clear
format long g
    path = '.';
    ftag = 'checkfile';
    stag = length(ftag);
    
    % readeph
    if ~exist(path,'dir')
        error('readcustomfile:readeph: EPHEMERIDES missing!');
    end
    
    % Retrieve filenames
    list   = dir(path);  % LS implementation differs from UNIX to WIN
    ilist  = size(list,1);
    nFiles = 0;
    
    % Count number of files
    while ilist
       if size(list(ilist).name,2) >= stag 
           if strcmp(list(ilist).name(1:stag),ftag)
               nFiles = nFiles + 1;
           end
       else
           list(ilist)=[];
       end
       ilist = ilist - 1;
    end
    
    % Sanity check
    if nFiles == 0
        error('readcustomfile:readeph: Please move files into folder');
    end
    
    % Fill structure
    ArgsNo = 31;
    SatNo  = nFiles; % Number of satellites
    fdata  = struct('filename',[],'eph',zeros(ArgsNo,SatNo));
    for iFile=1:nFiles
       fdata.filename  = list(iFile).name;
       values          = load(fdata.filename)'; % Transpose data
       fdata.eph(:,iFile)  = values(1:ArgsNo,end); % Store data in the matrix
    end
    
    value = zeros(nFiles,1);
    for field=1:ArgsNo        
        if length(unique(fdata.eph(field,:)))== 1
            fprintf('Match in : %8s\t value: %d\n',idxtoephfield(field),fdata.eph(field,1));
        else
            fprintf('!Mismatch in : %8s\n',idxtoephfield(field));
            for k=1:nFiles
               fprintf('\tFile: %20s has value: %d\n',fdata.filename,fdata.eph(field,k));
            end
        end

    end
    
    
