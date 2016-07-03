function [ sEph ] = buildsEph( eph )
%BUILDSEPH Converts eph data from matrix style to struct
%   The objective of the function is to translate the eph data to a
%   structure order to ease the development and debugging of the code. Thus
%   it helps the code to keep its independece from input type or style.
%
%   INPUT
%   EPH  - Ephemerides data in a matrix style
%   TYPE - Switcher to allow different styles of input matrixes
%
%   OUTPUT
%   sEph - Structure output

    persistent Eph;

    if isempty(Eph)
        % Ephemerides structure if NaN when no data is available
        Eph = struct(...
            'satid',NaN,'weeknb',NaN,'codel2',NaN,'ura',NaN,...
            'health',NaN,'iodc',NaN,'l2pf',NaN,'tgd',NaN,'toc',NaN,...
            'af2',NaN,'af1',NaN,'af0',NaN,'iode',NaN,...
            'toe',NaN,'fif',NaN,'mo',NaN,'ecc',NaN,'sqra',NaN,...
            'deltan',NaN,'omega0',NaN,'i0',NaN,'omega',NaN,...
            'omegadot',NaN,'idot',NaN,'crc',NaN,'crs',NaN,'cuc',NaN,...
            'cus',NaN,'cic',NaN,'cis',NaN,'tow',NaN);        
    end

    if size(eph,1) < 31
        error('Not enough ephemerides data available');
    end
    
    if size(eph,2) == 0
        error('Ephemerides data unavailable');
    end

    sEph          = Eph;
    sEph.satid    = eph(ephidx('sid'),:);
    sEph.weeknb   = eph(ephidx('wn'),:);
    sEph.ura      = eph(ephidx('ura'),:);
    sEph.iodc     = eph(ephidx('iodc'),:);
    sEph.tgd      = eph(ephidx('tgd'),:);
    sEph.toc      = eph(ephidx('toc'),:);
    sEph.af2      = eph(ephidx('af2'),:);
    sEph.af1      = eph(ephidx('af1'),:);
    sEph.af0      = eph(ephidx('af0'),:);
    sEph.toe      = eph(ephidx('toe'),:);    
    sEph.mo       = eph(ephidx('M0'),:);
    sEph.ecc      = eph(ephidx('ecc'),:);
    sEph.sqra     = eph(ephidx('sqra'),:);
    sEph.deltan   = eph(ephidx('dn'),:);
    sEph.omega0   = eph(ephidx('omega0'),:);
    sEph.i0       = eph(ephidx('i0'),:);
    sEph.omega    = eph(ephidx('omega'),:);
    sEph.omegadot = eph(ephidx('omegadot'),:);
    sEph.idot     = eph(ephidx('idot'),:);
    sEph.crc      = eph(ephidx('crc'),:);
    sEph.crs      = eph(ephidx('crs'),:);
    sEph.cuc      = eph(ephidx('cuc'),:);
    sEph.cus      = eph(ephidx('cus'),:);
    sEph.cic      = eph(ephidx('cic'),:);
    sEph.cis      = eph(ephidx('cis'),:);
%         sEph.tow      = eph(ephidx('tow'));
    %lesser
    sEph.codel2   = eph(ephidx('codel2'),:);
    sEph.health   = eph(ephidx('health'),:);
    sEph.l2pf     = eph(ephidx('l2p'),:);
    sEph.iode     = eph(ephidx('iode'),:);
    sEph.fif      = eph(ephidx('fif'),:);
        

    

end
