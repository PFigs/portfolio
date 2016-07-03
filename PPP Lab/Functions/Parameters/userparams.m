function [ param ] = userparams( symbol )
%READCUSTOMFILEPARAMS returns a constant for a given symbol
%   This function objective is to initialize some considerations made
%   during the readcustomfile function
%
%   INPUT
%       SYMBOL - symbol which value should be returned
%
%   OUTPUT
%       PARAM  - value
%
%   Pedro Silva, Instituto Superior Técnico, November 2011
  
    if nargin == 0
        symbol = 'none';
    end

    persistent TOL CONV TH WATCHDOG;
    persistent RYEAR RWEEK STATIC KINET;
    persistent LARRAY RCVBUFF;
    persistent MASKELV MASKGNSS MASKSNR MASKURA;
    persistent MAXSAT EPHARGS RESLIMIT;
    
    if isempty(TOL)
        TOL      = 1e-06;
        TH       = 5;
        RYEAR    = 2011;
        RWEEK    = 1616;
        LARRAY   = 1000;
        MAXSAT   = 32;
        EPHARGS  = 31;
        RCVBUFF  = 100000;
        MASKGNSS = 32;
        MASKSNR  = 0;
        WATCHDOG = 500;
        MASKELV  = rad(5);
        CONV     = -1;
        STATIC   = 15;
        KINET    = inf;
        MASKURA  = 10;
        RESLIMIT = 100;
    end
    
    if strcmpi(symbol,'TOLERANCE') || strcmpi(symbol,'TOL')
        param = TOL; % Algorithm's error tolerance
    elseif strcmpi(symbol,'TH')
        param = TH;     
    elseif strcmpi(symbol,'maskGNSS')
        param = MASKGNSS;     
    elseif strcmpi(symbol,'maskSNR')
        param = MASKSNR;             
    elseif strcmpi(symbol,'MASKELV')
        param = MASKELV;
    elseif strcmpi(symbol,'MASKURA')
        param = MASKURA;        
    elseif strcmpi(symbol,'MAXSAT')
        param = MAXSAT;   % Number of max satellites
    elseif strcmpi(symbol,'EPHARGS')
        param = EPHARGS;   % Number of arguments to read in ephemerides file
    elseif strcmpi(symbol,'LARGEARRAY')
        param = LARRAY;   % Default value for a large array 
    elseif strcmpi(symbol,'reference Year')
        param = RYEAR;  % Year reference for function pullfile:getweeknum
    elseif strcmpi(symbol,'reference week')
        param = RWEEK;  % Week reference for function pullfile:getweeknum
    elseif strcmpi(symbol,'receiverbuffer')
        param = RCVBUFF;
    elseif strcmpi(symbol,'visiblewatchdog')
        param = WATCHDOG;
    elseif strcmpi(symbol,'initialconv')
        param = CONV;
    elseif strcmpi(symbol,'static')
        param = STATIC;
    elseif strcmpi(symbol,'dynamic')
        param = KINET;        
    elseif strcmpi(symbol,'reslimit')        
        param = RESLIMIT;
    elseif strcmpi(symbol,'smooth')
        param = 250;
    else
        fprintf('TOLERANCE: %f\n',TOL);
        fprintf('MASKGNSS: %f\n',MASKGNSS);
        fprintf('MASKSNR: %f\n',MASKSNR);
        fprintf('MASKELV: %f\n',MASKELV);
        fprintf('MAXSAT: %f\n',MAXSAT);
        fprintf('TH: %f\n',TH);
        disp('and others...');
        error('userparams: check valid symbols!');
    end

end

% function printvalid()
%     fprintf('TOLERANCE: %f\n',TOL);
%     fprintf('MASKGNSS: %f\n',MASKGNSS);
%     fprintf('MASKELV: %f\n',MASKSNR);
%     fprintf('MASKELV: %f\n',MASKELV);
%     fprintf('MAXSAT: %f\n',MAXSAT);
%     disp('and others...');
% end