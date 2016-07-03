function [ varargout ] = readcustomfile( varargin )
%READCUSTOMFILE reads a custom file obtained for offline processing.
%   
% FUNCTION ARGUMENTS
%   The function has variable INPUTS and OUTPUTS with default values
%   associated to the INPUT directory. The variable INPUT allows the
%   function to switch de default path for data retrieval 'rcvdata/'.
%
%   INPUT
%     VARARGIN: DIRECTORY - Path were to look for files
%
%   OUTPUT
%     VARARGOUT - Data matrices with the information found (not synced for
%                 epochs with less than 4 satellites)
%
%       MES DATA - The measurement data is translated to an EPOCH structure  
%                  which contains 4 (nEpoch-by-32) matrixes and a vector
%                  with nEpoch. Each matrix contains data from pseudoranges
%                  or carrier phase and each collumn represent a satellite
%                  and each line a different TOW. The actual TOW is saved
%                  in the vector present at the structure.
%
%              Example:
%                       EPOCH +-- TOW (Vector with nEpoch elements)
%                             |- PRL1 (nEpoch by 5 matrix)
%                             |- CPL1 (nEpoch by 5 matrix)
%                             |- PRL2 (nEpoch by 5 matrix)
%                             |- CPL2 (nEpoch by 5 matrix)
%
% FUNCTION INPUT FILES
%   There are several files this function can read, measurement
%   information (pseudorange and carrier phase), ephemerides data,
%   ionosphere and doppler data.
%   
%   MEASUREMENTS
%       This file must be named as DD-MMM-YYYYpseudorangesNN where D, M, Y
%       are the default DATE from MATLAB, eg. 03-Nov-2011pseudoranges14.
%       Each file contains several observations from a single satellite and
%       the initial Time Of Week (TOW) may be different from file to file.
%       The observations MUST be written in collumns from 1 to 5 where 1 and
%       2 contains the L1 pseudo and carrier phase ranges, 3 and 4 the L2
%       pseudo and carrier phase ranges and 5 must contain the TOW.
%
%       Example:
%            Collumn    |   1   |   2   |   3   |   4   |  5  |
%            Line #1    | PR L1 | CP L1 | PR L2 | CP L1 | TOW |
%              ...
%            Line #N    | PR L1 | CP L1 | PR L2 | CP L1 | TOW |
%
%                                      Filename: 03-Nov-2011pseudoranges14
%
%   EPHEMERIDES
%       This file must use the format specified by Prof. José Sanguino in
%       his basic GPS exercises from Navigation Systems. The data is parsed
%       to a struct with size EPHARGS x NSAT, in order to ease access to it 
%       and avoid redudant copies of data.
%
%       Reference: 
%           Sanguino, J., Navigation Systems - Exercises 2010-2011.
%
%   IONOSPHERE
%       If the information is available the ionosphere parameters alpha and
%       beta must be displayed in collumns just as the measurements files.
%       It is expected that alpha parameters occupy the first collumns and
%       beta parameters the later ones.
%
%       %TODO: better definition of the input file and reading TOW        
%
%   DOPPLER
%       Part of the ranges file
%
%   Pedro Silva, Instituto Superior Técnico, Novembro 2011

    % Check input
    error(nargchk(0, 1, nargin)) % future usage: error(narginchk(3, 3));
    
    if nargin
        if ~ischar(varargin{1})
            error('readcustomfile: Input must be a string');
        else
            directory = varargin{1};
        end
        if ~exist(directory,'dir')
            error('readcustomfile: DIRECTORY must point to an existing location');
        end
    else
        directory = 'rcvdata/'; % Default data path
        if ~exist(directory,'dir')
            error('readcustomfile: Default path does not exist');
        end
    end
    
    persistent epoch;   % Sets epoch as persistent because of its size
    persistent ephdata; % Sets eph as persistent because of its size
    
    if ~exist([directory,'data_mes.mat'],'file')
    
    
    % Obtain data from files
    [mesdata,satlist,rTOW,fdate,datarate] = readmes(strcat(directory,'mes/'));  % READ FILES
    [ephdata,alleph]                      = readeph(strcat(directory,'eph/'));  % READ EPHEMERIDES
    ionodata                              = readion(strcat(directory,'ion/')); % READ IONO;
        
    % Parameter initialization
    nSat     = numel(satlist);
    myEpoch  = ones(nSat,1);
    mySize   = ones(nSat,1);
    iEpoch   = 1;
    minTOW   = rTOW(1);
    maxTOW   = rTOW(2);
    for k=1:nSat, 
        mySize(k) = size(mesdata(k).pseudo,1); 
    end;
    nEpoch   = maxTOW - minTOW + 1;
    itow     = minTOW;
    % Struct and Waitar initializations
    epoch    = rfilestructs('binranges',nEpoch);  % reads struct declaration
    namestr  = ['Loading file with' ' ' sprintf('%d',nEpoch) ' ' 'epochs'];
    wbhandle = waitbar(0,'1','Name',namestr);
    while iEpoch <= nEpoch
        for iSat = 1:nSat   % For each satellite
            hasEnoughData = mySize(iSat) >= myEpoch(iSat); % Is it possible to have data
%             hasDataForTOW = mesdata(iSat).pseudo(myEpoch(iSat),5) == itow;  % Has data at current TOW?
            if  hasEnoughData && mesdata(iSat).pseudo(myEpoch(iSat),5) == itow
                svid                    = mesdata(iSat).satid;
                epoch.PRL1(iEpoch,svid) = mesdata(iSat).pseudo(myEpoch(iSat),1); % Pseudo L1
                epoch.CPL1(iEpoch,svid) = mesdata(iSat).pseudo(myEpoch(iSat),2); % Phase  L1
                epoch.PRL2(iEpoch,svid) = mesdata(iSat).pseudo(myEpoch(iSat),3); % Pseudo L2
                epoch.CPL2(iEpoch,svid) = mesdata(iSat).pseudo(myEpoch(iSat),4); % Phase  L2  
                try 
                    epoch.DOL1(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),6); % Doppler L1
                    epoch.SNRL1(iEpoch,svid) = mesdata(iSat).pseudo(myEpoch(iSat),7); % SNRL L1
%                     epoch.DOL1(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),8); % Doppler L1
%                     epoch.DOL2(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),9); % Doppler L2
%                     epoch.SNRL1(iEpoch,svid) = mesdata(iSat).pseudo(myEpoch(iSat),10); % SNRL L1
%                     epoch.SNRL2(iEpoch,svid) = mesdata(iSat).pseudo(myEpoch(iSat),11); % SNRL L2
%                     epoch.PRCA(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),16); % Pseudo  CA
%                     epoch.CPCA(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),17); % Pseudo  CA
%                     epoch.SNRCA(iEpoch,svid) = mesdata(iSat).pseudo(myEpoch(iSat),18); % SNRL L1
%                     epoch.DOCA(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),19); % SNRL L1
%                     epoch.SML1(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),14); % Smooth values
%                     epoch.SML2(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),15); % Smooth values
%                     epoch.SMCA(iEpoch,svid)  = mesdata(iSat).pseudo(myEpoch(iSat),22); % Smooth values
                end
%                 try
%                     %convert magnitude PL1
%                     if epoch.PRL1(iEpoch,svid)
%                     magnitude = bitand(epoch.SML1(iEpoch,svid),2^22-1);
%                     sign      = bitget(epoch.SML1(iEpoch,svid),23);
%                     if sign ~= 0, sign = -1; else sign = 1; end;
%                     epoch.PRL1(iEpoch,svid) = epoch.PRL1(iEpoch,svid);% - (sign)*magnitude*1e-02;
%                     end
%                 end
%                 try
%                     %convert magnitude
%                     if epoch.PRL2(iEpoch,svid)
%                     magnitude = bitand(epoch.SML2(iEpoch,svid),2^22-1);
%                     sign      = bitget(epoch.SML2(iEpoch,svid),23);
%                     if sign ~= 0, sign = -1; else sign = 1; end;
%                     epoch.PRL2(iEpoch,svid) = epoch.PRL2(iEpoch,svid);% - (sign)*magnitude*1e-02;
%                     end
%                 end
%                 try
%                     %convert magnitude
%                     if epoch.PRCA(iEpoch,svid)
%                     magnitude = bitand(epoch.SMCA(iEpoch,svid),2^22-1);
%                     sign      = bitget(epoch.SMCA(iEpoch,svid),23);
%                     if sign ~= 0, sign = -1; else sign = 1; end;
%                     epoch.PRCA(iEpoch,svid) = epoch.PRCA(iEpoch,svid);% - (sign)*magnitude*1e-02;
%                     end
%                 end
                % DOPPLER WILL BE HERE
                myEpoch(iSat) = myEpoch(iSat) + 1; % Can proceed to next data item
            end
        end
        epoch.TOW(iEpoch) = itow;       % Marks epoch entry
        iEpoch            = iEpoch + 1; % Jumps to next data epoch
        itow              = itow + datarate;   % Jumps to next epoch
        waitbar(iEpoch/nEpoch,wbhandle,sprintf('%.0f%%',iEpoch/nEpoch*100));
    end
    close(wbhandle)
    drawnow
    save([directory,'data_mes.mat'],'epoch');
    save([directory,'data_eph.mat'],'ephdata');
    save([directory,'data_ion.mat'],'ionodata');
    save([directory,'data_nep.mat'],'nEpoch');
    save([directory,'data_sat.mat'],'satlist');
    save([directory,'data_date.mat'],'fdate');
    save([directory,'data_alleph.mat'],'alleph');
    else
        disp('Loading parsed data...')
        load([directory,'data_mes.mat']);
        load([directory,'data_eph.mat']);
        load([directory,'data_ion.mat']);
        load([directory,'data_nep.mat']);
        load([directory,'data_sat.mat']);
        load([directory,'data_date.mat']);
        load([directory,'data_alleph.mat']);
    end
    % OUTUP VALIDATION
    varargout{1} = epoch;
    varargout{2} = ephdata;
    varargout{3} = nEpoch;
    varargout{4} = ionodata;
    varargout{5} = satlist;
    varargout{6} = fdate;
    varargout{7} = alleph;
end


function [fdata, satlist, rTOW, fdate, rate] = readmes( path, varargin )
%READMES obtains data from the files in the given PATH
%   The data is synced to a common TOW where there measurements for at
%   least 4 satellites. This means that for any epoch one can obtain a
%   position, although caution is advice and it is recommended to evaluate
%   which time each structure index refers to, as some files can begin in a
%   later TOW.
%   For example, for 10 files, 1 starts at TOW = 100, 5 at TOW
%   200 and the others at TOW = 400. The minimun TOW with 4 satellites is 
%   TOW = 200 which will shift the data from the first file to TOW = 200 
%   while the data for the others will stay the same.
%
%   INPUT
%     PATH - Directory with observation files
%
%   OUTPUT
%     FADATA - Data retrieved from the files
%              The data is an array of structs each containing the satid
%              and the measurements read from the file.
%
%              Example:
%                       FDATA(1) +-- SATID  (decimal)
%                                 |- PSEUDO (M by 5 matrix)
%
%     SATLIST - List of satids
%     rTOW    - Collumn vector with TOW range [minTOW; maxTOW]
%                           
% Pedro Silva, Instituto Superior Tecnico, November 2011

    if ~exist( path,'dir')
        error('readcustomfile:readmes: path to MEASUREMENTS missing');
    end
    
    % Retrieve filenames
    list   = dir(path);  % LS implementation differs from UNIX to WIN
    ilist  = size(list,1);
    nFiles = 0;
    
    % Count number of files
    while ilist
       if size(list(ilist).name,2) >= 25 
           if strfind(list(ilist).name,'pseudoranges')
               nFiles = nFiles + 1;
           end
       else
           list(ilist)=[];
       end
       ilist = ilist - 1;
    end
    
    % Sanity check
    if nFiles < 4
        error('readcustomfile:readmes: Too few measurements files. Need at least 4.');
    end
    
    % Fill structure
    fdata(1:nFiles) = struct('satid',NaN,'pseudo',NaN);
    satlist         = zeros(nFiles,1);
    tmalign         = zeros(nFiles,1);
    tmlast          = zeros(nFiles,1);
    for iFile=1:nFiles
       filename            = strcat(path,list(iFile).name);
%        satid               = str2double(list(iFile).name(22:23));
       satid               = str2double(list(iFile).name(24:25));
       fdata(iFile).pseudo = load(filename);
       fdata(iFile).satid  = satid;
       tmalign(iFile,1)    = fdata(iFile).pseudo(1,5);
       tmlast(iFile,1)     = fdata(iFile).pseudo(end,5); 
       satlist(iFile,1)    = satid;
    end
    
    % Evaluates the minimum TOW for which there are at least 4 sats
    minlist = unique(sort(tmalign));
    for k = minlist'
        if sum(tmalign <= k) >= 4
            minTOW = ceil(k);
            break; 
        end
    end
    
    % Sets a starting time for the files
    for iFile = 1:nFiles 
       fdata(iFile).pseudo(fdata(iFile).pseudo(:,5)<minTOW,:)=[];
    end
    
    % Evaluates the maximum TOW
    maxlist = unique(sort(tmlast));
    maxTOW  = fix(maxlist(end));
    
    rTOW    = [minTOW; maxTOW];
    fdate   = list(iFile).name(1:11);
    rate    = 1;% TO IMPROVE % fdata(1).pseudo(2,5) - fdata(1).pseudo(1,5);
end


function [fdata, eph] = readeph( path )
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
% Pedro Silva, Instituto Superior Tecnico, November 2011

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
       if size(list(ilist).name,2) >= 23 
           if strfind(list(ilist).name,'ephemerides')
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
    ArgsNo = userparams('EPHARGS'); % Number of arguments in the eph message
    SatNo  = userparams('MAXSAT'); % Number of satellites
    fdata  = zeros(ArgsNo,SatNo);
    eph(1:SatNo) = struct('epoch',NaN);
    maxeph = 0;
    for iFile=1:nFiles
       filename            = strcat(path,list(iFile).name);
       values              = load(filename)';    % Transpose data
       svid                = values(1,1);        % SVID is the first parameter
       fdata(:,svid)       = values(1:ArgsNo,1); % Store data in the matrix
       ephentries          = unique(values','rows')';
       nEph                = size(ephentries,2);
       eph(svid).epoch     = zeros(ArgsNo+1,nEph); % Assign this to a cell (easier)
       if maxeph < nEph
           maxeph = nEph;
       end
       for k=1:nEph
          eph(svid).epoch(1:size(ephentries(:,k),1),k) = ephentries(:,k);
       end
    end
    
    ephtable = cell(maxeph,1);
    for k=1:maxeph
       ephtable{k} = zeros(ArgsNo+1,SatNo);
       for s=1:SatNo
           try
               if ~isnan(eph(s).epoch(1,k))
                ephtable{k}(:,s) = eph(s).epoch(:,k);
               end
           catch
               ephtable{k}(:,s) = zeros(ArgsNo+1,1);
           end
       end
    end
    eph = ephtable;
end


function fdata = readion( path, varargin )
% TO DEVELOP
%     iondata           = readion(strcat(directory,'ion/'));

    if nargin ~= 2
        filename = 'ionosphere.txt';
    else
        filename = varargin{1};
    end

    if exist(path,'dir') % Optional reading
        fdata = load(strcat(path,filename))'; % Transpose data
        fdata = struct('alpha',fdata(1:4,:),'beta',fdata(5:8,:));
        
        % TO CHANGE
        
    else
        fdata = NaN;
    end
    
end

