function fdata = readclk( filename, WD )
%READCLK reads a rinex clock file
%   This functions allows the user to obtain a structure with the position
%   and clock report of a RINEX file. The function was designed to obtain
%   data from the IGS RINEX format, as used by the IGS on 2011. 
%  
%   readclk( filename, WD )
%
%   Pedro Silva, Instituto Superior Tecnico, March 2012

    %Open file
    nbvec = 1:100; 
    fid   = fopen(filename);
    file  = textscan(fid,'%s','delimiter',sprintf('\n'));
    fclose(fid);
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
    fdata = struct('clkb', zeros(288,32),'TOW', zeros(288,1),'sclk', zeros(288,32));
    iEpoch = 0;
    last   = Inf;
    for k=k+1:fSize
        spaces = nbvec(file{1}{k}==' ');
        if strcmpi(file{1}{k}(1:spaces(1)-1),'AS')
            if file{1}{k}(spaces(1)+1) == 'G'
                [parsed,count]=sscanf(file{1}{k}(spaces(1)+1:end),'G%d %d %d %d %d %d %f %d %e %e\n');
                if count == 0
                    error('No data read form igs clock file');
                end
                svid = parsed(1);
%                 file{1}{k}
                tow = getweeksec(WD,parsed(5),parsed(6),parsed(7));
                
                if tow ~= last
                   iEpoch = iEpoch + 1;
                   last   = tow;
                end

                fdata.TOW(iEpoch)  = getweeksec(WD,parsed(5),parsed(6),parsed(7));
                fdata.clkb(iEpoch,svid) = parsed(9);
                if count > 9
                    fdata.sclk(iEpoch,svid) = parsed(10);
                end
            end
        end
    end   

end

