function [ satinfo, satacc, satid ] = readsp3c( filename )
%READSP3C reads an sp3 formated file
%   This functions allows the user to obtain a structure with the position
%   and clock report of an sp3 file. The function was designed to obtain
%   data from the sp3-c format, as used by the IGS on 2011. It should
%   continue forward compatible, as new versions will add more collumns.
%  
%   Note that some fields are ignored

% Constants
SATIDS  = 85;    % number of max sats in sp3 version
LINE_WIDTH = 61;

%Open file
fid=fopen(filename);

%% Read line 1
line = fgetl(fid);
posorvel  = line(3);
nbepoch   = sscanf(line(33:39),'%d');
dataused  = sscanf(line(41:45),'%s');
coordsys  = sscanf(line(47:51),'%s');
orbittype = sscanf(line(53:55),'%s');
agency    = sscanf(line(57:60),'%s');

%% Read line 2
line = fgetl(fid);
nbweek    = sscanf(line(4:7),'%d');
secweek   = sscanf(line(9:23),'%f');
epochint  = sscanf(line(25:38),'%s');       % epoch interval


%% init arrays
satid   = zeros(SATIDS,1);
satacc  = zeros(SATIDS,1);
sateph  = zeros(SATIDS,nbepoch);

%% Read lines 3 to 7 - Sat id
line = fgetl(fid);
nbsat = sscanf(line(5:6),'%2d');
j=11;
n=1;
for i=1:SATIDS-1
    if i == n*17+1
       line = fgetl(fid);
       j=11;
       n = n+1;
    end;
    satid(i) = sscanf(line(j:j+1),'%2d');
    j=j+3;
end;


%% Read lines 8 to 12 - Accuracy
line  = fgetl(fid);
j=10;
n=1;
for i=1:SATIDS-1
    if i == n*17+1
       line = fgetl(fid);
       j=10;
       n = n+1;
    end;
    satacc(i) = sscanf(line(j:j+2),'%3d');
    j=j+3;
end;

%% Read lines 13 to 14 - Constants c
line  = fgetl(fid);
ftype   = sscanf(line(4:5),'%s');
timesys = sscanf(line(10:12),'%s');

% ignore line 14
fseek(fid,LINE_WIDTH,'cof');

%% Read lines 15 to 16 - Constants f
line  = fgetl(fid);
base_posvel   = sscanf(line(4:13),'%f');
base_clk      = sscanf(line(15:26),'%f');

% ignore line 16
fseek(fid,LINE_WIDTH,'cof');

%% Read lines 17 to 18 - Constants i
%ignored
fseek(fid,LINE_WIDTH*2,'cof');

%% Read lines 19 to 22 - Comment lines
fseek(fid,LINE_WIDTH*4,'cof');


%% Init struct
ephdata(1:nbsat) = struct('x',inf,'y',inf,'z',inf,'clk',inf,'dx',inf,'dy',inf,'dz',inf,'dclk',inf);
epoch(1:nbepoch)   = struct('year',inf,'month',inf,'day',inf,'hour',inf,...
                            'minute',inf,'second',inf,'pdata',ephdata,'epdata',inf,'vdata',inf);
satinfo = struct('epoch', epoch,'nbsat',nbsat,'nbepoch',nbepoch);

%% Read until EOF
j=0;
i=0;
while 1 % can not be sure of the remaining number of lines
    line  = fgetl(fid);
    j=j+1;
    switch line(1);
        case '*'        % New epoch
            j=0;
            i=i+1;      % ready to receive epoch data
            satinfo.epoch(i).year   = sscanf(line(4:7),'%d');
            satinfo.epoch(i).month  = sscanf(line(9:10),'%d');
            satinfo.epoch(i).day    = sscanf(line(12:13),'%d');
            satinfo.epoch(i).hour   = sscanf(line(15:16),'%d');
            satinfo.epoch(i).minute = sscanf(line(18:19),'%d');
            satinfo.epoch(i).second = sscanf(line(21:31),'%f');
            
        case 'P'        % Position and clock report
            satinfo.epoch(i).pdata(j).satid  = sscanf(line(3:4),'%d');
            satinfo.epoch(i).pdata(j).x      = sscanf(line(5:18),'%f');
            satinfo.epoch(i).pdata(j).y      = sscanf(line(19:32),'%f');
            satinfo.epoch(i).pdata(j).z      = sscanf(line(33:46),'%f');
            satinfo.epoch(i).pdata(j).clk    = sscanf(line(47:60),'%f');
            satinfo.epoch(i).pdata(j).dx     = sscanf(line(62:63),'%d');
            satinfo.epoch(i).pdata(j).dy     = sscanf(line(65:66),'%d');
            satinfo.epoch(i).pdata(j).dz     = sscanf(line(68:69),'%d');
            satinfo.epoch(i).pdata(j).dclk   = sscanf(line(71:73),'%d');
            % rest ignored
            
        case 'E'        
            if line(2) == 'P'       % Position and clock correclation
                
            else  % end of file
                break;
            end;
            
        case 'V'        % Velocity report
            
    end
end;

%% OUTPUTS
satid       = satid(1:nbsat);
satacc      = satacc(1:nbsat);
%satinfo    = satinfo;

%%
fclose(fid);
end