function message = decodeMPC(data, message)
%DECODEMPC decodes MPC data payload
% Please note that bitfield is stored in decimal format
%
% INPUT
% DATA    - First message payload
% MESSAGE - Struct with essential data to receive ranges information and
%           provide timing constrains
%
% OUTPUT
% ranges   - ranges data
% NSTRUCT - Remaining structures to obtain
% SEQ     - Sequence number
%
% SEQ number still seems to cause trouble (full buffer? Message lost?)
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    % initialisations
    C      =  gpsparams('c');
    ranges = message.ranges;
    
    seq                   = u2(data(1:2),'bigendian');
    nStruct               = double(data(3));
    satid                 = double(data(4));
    ranges.LEFT           = nStruct;
    ranges.SATLIST(satid) = satid;     %saves id in vector to speed up reading
    ranges.SATELV(satid)  = double(data(5));   %satellite elevation
    ranges.SATAZ(satid)   = double(data(6)*2); %satellite azimuth
    ranges.channel        = double(data(7));
    
%     fprintf('\tSAT: %d, LEFT: %d SEQ: %d (%d)\n',satid,nStruct,seq,message.TOW);

    % GPS and SBAS
    if satid <= 51     
        if ~isnan(message.TOW) %  && isnan(ranges.TOW)
            % The TOW will be the same for all the MPC in the same epoch
            if isnan(ranges.TOW)
                leap            = mod(seq - message.lastSEQ,36000);
                ranges.TOW      = message.TOW + leap*50e-03; 
                ranges.SEQ      = seq;
                message.TOW     = ranges.TOW;
                message.lastSEQ = seq;
                
            % Checks if two MPCs have overlapped
            elseif ranges.SEQ  ~= seq
                warning('ASHTECH:decodeMPC','Unexpected SEQ found. Ignoring measurements.');
                message.dirty = 0;
                message.TOW     = NaN;
                message.lastSEQ = NaN;                
                return
            end
            
        % Only true for the first time
        else
            message.TOW     = seqtotow(seq,message.UTCoffset,message.WD);
            message.lastSEQ = seq;
            ranges.SEQ      = seq;
            ranges.TOW      = message.TOW;
        end
        
    % GLONASS
    else 
        if ~isnan(message.TOWGLO)
            % The TOW will be the same for all the MPC in the same epoch
            if isnan(ranges.TOWGLO)
                leap           = mod(seq - message.lastSEQGLO,36000);
                ranges.TOWGLO  = message.TOWGLO + leap*50e-03; 
                ranges.SEQGLO  = seq;
                message.TOWGLO = ranges.TOWGLO;
                message.lastSEQGLO = seq;
            
            % Checks if two MPCs have overlapped
            elseif ranges.SEQGLO  ~= seq
                warning('ASHTECH:decodeMPC','Unexpected SEQ found. Ignoring measurements.');
                message.dirty = 0;
                return
            end
            
        % Only true for the first time
        else
            message.TOWGLO     = seqtotow(seq,message.UTCoffset,message.WD);
            message.lastSEQGLO = seq;
            ranges.SEQGLO      = seq;
            ranges.TOWGLO      = message.TOWGLO;
        end
        
    end;
      
    idx = 8;
    % C/A code data block - BIT FIELD IS STORED IN DECIMAL!
    ranges.WARNINGCA(satid) = double(data(idx)); idx=idx+1;
    ranges.QUALITYCA(satid) = double(data(idx)); idx=idx+2; % Ignored
    ranges.SNRCA(satid)     = double(data(idx)); idx=idx+2; % Spare
    ranges.CPCA(satid)      = r8(data(idx:idx+7),'bigendian'); idx = idx+8;
    ranges.PRCA(satid)      = r8(data(idx:idx+7),'bigendian')*C; idx = idx+8;
    ranges.DOCA(satid)      = i4(data(idx:idx+3),'bigendian')*1e-04; idx = idx+4;
    ranges.BFCA(satid)      = u4(data(idx:idx+3),'bigendian'); idx = idx+4;
    
    % P code on L1 block
    ranges.WARNINGL1(satid) = double(data(idx)); idx=idx+1;
    ranges.QUALITYL1(satid) = double(data(idx)); idx=idx+2; % Ignored
    ranges.SNRL1(satid)     = double(data(idx)); idx=idx+2; % Spare
    ranges.CPL1(satid)      = r8(data(idx:idx+7),'bigendian');idx = idx+8;
    ranges.PRL1(satid)      = r8(data(idx:idx+7),'bigendian')*C;idx = idx+8;
    ranges.DOL1(satid)      = i4(data(idx:idx+3),'bigendian')*1e-04;idx = idx+4;
    ranges.BFL1(satid)      = u4(data(idx:idx+3),'bigendian');idx = idx+4;    
    
    % P code on L2 block
    ranges.WARNINGL2(satid) = double(data(idx)); idx=idx+1;
    ranges.QUALITYL2(satid) = double(data(idx)); idx=idx+2; % Ignored
    ranges.SNRL2(satid)     = double(data(idx)); idx=idx+2;  % Spare
    ranges.CPL2(satid)      = r8(data(idx:idx+7),'bigendian');idx = idx+8;
    ranges.PRL2(satid)      = r8(data(idx:idx+7),'bigendian')*C;idx = idx+8;
    ranges.DOL2(satid)      = i4(data(idx:idx+3),'bigendian')*1e-04;idx = idx+4;
    ranges.BFL2(satid)      = u4(data(idx:idx+3),'bigendian');

    
    % Updates struct
    message.ranges = ranges;
    
end

