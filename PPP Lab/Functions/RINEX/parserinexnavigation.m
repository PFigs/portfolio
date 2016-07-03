function data = parserinexnavigation(file,idx,fSize,data,version)
%PARSERINEXNAVIGATION Summary of this function goes here
%   Detailed explanation goes here

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
    
    iEpoch   = 0;
    lasttime = -Inf;
    state    = 'orbitstart';
    
        for k=idx+1:fSize
            str = file{k};
            if strcmpi(state,'orbitstart')
                satid       = str2double(str(1:2)); % 2
                year        = str2double(str(4:5)); % 3
                month       = str2double(str(7:8)); % 3
                day         = str2double(str(10:11)); % 3
                hour        = str2double(str(13:14)); % 3
                minute      = str2double(str(15:17));
                second      = str2double(str(18:22));
                svbias      = str2double(removeD(str(23:41)));
                svdrift     = str2double(removeD(str(42:60)));
                svdriftrate = str2double(removeD(str(61:end)));
                
                WD  = weekday(datenum(year,month,day))-1;
                TOC = getweeksec(WD,hour,minute,second);
                
                state       = 'orbit1';
                

            elseif strcmpi(state,'orbit1')
                iode  = str2double(removeD(str(4:22)));
                crs   = str2double(removeD(str(23:41)));
                dn    = str2double(removeD(str(42:60)));
                mo    = str2double(removeD(str(61:end)));
                state = 'orbit2';

            elseif strcmpi(state,'orbit2')
                cuc   = str2double(removeD(str(4:22)));
                ecc   = str2double(removeD(str(23:41)));
                cus   = str2double(removeD(str(42:60)));
                sqrta = str2double(removeD(str(61:end)));
                state = 'orbit3';

            elseif strcmpi(state,'orbit3')
                toe   = str2double(removeD(str(4:22)));
                cic   = str2double(removeD(str(23:41)));
                OMEGA = str2double(removeD(str(42:60)));
                cis   = str2double(removeD(str(61:end)));            
                state = 'orbit4';

            elseif strcmpi(state,'orbit4')
                io       = str2double(removeD(str(4:22)));
                crc      = str2double(removeD(str(23:41)));
                omega    = str2double(removeD(str(42:60)));
                omegadot = str2double(removeD(str(61:end)));            
                state    = 'orbit5';

            elseif strcmpi(state,'orbit5')    
                idot  = str2double(removeD(str(4:22)));
                l2c   = str2double(removeD(str(23:41)));
                week  = str2double(removeD(str(42:60)));
                l2p   = str2double(removeD(str(61:end)));            
                state = 'orbit6';

            elseif strcmpi(state,'orbit6')
                svacc    = str2double(removeD(str(4:22)));
                svhealth = str2double(removeD(str(23:41)));
                tgd      = str2double(removeD(str(42:60)));
                iodc     = str2double(removeD(str(61:end)));            
                state    = 'orbit7';

            elseif strcmpi(state,'orbit7')
                TOTX  = str2double(removeD(str(4:22)));
                fif   = str2double(removeD(str(23:41)));
                temp  = zeros(32,32);

                % Save data
                temp(ephidx('satid'),satid)    = satid;
                temp(ephidx('WN'),satid)       = week;
                temp(ephidx('CodeL2'),satid)   = l2c;
                temp(ephidx('ura'),satid)      = svacc;
                temp(ephidx('Health'),satid)   = svhealth;
                temp(ephidx('IODC'),satid)     = iodc;
                temp(ephidx('L2P'),satid)      = l2p;
                temp(ephidx('TGD'),satid)      = tgd;
                temp(ephidx('TOC'),satid)      = TOC;
                temp(ephidx('af2'),satid)      = svdriftrate; % af2
                temp(ephidx('af1'),satid)      = svdrift; % af1
                temp(ephidx('af0'),satid)      = svbias; % af0
                temp(ephidx('iode'),satid)     = iode;
                temp(ephidx('toe'),satid)      = toe;
                temp(ephidx('fif'),satid)      = fif;
                temp(ephidx('M0'),satid)       = mo;
                temp(ephidx('ecc'),satid)      = ecc;
                temp(ephidx('sqra'),satid)     = sqrta;
                temp(ephidx('DN'),satid)       = dn;
                temp(ephidx('Omega0'),satid)   = OMEGA;
                temp(ephidx('Omega'),satid)    = omega;
                temp(ephidx('I0'),satid)       = io;
                temp(ephidx('omegadot'),satid) = omegadot;
                temp(ephidx('idot'),satid)     = idot;
                temp(ephidx('crc'),satid)      = crc;
                temp(ephidx('crs'),satid)      = crs;
                temp(ephidx('cuc'),satid)      = cuc;
                temp(ephidx('cus'),satid)      = cus;
                temp(ephidx('cic'),satid)      = cic;
                temp(ephidx('cis'),satid)      = cis;
                temp(ephidx('TOW'),satid)      = TOTX;
                % Pay attention to leap days
                time = hour*60*60+minute*60;
                if time - lasttime > 50*60
                    lasttime = time;
                    iEpoch   = iEpoch + 1;
                    data.time = [data.time (time)];
                    data.data = [data.data {temp}];
                else
                    data.data{iEpoch}(:,satid) = temp(:,satid);
                end

                state = 'orbitstart';
            end
        end
    

    %%% ARE UNITS CONSISTENT WITH THE ONES I READ FROM THE RECEIVER?
end



function str = removeD(str)
    str(str == 'D') = 'e';
end

