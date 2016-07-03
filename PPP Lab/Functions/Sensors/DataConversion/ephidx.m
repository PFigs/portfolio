function idx = ephidx(str)
%EPHIDX returns the parameter index for accesing eph matrices
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
% INPUT
% STR - Parameter name
%
% OUTPUT
% IDX - Parameter index
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    if strcmpi('SID',str) || strcmpi('satid',str)
        idx = 1;
    elseif strcmpi('WN',str) || strcmpi('weeknb',str)
        idx = 2;
    elseif strcmpi('CodeL2',str)
        idx = 3;
    elseif strcmpi('URA',str)
        idx = 4;
    elseif strcmpi('Health',str)
        idx = 5;
    elseif strcmpi('IODC',str)
        idx = 6;
    elseif strcmpi('L2P',str)
        idx = 7;
    elseif strcmpi('TGD',str)
        idx = 8;
    elseif strcmpi('TOC',str)
        idx = 9;
    elseif strcmpi('AF2',str)
        idx = 10;
    elseif strcmpi('AF1',str)
        idx = 11;
    elseif strcmpi('AF0',str)
        idx = 12;
    elseif strcmpi('IODE',str) || strcmpi('IODESF2',str)
        idx = 13;
    elseif strcmpi('IODESF3',str)
        idx = 14;
    elseif strcmpi('TOE',str)
        idx = 15;
    elseif strcmpi('FIF',str)
        idx = 16;
    elseif strcmpi('M0',str)
        idx = 17;
    elseif strcmpi('ECC',str)
        idx = 18;
    elseif strcmpi('SQRA',str)
        idx = 19;
    elseif strcmpi('DN',str)
        idx = 20;
    elseif strcmpi('Omega0',str)
        idx = 21;
    elseif strcmpi('I0',str)
        idx = 22;
    elseif strcmpi('Omega',str) % argument perigee
        idx = 23;
    elseif strcmpi('Omegadot',str)
        idx = 24;
    elseif strcmpi('IDOT',str)
        idx = 25;
    elseif strcmpi('CRC',str)
        idx = 26;
    elseif strcmpi('CRS',str)
        idx = 27;
    elseif strcmpi('CUC',str)
        idx = 28;
    elseif strcmpi('CUS',str)
        idx = 29;
    elseif strcmpi('CIC',str)
        idx = 30;
    elseif strcmpi('CIS',str)
        idx = 31;
    elseif strcmpi('TOW',str)
        idx = 32;
    elseif strcmpi('UPDATE',str)
        idx = 33;
    else
        error(['ephidx: Ooops did not find match for ' str]);
    end
   
end

