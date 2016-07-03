function datatorinex(iyear,imonth,iday,data)
%WRITERINEX writes gps data to RINEX format
% Recommendation 2.11 was followed
%
% INPUT
%
% OUTPUT

% TODO:
%  IN CASES OF 12 SAT OR MORE
%

%
% Pedro Silva, Instituto Superior Tecnico, January 2012


year      = sprintf('%d',iyear);
folder    = 'RINEX/';
satsystem = 'GPS';
[ihour,imin,isec] = towtohourminsec(data.TOW(1));

%% OPEN/CREATE FILE
% NAME : ssssddf.yyt
PGM      = 'PPPLAB'; % MAX SIZE 20
RUNBY    = 'IT LX'; % MAX SIZE 20
OBSERVER = 'PEDRO SILVA'; % MAX SIZE 20
AGENCY   = 'IT SATLAB, Instituto Superior Tecnico'; % MAX SIZE 40
STATION  = 'slab'; % 4 character station name
RCVNUM   = 'ZXW.SENSOR';
RCVTYPE  = 'L1L2';
RCVVER   = 'V1.0';
DISTOBS  = 4; % DISTINTIC OBSERVATIONS
% ?!?!?!?!?!?!
MARKERNM = 'A 9080'; % WHAT IS THIS?
% ?!?!?!?!?!?!
APROXX = 4918533.320;
APROXY = -791212.572;
APROXZ = 3969758.451;

ANTENAH = 0.0;
ANTENAE = 0.0;
ANTENAN = 0.0;
abcd     = 'abcdefghijklmnopqrstuvx';
doy      = sprintf('%03d',dayofyear(iyear,imonth,iday)); % day of year of first record
seqnum   = abcd(ihour); % file sequence number
filetype = 'Observation Data'; % observation (O), navigation (N), ...
filename = strcat(STATION,doy,seqnum,'.',year(3:4),filetype(1));
fid      = fopen(strcat(folder,filename),'w');


%% RECORD HEADER

% Format Version and type of file/data
rinexVersion = 2.11;
fprintf(fid,'%9.2f',rinexVersion);
fillblank(fid,'',11);
fprintf(fid,'%c',filetype);
fillblank(fid,'Observation Data',20);
fprintf(fid,'%s',satsystem);
fillblank(fid,satsystem,20);
fprintf(fid,'%s\n','RINEX VERSION / TYPE');

% Name of program, agency and creation date
fprintf(fid,'%s',PGM); 
fillblank(fid,PGM,20);
fprintf(fid,'%s',RUNBY); % MAX SIZE 20
fillblank(fid,RUNBY,20);
fprintf(fid,'%s',date); % ALWAYS 20
fillblank(fid,date,20);
fprintf(fid,'%s\n','PGM / RUN BY / DATE');

%writecomment(fid,'Propriedade do Instituto Superior Tecnico');

% ANTENNA MARKER ?
fprintf(fid,'%s',MARKERNM);
fillblank(fid,MARKERNM,60);
fprintf(fid,'%s\n','MARKER NAME');

% Observer and agency
fprintf(fid,'%s',OBSERVER);
fillblank(fid,OBSERVER,20);
fprintf(fid,'%s',AGENCY);
fillblank(fid,AGENCY,40);
fprintf(fid,'%s\n','OBSERVER / AGENCY');

% Receiver info
fprintf(fid,'%s',RCVNUM);
fillblank(fid,RCVNUM,20);
fprintf(fid,'%s',RCVTYPE);
fillblank(fid,RCVTYPE,20);
fprintf(fid,'%s',RCVVER);
fillblank(fid,RCVVER,20);
fprintf(fid,'%s\n','REC # / TYPE / VERS');

% Antenna type
ANTNUM  = '531V2';
ANTTYPE = 'AO32';
fprintf(fid,'%s',ANTNUM);
fillblank(fid,ANTNUM,20);
fprintf(fid,'%s',ANTTYPE);
fillblank(fid,ANTTYPE,40);
fprintf(fid,'%s\n','ANT # / TYPE');

% Approximate position
str = sprintf('%14.4f%14.4f%14.4f',APROXX,APROXY,APROXZ);
fprintf(fid,'%s',str);
fillblank(fid,str,60);
fprintf(fid,'%s\n','APPROX POSITION XYZ');

% Antenna deltas
str = sprintf('%14.4f%14.4f%14.4f',ANTENAH,ANTENAE,ANTENAN);
fprintf(fid,'%s',str);
fillblank(fid,str,60);
fprintf(fid,'%s\n','ANTENNA: DELTA H/E/N');

% Number and types of observables
fprintf(fid,'%6d',DISTOBS);
fillblank(fid,'',4); fprintf(fid,'P1');
fillblank(fid,'',4); fprintf(fid,'L1');
fillblank(fid,'',4); fprintf(fid,'P2');
fillblank(fid,'',4); fprintf(fid,'L2');
fillblank(fid,'',54-DISTOBS*6);
fprintf(fid,'%s\n','# / TYPES OF OBSERV');

% Time of first observation
fprintf(fid,'%6d',iyear);
fprintf(fid,'%6d',imonth);
fprintf(fid,'%6d',iday);
fprintf(fid,'%6d',ihour);
fprintf(fid,'%6d',imin);
fprintf(fid,'%13.7f',isec);
fillblank(fid,'',5);
fprintf(fid,'%s','GPS');
fillblank(fid,'',2+7);
fprintf(fid,'%s\n','TIME OF FIRST OBS');

% End of header
fillblank(fid,'',60);
fprintf(fid,'%s\n','END OF HEADER');


%% RECORD DATA

% Epoch entry
for iEpoch=1:size(data.TOW,1)
    
    [ihour,imin,isec] = towtohourminsec(data.TOW(iEpoch));
    availableSat      = find(((data.PRL1(iEpoch,:)) ~= 0));
    strsatlist        = sprintf('G%02d',availableSat);
    nSat              = size(availableSat,2);% obtain sat list
    
    if nSat <=5
        fprintf('NSAT: %d, iEpoch: %d\n',nSat,iEpoch);
    end
    
    fprintf(fid,' %s',year(3:4)); % changing year not considered
    fprintf(fid,' %2d',imonth); % changing month not considered
    fprintf(fid,' %2d',iday); % it may change but one can consider only one day observations    
    fprintf(fid,' %2d',ihour);
    fprintf(fid,' %2d',imin);
    fprintf(fid,'%11.7f',isec);

    % If ok
    EpochFlag = 0;
    fprintf(fid,'  %1d',EpochFlag);
    fprintf(fid,'%3d',nSat);
    fprintf(fid,'%s',strsatlist);
    fillblank(fid,strsatlist,64);
    fprintf(fid,'\n');

    for j=1:nSat
        fprintf(fid,'%14.3f  %14.3f  %14.3f  %14.3f\n',data.PRL1(iEpoch,availableSat(j)),...
                                                       data.CPL1(iEpoch,availableSat(j)),...
                                                       data.PRL2(iEpoch,availableSat(j)),...
                                                       data.CPL2(iEpoch,availableSat(j)));
    end
end

fclose(fid);

end


function fillblank(fid,str,max)

    fprintf(fid,'%s',blanks(max-length(str)));

end


function writecomment(fid,str)
%WRITECOMMENT writes a comment to the RINEX FILE
%  If the given stringer is bigger than what it is supposed, the comment 
%  will not be written to the file 
%  According to the 2.11 recomendation
%
% INPUT
% FID - File descriptor
% STR - Comment to insert
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

sizeStr = length(str);
    if sizeStr < 60
        fprintf(fid,'%s',str); %MAX 59 CHAR
        fprintf(fid,'%s',blanks(60-size(str,2)));
        fprintf(fid,'%s\n','COMMENT');
    end
    %else do nothing
end