function epoch = decodeMCA( data, epoch )
%DECODEMCA decodes MCA data payload (AC12)
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

    C      =  gpsparams('c');
    
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
    epoch.BFCA(satid)      = u4(data(idx:idx+3),'bigendian');   
    
end

