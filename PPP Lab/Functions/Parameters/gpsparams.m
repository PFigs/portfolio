function [ param ] = gpsparams(symbol)
%EARTHPARAMS returns a constant for a given symbol related to the WGS84
%earth model
%   This function objective is to return a constant value regarding
%   specific values in several earth models. Currently only WGS84 is
%   supported but if interest grows, other models can be further deployed.
%   This can be achieved by using varargin and a switch case to decide
%   which model the user is using

%   INPUT
%       SYMBOL - symbol which value should be returned

%   OUTPUT
%       PARAM  - value

%   Pedro Silva, Instituto Superior Técnico, November 2011

    if ~ischar(symbol)
        error('gpsparams: SYMBOL must be a char');
    end
    
    persistent f1 f2 lbdf1 lbdf2 lbdfw lbdfn;
    persistent c miu gama lbdif doff;
    
    
    if isempty(f1)
        f1   = 1575.42e06;
        f2   = 1227.60e06;
        c    = 299792458;
        miu  = 3986004.418;
        gama = (77/60)^2; % gama fl1/fl2
        doff = 429496;
        lbdf1 = c/f1;
        lbdf2 = c/f2;
        lbdfw = c/(f1-f2);
        lbdfn = c/(f1+f2);
        lbdif = (1575.42^2)/(1575.42^2-1227.60^2)*(299792458/1575.42e6) ...
                - (1227.60^2)/(1575.42^2-1227.60^2)*(299792458/1227.60e6);
    end
    
    if strcmpi(symbol,'f1')
        param = f1;
    
    elseif strcmpi(symbol,'f2')
        param = f2;
    
    elseif strcmpi(symbol, 'C')
        param = c;
    
    elseif strcmpi(symbol, 'gama')
        param = gama;
    
    elseif strcmpi(symbol, 'miu')
        param = miu;        
        
    elseif strcmpi(symbol, 'lbdif')
        param = lbdif;
        
    elseif strcmpi(symbol, 'lbdfn')
        param = lbdfn;
        
    elseif strcmpi(symbol, 'lbdf1')
        param = lbdf1;
        
    elseif strcmpi(symbol, 'lbdf2')
        param = lbdf2;
    
    elseif strcmpi(symbol, 'lbdfw')
        param = lbdfw;
               
    elseif strcmpi(symbol, 'doffset') % Doppler offset
        param = doff;
        
    else
        error('gpsparams: SYMBOL not found!');
    end
    
end


