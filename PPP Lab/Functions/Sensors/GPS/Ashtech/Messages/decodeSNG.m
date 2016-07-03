function epoch = decodeSNG(data, epoch)
%DECODESNG decodes SNG data payload
% Please note that bitfield is stored in decimal format
%
% INPUT
% DATA - First message payload
%
% OUTPUT
% EPOCH - Epoch data
% NSTRUCT - Remaining structures to obtain
% SEQ - Sequence number
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    STM = u4(data(1:2),'bigendian'); % Start time of 30-second frame 
                                         % in satellite time scale tk from
                                         % which the ephemeris data is
                                         % derived; time modulo one day 
                                         % (seconds)
    
    DN  = u2(data(3:4),'bigendian'); % Day number of 30-second frame; modulo
                                     % four-year period counting from 
                                     % beginning of last leap year, which
                                     % corresponds to parameter tb
                                     % (tb is set within this day number).
                                     % This parameter varies within the 
                                     % range 1 to 1461. If day number=0,
                                     % the day number is unknown
                                     % (absent in navigation frame)
    
    GTOE  = u4(data(5:8),'bigendian');
    FOGH  = u4(data(9:12),'bigendian');
    BTN   = u4(data(13:16),'bigendian');
    ECEFX = r8(data(17:24),'bigendian');
    ECEFY = r8(data(25:32),'bigendian');
    ECEFZ = r8(data(33:40),'bigendian');
    VELX  = r4(data(41:44),'bigendian');
    VELY  = r4(data(45:48),'bigendian');
    VELZ  = r4(data(49:52),'bigendian');
    ACCX  = r4(data(53:56),'bigendian');
    ACCY  = r4(data(57:60),'bigendian');
    ACCZ  = r4(data(61:64),'bigendian');
    BTC   = r8(data(65:72),'bigendian');
    AEN   = r8(data(73:80),'bigendian');
    BIF   = data(81);
    CHN   = data(82);                    % Satellite frequency channel 
                                         % number[-7,…,6]
    SATID = u2(data(83:83),'bigendian'); % Satellite system number 
                                         % (satellite number [1,…,24])
    
    
    
    
    seq     = u2(data(1:2),'bigendian');
    nStruct = data(3);
    satid   = data(4);
       
    epoch.SATLIST(satid) = satid;   %saves id in vector to speed up reading
    epoch.SATELV(satid)  = data(5); %satellite elevation
    epoch.SATAZ(satid)   = data(6); %satellite azimuth
    epoch.channel = data(7);
    epoch.TOW     = seqtotow(seq);    %time of week converted from 30min timer
    epoch.WN      = getweeknum(2012,datenum(date));
    epoch.LEFT    = nStruct;
    %fprintf('STRUCT LEFT: %d => SEQ: %d, TOW: %d \n',nStruct,seq,epoch.TOW);
    
    idx = 8;
    % C/A code data block - BIT FIELD IS STORED IN DECIMAL!
    epoch.WARNINGCA(satid) = data(idx); idx=idx+1;
    epoch.QUALITYCA(satid) = data(idx); idx=idx+2; % Ignored
    epoch.SNRCA(satid)     = data(idx); idx=idx+2;  % Spare
    epoch.CPCA(satid)      = r8(data(idx:idx+7),'bigendian'); idx = idx+8;
    epoch.PRCA(satid)      = r8(data(idx:idx+7),'bigendian')* C; idx = idx+8;
    epoch.DOCA(satid)      = u4(data(idx:idx+3),'bigendian'); idx = idx+4;
    epoch.BFCA(satid)      = u4(data(idx:idx+3),'bigendian'); idx = idx+4;
    
    % P code on L1 block
    epoch.WARNINGL1(satid) = data(idx); idx=idx+1;
    epoch.QUALITYL1(satid) = data(idx); idx=idx+2; % Ignored
    epoch.SNRL1(satid)     = data(idx);idx=idx+2;  % Spare
    epoch.CPL1(satid)      = r8(data(idx:idx+7),'bigendian');idx = idx+8;
    epoch.PRL1(satid)      = r8(data(idx:idx+7),'bigendian')* C;idx = idx+8;
    epoch.DOL1(satid)      = u4(data(idx:idx+3),'bigendian');idx = idx+4;
    epoch.BFL1(satid)      = u4(data(idx:idx+3),'bigendian');idx = idx+4;    
    
    % P code on L2 block
    epoch.WARNINGL2(satid) = data(idx); idx=idx+1;
    epoch.QUALITYL2(satid) = data(idx); idx=idx+2; % Ignored
    epoch.SNRL2(satid)     = data(idx);idx=idx+2;  % Spare
    epoch.CPL2(satid)      = r8(data(idx:idx+7),'bigendian');idx = idx+8;
    epoch.PRL2(satid)      = r8(data(idx:idx+7),'bigendian')* C;idx = idx+8;
    epoch.DOL2(satid)      = u4(data(idx:idx+3),'bigendian');idx = idx+4;
    epoch.BFL2(satid)      = u4(data(idx:idx+3),'bigendian');
    

end

