function sSettings = getinput( varargin )
%GETINPUT prompts the user about operation and day of year
%   The function is responsible to ask the user the necessary initial
%   setttings for the algorithm to work
%
%   AVAILABLE RECEIVERS
%   'proflex';
%   'zxw';
%   'ac12';
%   'ublox';
%
%   DEFAULT MESSAGES
%   FOR AC12 (SF):
%       'MCA,SNV';     
%
%   FOR UBLOX (SF):
%       'EPH,HUI,RAW';
%   
%   FOR PF500 (DF):
%       'SNV,MPC';     
%
%   FOR ZXW (DF):    
%       'SNV,MBN';     
%       'SNV,DBN'; %RPC
%
%
%   AVAILABLE ALGORYTHMS
%   'spp';    % Standard SPP
%   'igstesting'; % Testing purposes
%
%   INPUT
%   VARARGIN - Change between 'default' or 'full'/'setup' modes
%
%   OUTPUT
%   MODE     - OFFLINE or ONLINE
%   DOY      - Day of Year
%   RECEIVER - Receiver's name
%   SKIPCFG  - Flag for skipping configuration
%   MESSAGES - Receiver messages
%   ALGTYPE  - Algorythm to use
%
% Pedro Silva, Instituto Superior Tecnico, January 2012
    
    sSettings = ppplabstructs('Settings');
    % Default vars
    sSettings.receiver.reset     = 0;
    sSettings.receiver.configure = 1;
    sSettings.receiver.logging   = 1;
    sSettings.receiver.com       = 'COM1';
    sSettings.operation          = 'offline'; % default
    sSettings.receiver.messages  = 'SNV,MPC';
    sSettings.receiver.name      = 'proflex';
    sSettings.algorithm.name     = 'spp';
    sSettings.algorithm.freqmode = 'L1';
    sSettings.time.doy           = dayofyear(2012, 08, 03);  % Dados salgueiro
  
     if nargin >= 1 && ~mod(nargin,2)
       for i=1:2:size(varargin,2)
           if strcmpi(varargin{i},'algo') || strcmpi(varargin{i},'algtype');
               sSettings.algorithm.name  = varargin{i+1};
           elseif strcmpi(varargin{i},'receiver')
               sSettings.receiver.name = varargin{i+1};
           elseif strcmpi(varargin{i},'freqmode')
               sSettings.algorithm.freqmode = varargin{i+1};
           elseif strcmpi(varargin{i},'inputpath')
               sSettings.file.folderpath = varargin{i+1};
           elseif strcmpi(varargin{i},'mode')
               sSettings.operation = varargin{i+1};
           end
       end
    end
    
    
    % Enters full setup
    if nargin && strcmpi(varargin{1},'full') || strcmpi(varargin{1},'setup')
        
        % Decision about which receiver to use
        while 1
            receiver = input('Which receiver will you use? (<Name> or Help) ','s');
            if strcmpi(receiver,'H') || strcmpi(receiver,'help')
                disp('Receivers available:');
                fprintf('\t- Proflex\n\t- ZXW\n\t- Ublox\n\t- AC12\n');
            elseif strcmpi(receiver,'ublox') || strcmpi(receiver,'zxw') || ...
                   strcmpi(receiver,'proflex') || strcmpi(receiver,'ac12')
                break;
            end
        end
        sSettings.receiver.name = receiver;
        
        % Ask for operation mode
        while 1
            mode = input('Operation mode: ','s');
            if strcmpi(mode,'offline') || strcmpi(mode,'online')
               operation = 1;
               break; 
            elseif strcmpi(mode,'')
                mode = 'offline'; % default
                operation = 0;
                break
            end
        end
        sSettings.operation = mode;
        
        % Ask for COM port
        while 1
            com = input('COM port (COMX): ','s');
            if strcmpi(com(1:3),'COM') && length(com)>=4
               break; 
            elseif strcmpi(mode,'')
                com = 'COM1'; % default
                break
            end
        end        
        sSettings.receiver.com = com;
        
        % Obtains the day of the year
        while 1
            if operation
                clk = clock;
                doy = dayofyear(clk(1),clk(2),clk(3));
                break;
            else
                disp('Please input date of acquisition');
                default = input('Default? 14 DEZ 2011? (Y/N): ','s');
                if strcmpi(default,'Y') || strcmpi(default,'')
                    year  = 2011;
                    month = 12;
                    day   = 14;
                else
                    year  = input('Year  (xxxx): ');
                    month = input('Month (1-12): ');
                    day   = input('Day   (1-31): ');
                end
                doy = dayofyear(year, month, day);
                break;
            end
        end
        sSettings.time.doy = doy;
        
        % Decision about receiver reset
        while 1
            reset = input('Perform a reset? (Y/N) ','s');
            if strcmpi(reset,'Y') || strcmpi(reset,'')
                reset = 1;
                break;
            else
                reset = 0;
                break;
            end
        end
        sSettings.receiver.reset = reset;
        
        % Decision about receiver configuration
        while 1
            configure = input('Perform receiver configuration? (Y/N) ','s');
            if strcmpi(configure,'N') || strcmpi(configure,'')
                configure = 0;
                break;
            else
                configure = 1;
                disp('Which messages shall I configure?');
                disp('Type h or help for assistance.');
                while 1
                    messages = input('(Help, Messages or Default for receiver default) ','s');
                    if strcmpi(messages,'h') || strcmpi(messages,'help')
                        disp('Messages must be separated by a comma');
                        disp('For example, ''MBN,SVN,EPH''');
                        fprintf('D or Default will use %s''s default',receiver);
                    end
                    
                    % Configures default messages for previous receiver
                    if strcmpi(messages,'d') || strcmpi(messages,'default')
                        if strcmpi(receiver,'zxw')
                            messages = 'SNV,DBN'; %MBN
                            break;    
                        elseif strcmpi(receiver,'proflex')
                            messages = 'SNV,DPC,ION';
                            break;
                        elseif strcmpi(receiver,'ublox')
                            messages = 'EPH,HUI,RAW';
                            break;
                        elseif strcmpi(receiver,'ac12')
                            messages = 'MCA,SNV';
                            break;
                        end
                        disp('Default messages for given receiver not found');
                    else
                        fprintf('\tUsing %s\n',messages);
                        break;
                    end
                end
                sSettings.receiver.messages = messages;
                break;
            end
        end
        sSettings.receiver.configure = configure;
        
        % Decision regarding algorythm to use
        while 1
            algtype = input('Which algorythm shall I use? (<Name> or Help) ','s');
            if strcmpi(algtype,'H') || strcmpi(algtype,'help')
                disp('Algorythms available:');
                fprintf('\t- spp\n\t- \n\t- igstesting\n\t- ...\n');
            elseif strcmpi(algtype,'spp') || strcmpi(algtype,'igstesting') || strcmpi(algtype,'sppdf')
                break;
            end
        end
        sSettings.algorithm.name = algtype;
        
    elseif nargin && strcmpi(varargin{1},'load') || strcmpi(varargin{1},'last')
        if exist('.session.mat','file')
            load('.session.mat');
            if strcmpi('ONLINE',mode)
                clk = clock;
                sSettings.time.doy = dayofyear(clk(1),clk(2),clk(3));
            end
        end
    end
    
    sSettings.receiver.logpath   = 'Aquisition/';
    
    % Displays information
    if strcmpi('ONLINE',sSettings.operation)
        fprintf('Initialising %s on %s...\n',sSettings.receiver.name,sSettings.receiver.com);
        fprintf('\tAt day ''%d'' of the year\n',sSettings.time.doy);
        fprintf('\tRESET flag set to %d...\n',sSettings.receiver.reset);
        fprintf('\tCONFIGURATION flag set to %d...\n',sSettings.receiver.configure);
        fprintf('\tMESSAGES ''%s'' will be sent...\n',sSettings.receiver.messages);
        save('.session.mat');
    else
        fprintf('OFFLINE processing\n');
        fprintf('\tALGORYTHM ''%s'' will be used...\n',sSettings.algorithm.name);
        fprintf('\tFREQUENCY MODE ''%s'' will be used...\n',sSettings.algorithm.freqmode);
    end
        
end

