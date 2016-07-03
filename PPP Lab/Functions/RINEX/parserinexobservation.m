function data = parserinexobservation(file,idx,fSize,data, obs, nObs)

    maxcol = 1:80;
    state  = 'epochstart';
    iEpoch = 0;
    
    namestr  = 'Loading RINEX Observation file';
    wbhandle = waitbar(0,'1','Name',namestr);
    for k=idx+1:fSize

        if strcmpi(state,'epochstart')
            iEpoch = iEpoch + 1;
            gpspos = file{k}=='G'; %find GPS position
            gpspos = maxcol(gpspos);
            glopos = file{k}=='R'; %find Glonass position
            glopos = maxcol(glopos);

            gpsidx = min(gpspos);
            gloidx = min(glopos);
            idx    = min(gpsidx,gloidx);

            % Flag who comes first 
            % (if extended remember to keep the second one)
            if gpsidx == idx
                systemorder = ['G','R'];
            elseif gpsidx == gloidx
                systemorder = ['R','G'];
            else
                error('minimum index not present in any sat system');
            end

            epinfo = file{k}(1:idx-1);

            epinfo = regexp(epinfo,'\s*','split');
            epinfo(1) = [];
            assert(size(epinfo,2) >= 8,'Failed to parse string');
            year    = str2double(['20',epinfo{1}]);
            month   = str2double(epinfo{2});
            day     = str2double(epinfo{3});
            hour    = str2double(epinfo{4});
            minute  = str2double(epinfo{5});
            second  = str2double(epinfo{6});
            flag    = str2double(epinfo{7});
            nSat    = str2double(epinfo{8});

            WD               = weekday(datenum(year,month,day))-1;
            TOW              = getweeksec(WD,hour,minute,second);
            data.TOW(iEpoch) = TOW;
            [gpssats]        = getsatellites(file{k},gpspos);
            [glosats]        = getsatellites(file{k},glopos);

            if nSat > 12
                state = 'epochcont';
            else
                gpsparsed = 0;
                gloparsed = 0;
                parsed = 0;
                glosats = glosats + 64; % OFFSET (sames as proflex)
                if systemorder(1) == 'G'
                    sats = [gpssats;glosats];
                elseif systemorder(1) == 'R'
                    sats = [glosats;gpssats];
                end                    
                state = 'observation';
            end

        elseif strcmpi(state,'epochcont')
            % Epoch line continuation (more than 12 sat)
            gpspos = file{k}=='G'; %find GPS position
            gpspos = maxcol(gpspos);
            glopos = file{k}=='R'; %find Glonass position
            glopos = maxcol(glopos);

            [gpssats] = getsatellites(file{k},gpspos,gpssats);
            [glosats] = getsatellites(file{k},glopos,glosats);

            parsed    = 0;
            glosats = glosats + 64; % OFFSET (sames as proflex)
            if systemorder(1) == 'G'
                sats = [gpssats;glosats];
            elseif systemorder(1) == 'R'
                sats = [glosats;gpssats];
            end

            state = 'observation';


        elseif strcmpi(state,'observation')

            % Satellite to parse
            parseidx = 1;
            parsesat = sats(1);

            % Retrieve information according to header
            % LLI and SI ignored
            str = file{k};
            while ~isempty(str)
                data = fillstruct(iEpoch,parsesat,obs(parseidx),str,data);
                if length(str) >= 16
                    str(1:16) = [];
                else
                    str(1:end) = [];
                end
                parseidx = parseidx + 1;
            end

            if nObs > 5
                state = 'observationcont';
            else
                if parsed >= nSat
                    state = 'epochstart';
                else
                    parsed  = parsed +1;
                    sats(1) = []; % pop sat
                    state   = 'observation';
                end
            end


        elseif strcmpi(state,'observationcont')                

            % Retrieve information according to header
            % LLI and SI ignored
            str = file{k};
            while ~isempty(str)
                data = fillstruct(iEpoch,parsesat,obs(parseidx),str,data);
                if length(str) >= 16
                    str(1:16) = [];
                else
                    str(1:end) = [];
                end
                parseidx = parseidx + 1;
            end

            parsed  = parsed +1;
            sats(1) = []; % pop sat

            if parsed >= nSat
                state = 'epochstart';
            else
                state = 'observation';
            end
        end    
        waitbar(k/fSize,wbhandle,sprintf('line %d : Epoch %d - %.0f%%',k,iEpoch,k/fSize*100));
    end
    close(wbhandle)
    drawnow;
end



function data = fillstruct(iEpoch,sat,obs,str,data)


    if strcmpi(obs,'C1')
        data.PRCAL1(iEpoch,sat)  = str2double(str(1:14));
%         data.CALLIL1(iEpoch,sat) = str2double(str(15));
%         data.CASIL1(iEpoch,sat)  = str2double(str(15));

    elseif strcmpi(obs,'C2')
        data.PRCAL2(iEpoch,sat) = str2double(str(1:14));

    elseif strcmpi(obs,'P1')
        data.PRL1(iEpoch,sat) = str2double(str(1:14));

    elseif strcmpi(obs,'P2')
        data.PRL2(iEpoch,sat) = str2double(str(1:14));

    elseif strcmpi(obs,'L1')
        data.CPL1(iEpoch,sat) = str2double(str(1:14));

    elseif strcmpi(obs,'L2')
        data.CPL2(iEpoch,sat) = str2double(str(1:14));

    elseif strcmpi(obs,'S1')
        data.SNRL1(iEpoch,sat) = str2double(str(1:14));

    elseif strcmpi(obs,'S2')    
        data.SNRL2(iEpoch,sat) = str2double(str(1:14));

    end
                    


end



function [sats,nSat] = getsatellites(str,tokenposition,sats)

    if nargin == 2
        sats = [];
    end

    if ~isempty(tokenposition)
        for psat=tokenposition
            sats = [sats; str2double(str(psat+1:psat+2))];
        end
    end
    
    nSat = size(sats,1);
end
