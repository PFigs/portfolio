function [ st ] = ubloxstructs( type, varargin )
%UBLOXSTRUCTS returns a structure object 
%   This function objective is to allow easy access to structure
%   declaration in order to improve code reading.
%
%   These structures are receiver specific, ASHTECH
%
%   INPUT
%   TYPE - Type of structure to be returned
%
%   OUTPUT
%   ST - Structure object
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    % CHECK INPUTS
    if ~ischar(type), 
        error('readparam: TYPE must be a string'); 
    end;
       
    if strcmpi(type,'RAW')
       satNo  = userparams('MAXSAT');
       st  =   struct(...
                     'msgID','RAW',...
                     'WARNINGL1', zeros(1,satNo),'QUALITYL1', zeros(1,satNo),...               
                     'SNRL1', zeros(1,satNo),'CPL1', zeros(1,satNo),...               
                     'PRL1', zeros(1,satNo),'DOL1', zeros(1,satNo),...
                     'SATELV', zeros(1,satNo),'SATAZ', zeros(1,satNo),...
                     'SATLIST', zeros(1,satNo),...
                     'TOW' , NaN, 'WN', NaN, 'LEFT',NaN);  
            
    elseif strcmpi(type,'ION')
        st  =  struct(...
               'msgID','ION',...
               'health', 0, 'utcA0', 0, 'utcA1', 0, 'utcTOW', 0,...
               'utcWNT', 0, 'utcLS', 0, 'utcWNF', 0, 'utcDN', 0,...
               'utcLSF', 0, 'utcSpare', 0, 'alpha', zeros(4,1),...
               'beta', zeros(4,1), 'fhealth', 0, 'futc', 0,...
               'fklob', 0);
            
    elseif strcmpi(type,'EPH')
        ArgsNo = userparams('EPHARGS'); % Number of arguments in the eph message
        SatNo  = userparams('MAXSAT'); % Number of satellites    
        st     = struct('msgID','EPH','update',NaN,...
                        'data',zeros(ArgsNo+1,SatNo)); % +1 for TOW
    end


end

