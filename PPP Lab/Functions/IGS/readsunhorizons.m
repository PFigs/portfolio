function data = readsunhorizons(filepath,iTOW,lTOW)
% READ FILE 
% CONVERT FROM ECI TO ECEF
%
%   Filepath - Path to file

    interval = lTOW - iTOW;
    assert(interval > 0,'Invalid interval');

    fid = fopen(filepath);
    assert(fid>0,'Failed to open file')
    
    sdata = zeros(interval,3);
    stow  = zeros(interval,1);
    sidx  = 0;
    TOW   = 0;
    state = 'begin';
    % Read
    ln = fgetl(fid);
    while ln~=-1 
        
        if strcmpi(state,'begin')
            k = strfind(ln,'$$SOE');
            if ~isempty(k)
                state = 'read';
            end
            
        elseif strcmpi(state,'read')

            k = strfind(ln,'$$EOE');
            if ~isempty(k)
                break;
            end
            
            % GET DATE
            eod = sscanf(ln,'%f = %s');
            JD  = eod(1);
            
            % GET DATA
            ln  = fgetl(fid);
            
            % SAVE IT IF INSIDE WANTED RANGE
            if TOW >= iTOW
                if TOW <= lTOW
                    sidx = sidx +1;
                    xyz  = sscanf(ln,'%f %f %f\n');
                    xyz  = ecitoecef(JD,xyz);
                    sdata(sidx,:) = xyz.*1e03; % Convert to meter
                    stow(sidx) = TOW;
                else
                    break;
                end
            end
            TOW = TOW + 1;
        end
        ln = fgetl(fid);
        if isempty(ln)
            ln = 0;
        end

    end
    fclose(fid);
    data = struct('sun',sdata,'TOW',stow);
end