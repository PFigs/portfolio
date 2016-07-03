function sFile = readbinfile( varargin )
%READBINFILE reads an ashtech binary file
%   The messages obtained from the receiver are recorded "as is" to the
%   file.
%
%   INPUT
%
%   OUTPUT
%
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012

    % Check input
    error(nargchk(0, 2, nargin)) % future usage: error(narginchk(3, 3));
    
    if nargin ==1
        if ~ischar(varargin{1})
            error('readbinfile: Input must be a string');
        else
            directory = varargin{1};
        end
        if ~exist(directory,'dir')
            error('readbinfile: DIRECTORY must point to an existing location');
        end  
    else
        directory = 'rcvdata/'; % Default data path
        if ~exist(directory,'dir')
            error('readbinfile: Default path does not exist');
        end
    end
    
    if nargin == 2
        if ~ischar(varargin{2})
            error('readbinfile: Input must be a string');
        else
            filename = varargin{2};
        end
        if ~exist(strcat(directory,'bin/',filename),'file')
            error('readbinfile: DIRECTORY must point to an existing location');
        end  
    else
        filename  = 'ashtech.bin';
    end

    %load file
    fid     = fopen(strcat(directory,'bin/',filename));
    if fid == -1
        error('readbinfile: failed to open file');
    end
    binfile = fread(fid);
    fclose(fid);
    
    
    % syncbin - searches for $
    dollar                    = binfile=='$';
    possiblemessages          = sum(dollar);
    dollar                    = find(dollar ==1);
    valid(1,1:length(dollar)) = NaN;
    
    % finds mischecks
    fprintf('Possible messages: %d\n',possiblemessages);
    count    = 0;
    msgcount = zeros(4,1);
    for p=dollar'
        if strncmpi(char(binfile(p+1:p+6))','PASHR,',6)
            count = count +1;
            valid(1,count)=p;
            if strncmpi(char(binfile(p+7:p+9))','MPC',3)
                msgcount(1)=msgcount(1)+1;
            elseif strncmpi(char(binfile(p+7:p+9))','SNV',3)
                msgcount(2)=msgcount(2)+1;
            elseif strncmpi(char(binfile(p+7:p+9))','ION',3)
                msgcount(3)=msgcount(3)+1;
            elseif strncmpi(char(binfile(p+7:p+9))','RPC',3)
                msgcount(4)=msgcount(4)+1;
            end
        end
    end
    
    fprintf('Messages found: %d\n',count);
    fprintf('MPC: %d\n',msgcount(1));
    fprintf('SNV: %d\n',msgcount(2));
    fprintf('ION: %d\n',msgcount(3));
    fprintf('RPC: %d\n',msgcount(4));
    
    valid(isnan(valid))=[];
    
    
    % Send to rfilestructs
    sFile = struct(...
                'receiver',NaN,...
                'rate',NaN,...
                'stime',NaN,...
                'ranges',NaN,...
                'eph',NaN,...
                'wn',NaN,...
                'iono',NaN);
            
    % This is the final struct which will be sent up             
    sFile.receiver = 'BINFILE';
    sFile.ranges   = rfilestructs('binranges',msgcount(1));  % reads struct declaration
    sFile.eph      = rfilestructs('bineph');  % reads struct declaration
    
    %parsing struct
    parsing           = struct(...
                            'msgID',NaN,...
                            'update',NaN,...
                            'dirty',NaN,...
                            'satlist',NaN,...
                            'nbEpoch',NaN,...
                            'ranges',NaN,...
                            'eph',NaN,...
                            'iono',NaN,...
                            'UTCoffset',0 ...
                            );
    parsing.eph       = ashtechstructs('SNV'); 
    parsing.ranges    = ashtechstructs('MPC'); 
    parsing.dirty     = 1;
    parsing.nbEpoch   = 0;
    
    namestr  = ['Loading ashtech file'];
    wbhandle = waitbar(0,'1','Name',namestr);
    % decode  - read the message size (bytes always available if not EOF)
    elements = length(valid);
    for k = 1:50000
        p=valid(k);
        idx    = p+7; % header index - skips to comma
        header = char(binfile(idx:idx+2))';
        
        % get payload size (with checksum) and checksum type
        idx                = idx+4; % first payload byte
        [datalength,cksum] = parseashtech(header,binfile(idx:idx+1));
        if isempty(datalength)
            continue;
        end
        
        % Compute cksum
        payload = binfile(idx:idx+datalength-1);
        if checksum(payload,cksum);
            parsing.msgID = header;
            parsing       = parsemsg(header,payload,parsing);
            if ~isstruct(parsing.ranges)
                break;
            end
            if parsing.dirty
                sFile         = storeparsing(sFile,parsing);
            end
        else
            fprintf('checksum failed');
        end
        waitbar(k/elements,wbhandle,sprintf('%.0f%%',k/elements*100));
    end
    close(wbhandle)
    drawnow
    save(strcat('binfile2','-',...
         num2str(parsing.day),',',...
         num2str(parsing.month),',',...
         num2str(parsing.year),'-',...
         num2str(parsing.hour),',',...
         num2str(parsing.min)),'sFile');
end



function [datalength,cksum] = parseashtech( msgID, datalength)
    
    % DBN MESSAGE - Information regarding pseudo range
    if strcmpi(msgID,'RPC')
        datalength = u2(datalength,'bigendian')+2;
        cksum      = '16b';
        
    elseif strcmpi(msgID,'DPC')
        datalength = u2(datalength,'bigendian')+2;
        cksum      = '16b';     
        
    % SNV MESSAGE - Information regarding sat ephemerides
    elseif strcmpi(msgID,'SNV')
        datalength = 130+2;
        cksum      = '16b';

    % MPC MESSAGE - Ranges to the satellites (C\A, L1, L2)
    elseif strcmpi(msgID,'MPC') 
        datalength = 94+1;
        cksum      = 'XOR';
    
    % MPC MESSAGE - Ranges to the satellites (C\A only)
    elseif strcmpi(msgID,'MCA') 
        datalength = 94+1;
        cksum      = 'XOR';

    % ION MESSAGE - Ionosphere message
    elseif strcmpi(msgID,'ION')
        datalength = 74+2;
        cksum      = '16b';

    elseif strcmpi(msgID,'PFS')
        datalength = 32+2;
        cksum      = 'SKIP';
    else
        datalength = [];
        cksum      = [];   
        return
    end
    
end

function check = checksum( message, checktype )
%CHECKSUM calculates the checksum for the given data
% This checksum is the lsb of the sum of 16 bit input data and made for ZXW
% gps interface
%
% INPUT
% DATA - Decimal fields
%
% OUTPUT
% CKSUM - The sum of unsigned shorts
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    % It accepts either row or collumn vectors
    [i,j] = size(message);
    if i>1 && j>1
        error('checksum: INPUT DATA should be a vector or row');
    end
    
    dim   = max(i,j); cksum = 0;
    if strcmpi(checktype,'16b')
        txchecksum   = u2(message(end-1:end),'bigendian'); % Store tx checksum
        message(end-1:end) = []; % Remove tx checksum
        dim = dim - 2;
        for i = 1:2:dim
           cksum = cksum + u2(message(i:i+1),'bigendian');
        end
        cksum = bitand(cksum,2^16-1);
        
    elseif strcmpi(checktype,'xor') 
        txchecksum   = message(end); % Store tx checksum
        message(end) = [];       % Remove tx checksum
        dim = dim-1;
        cksum = 0;
        for i = 1:dim
            cksum = bitxor(cksum,message(i));
        end
        
    elseif strcmpi(checktype,'SKIP')
        txchecksum = 1;
        cksum      = 1;
        
    else
        txchecksum = 0;
        cksum      = 1;
    end
    
    % Verifies if the checksum is correct
    check = txchecksum == cksum;
    
end

function [message] = parsemsg( msgID, payload, message )
%PARSEMSG is a parser for ASHTECH replies
% This function parses the data read from the receiver and returns the
% decoded fields
%
% INPUT
% MSGID - Message ID
% payload  - Message payload
% VARARGIN - Message specific input
%
% OUTPUT
% VARARGOUT - Message specific output
%
% Pedro Silva, Instituto Superior Tecnico, Janeiro 2012

    % DBN MESSAGE - Pseudorange and carrier phase
    if strcmpi(msgID,'RPC')
        message.ranges = decodeRPC(payload);
    
    % DPC MESSAGE - Pseudorange message with time information
    elseif strcmpi(msgID,'DPC')
        message.ranges = decodeDPC(payload);
        
    % SNV MESSAGE - Processed Ephemerides
    elseif strcmpi(msgID,'SNV')
        message.eph   = decodeSNV(payload,message.eph);
    
    % MPC MESSAGE - Measurements SNR, CA, PR, CP, DOPPLER
    elseif strcmpi(msgID,'MPC')
        if message.ranges.LEFT == 0 % with old data
            message.ranges = ashtechstructs('MPC');
            message.nbEpoch = message.nbEpoch + 1;
        end
        message.ranges  = decodeMPC(payload,message.ranges,message.UTCoffset);
        
        
    % ION MESSAGE - Contains ionosphere information
    elseif strcmpi(msgID,'ION')
        message.iono = decodeION(payload);
    
    
    % TIMING MESSAGE - PFS,<DATA UTC>,<RATE EM MS>,<PRIMEIRA SEQUENCE TAG>
    elseif strcmpi(msgID,'PFS')
        % 14 data     - yyyyMMddHHmmss
        % 7 rate
        % 10 seq tag
        % 
        comma  = char(payload) == ',';
        numvec = 1:length(payload);
        comma  = numvec(comma);
        reftime = payload(1:comma(1)-1);
        message.rate    = payload(comma(1)+1:comma(2)-1);
        message.refseq  = payload(comma(2)+1:end);
        
        reftime = char(reftime)';
        message.year    = str2double(reftime(1:4));
        message.month   = str2double(reftime(5:6));
        message.day     = str2double(reftime(7:8));
        message.hour    = str2double(reftime(9:10));
        message.min     = str2double(reftime(11:12));
        message.sec     = str2double(reftime(13:14));
        message.stime   = datenum(message.year,message.month,message.day,message.hour,message.min,message.sec);
        message.rate    = str2double(num2str(char(message.rate)'))*1e-03;
        message.refseq  = str2double(num2str(char(message.refseq)'));
        
    else
    %donothing  
    disp(msgID);
    end

end

function sFile = storeparsing(sFile,parsing)

        if strcmpi(parsing.msgID,'MPC') && parsing.ranges.LEFT == 0
            sats            = parsing.ranges.SATLIST(parsing.ranges.SATLIST > 0);
            ranges          = parsing.ranges;
            iEpoch          = parsing.nbEpoch + 1;
            
            sFile.ranges.WARNINGCA(iEpoch,sats) = ranges.WARNINGCA(sats);
            sFile.ranges.QUALITYCA(iEpoch,sats) = ranges.QUALITYCA(sats);
            sFile.ranges.SNRCA(iEpoch,sats)     = ranges.SNRCA(sats);
            sFile.ranges.CPCA(iEpoch,sats)      = ranges.CPCA(sats);
            sFile.ranges.PRCA(iEpoch,sats)      = ranges.PRCA(sats);
            sFile.ranges.DOCA(iEpoch,sats)      = ranges.DOCA(sats);
            sFile.ranges.BFCA(iEpoch,sats)      = ranges.BFCA(sats);
            sFile.ranges.WARNINGL1(iEpoch,sats) = ranges.WARNINGL1(sats);
            sFile.ranges.QUALITYL1(iEpoch,sats) = ranges.QUALITYL1(sats);
            sFile.ranges.SNRL1(iEpoch,sats)     = ranges.SNRL1(sats);
            sFile.ranges.CPL1(iEpoch,sats)      = ranges.CPL1(sats);
            sFile.ranges.PRL1(iEpoch,sats)      = ranges.PRL1(sats);
            sFile.ranges.DOL1(iEpoch,sats)      = ranges.DOL1(sats);
            sFile.ranges.BFL1(iEpoch,sats)      = ranges.BFL1(sats);
            sFile.ranges.WARNINGL2(iEpoch,sats) = ranges.WARNINGL2(sats);
            sFile.ranges.QUALITYL2(iEpoch,sats) = ranges.QUALITYL2(sats);
            sFile.ranges.SNRL2(iEpoch,sats)     = ranges.SNRL2(sats);
            sFile.ranges.CPL2(iEpoch,sats)      = ranges.CPL2(sats);
            sFile.ranges.PRL2(iEpoch,sats)      = ranges.PRL2(sats);
            sFile.ranges.DOL2(iEpoch,sats)      = ranges.DOL2(sats);
            sFile.ranges.BFL2(iEpoch,sats)      = ranges.BFL2(sats);
            sFile.ranges.SATELV(iEpoch,sats)    = ranges.SATELV(sats);
            sFile.ranges.SATAZ(iEpoch,sats)     = ranges.SATAZ(sats);
            sFile.ranges.SATLIST(iEpoch,sats)   = ranges.SATLIST(sats);
            
            sFile.ranges.SEQGLO(iEpoch)         = ranges.SEQGLO;
            sFile.ranges.SEQ(iEpoch)            = ranges.SEQ;
            
            if sFile.ranges.SEQ(iEpoch) == 0 || sFile.ranges.SEQ(iEpoch) ==  35960
                pause(0.1);
            end
            
            if isnan(sFile.stime)
                sFile.stime = parsing.stime;    
                clk    = datevec(sFile.stime);
                hour   = clk(4);
                min    = clk(5);
                sFile.tow    = seqtotow(ranges.SEQ,parsing.UTCoffset,hour,min,sFile.wd);
                sFile.towglo = seqtotow(ranges.SEQGLO,parsing.UTCoffset,hour,min,sFile.wd);
            else
                % Checks how many minutes have gone by 
                leap = mod((sFile.ranges.SEQ(iEpoch) - sFile.ranges.SEQ(iEpoch-1)),36000);
                if leap == 0
                   leap = sFile.rate*20; 
                end
                sFile.tow    = sFile.tow + leap*50e-03;
                sFile.towglo = sFile.towglo + leap*50e-03;
            end
            

            
            sFile.ranges.TOWGLO(iEpoch,1) = sFile.towglo;
            sFile.ranges.TOW(iEpoch,1)    = sFile.tow;
            sFile.ranges.WN(iEpoch,1)     = ranges.WN;
            

            % Increments global time
            parsing.nbEpoch = iEpoch;
            
        elseif strcmpi(parsing.msgID,'SNV')
            eph                  = parsing.eph;
            id                   = eph.update;
            sFile.eph.data(:,id) = eph.data(:,id);


%                 oldeph = sFile.eph(:,id);                
%                 % If no new information, continue
%                 if eph.data == oldeph
%                     continue;    
% 
%                 % save it
%                 else
%                     
%                 end

        elseif strcmpi(parsing.msgID,'PFS')
            sFile.wd = weekday(parsing.stime)-1; 
            sFile.rate = parsing.rate;
        end
end
