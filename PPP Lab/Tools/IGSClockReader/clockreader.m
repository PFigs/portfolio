%Clock reader reads a rinex clock file
%   This functions allows the user to obtain a structure with the position
%   and clock report of a RINEX file. The function was designed to obtain
%   data from the IGS RINEX format, as used by the IGS on 2011. 
%  
%   Pedro Silva, Instituto Superior Tecnico, March 2012

filename = 'igs16663.clk';
WN     = 1666;
WD     = 3;

%Open file
nbvec = 1:100; 
fid   = fopen(filename);
file  = textscan(fid,'%s','delimiter',sprintf('\n'));
fSize = size(file{1},1);

% Search for header end
count = 0;
for k=1:fSize
    count = count+1;
    if strcmpi(file{1}{k}(1:3),'END')
        break;
    end
end

% Read the clock data
fdata = struct('clkb', zeros(288,32),'TOW', zeros(288,1));
iEpoch = 1;
flag   = 0;
for k=k+1:fSize
    spaces = nbvec(file{1}{k}==' ');
    if strcmpi(file{1}{k}(1:spaces(1)-1),'AS')
        if file{1}{k}(spaces(1)+1) == 'G'
            flag = 1;
            [parsed,count]=sscanf(file{1}{k}(spaces(1)+1:end),'G%d %d %d %d %d %d %f %d %e %e');
            svid = parsed(1);
            fdata.TOW(iEpoch)  = getweeksec(WD,parsed(5),parsed(6),parsed(7));
            fdata.clkb(iEpoch,svid) = parsed(9);
        end
    elseif flag
        iEpoch = iEpoch + 1;
        flag   = 0;
    end
end   

fclose(fid);
