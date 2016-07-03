function [ param ] = earthparams(symbol)
%EARTHPARAMS returns a constant for a given symbol related to the WGS84
%earth model
%   This function objective is to return a constant value regarding
%   specific values in several earth models. Currently only WGS84 is
%   supported but if interest grows, other models can be further deployed.
%   This can be achieved by using varargin and a switch case to decide
%   which model the user is using
% 
%   INPUT
%       SYMBOL - symbol which value should be returned
%
%   OUTPUT
%       PARAM  - value
%
%   REFERENCE
%   http://www.bipm.org/en/CGPM/db/3/2/
%
%   Pedro Silva, Instituto Superior Técnico, November 2011

    persistent gforce;
    persistent semimajor;
    persistent flatenning flatGRS80;
    persistent earthrad;
    persistent earthgrav;
    persistent angularvel;

    if ~ischar(symbol)
        error('earthparams: SYMBOL must be a char');
    end

    if isempty(gforce)
        gforce     = 9.80665;
        semimajor  = 6378137.0;
        flatenning = 1/298.257223563; %wgs84
        flatGRS80  = 1/298.257222101; %GRS80
        earthrad   = 6378137;
        earthgrav  = 3986005e08;
        angularvel = 7.2921151467e-5;
    end
    
    if strcmpi(symbol,'A')
        % semi-major
        param = semimajor;
    elseif strcmpi(symbol, 'F')
        % flatenning
        param = flatenning; 
        
    elseif strcmpi(symbol, 'FGRS80')
        param = flatGRS80; 
    elseif strcmpi(symbol, 'R')
        % earth radius        
        param = earthrad;
    elseif strcmpi(symbol, 'G')
        % Earth gravitaniotal constant
        param = earthgrav;
    elseif strcmpi(symbol, 'OMEGAE')
        % Angular velocity for the Earth rotation
        param = angularvel; 
    elseif strcmpi(symbol, 'gforce')
        param = gforce;
    else
        error('earthparams: SYMBOL not found!');
    end
    
end

