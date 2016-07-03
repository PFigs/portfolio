function data = parseantex(file,k,fSize)
%PARSEANTEX parses IGS antex file
% OUTPUT in metre!
% Available @ ftp://igscb.jpl.nasa.gov/pub/station/general/igs08.atx

    data = zeros(userparams('MAXSAT'),3);

    state      = 'none';
    tocontinue = 1;

    while tocontinue && k < fSize
        
        % Move forward in the file
        k=k+1;
            
        idx = strfind(file{k},'START OF ANTENNA');
        if ~isempty(idx)
            state    = 'start';
            continue;
        end
        
        if strcmpi(state,'start')
           idx = strfind(file{k},'TYPE / SERIAL NO');
           if ~isempty(idx)
                info    = regexp(file{k}(1:idx-1),'\s*','split');
                info(1) = [];
                prn     = info{2};
                
                if prn(1)=='G'
                    prn   = str2double(prn(2:end));
                    state = 'gps';
                else
                    tocontinue = 0;
                end
           end
  
        elseif strcmpi(state,'gps')
            idx = [];
            % Search for phase center
            while isempty(idx)
                k=k+1;
                idx = strfind(file{k},'NORTH / EAST / UP');
            end
            info    = regexp(file{k}(1:idx-1),'\s*','split');
            info(1) = [];
            data(prn,1) = str2double(info{1})*1e-03;
            data(prn,2) = str2double(info{2})*1e-03;
            data(prn,3) = str2double(info{3})*1e-03;            
            state = 'none';
        end
    end

end