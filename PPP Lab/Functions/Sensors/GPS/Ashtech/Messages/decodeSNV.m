
function eph = decodeSNV( data, eph )
%DECODESNV decodes SNV data payload
%
% INPUT
% DATA - Message payload
%
% OUTPUT
% EPH - Structure with ephemerides data
% TOW - Time of week
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    satid                             = data(129)+1; % SVN -1 is sent
    eph.update                        = satid; % Sat with recent data
    eph.data(ephidx('SID') , satid)   = satid; % SATID
    eph.data(ephidx('TOW') , satid)   = u4(data(3:6),'bigendian'); %time of week
    eph.data(ephidx('wn')  , satid)   = u2(data(1:2),'bigendian');    
    eph.data(ephidx('tgd') , satid)   = r4(data(7:10),'bigendian');  
    eph.data(ephidx('iodc'), satid)   = u4(data(11:14),'bigendian'); 
    eph.data(ephidx('TOC') , satid)   = u4(data(15:18),'bigendian'); 
    eph.data(ephidx('af2') , satid)   = r4(data(19:22),'bigendian'); 
    eph.data(ephidx('af1') , satid)   = r4(data(23:26),'bigendian'); 
    eph.data(ephidx('af0') , satid)   = r4(data(27:30),'bigendian'); 
    eph.data(ephidx('IODE'), satid)   = u4(data(31:34),'bigendian'); 
    eph.data(ephidx('DN')  , satid)   = r4(data(35:38),'bigendian')*pi; %to circles
    eph.data(ephidx('M0')  , satid)   = r8(data(39:46),'bigendian')*pi; %to circles 
    eph.data(ephidx('ECC') , satid)   = r8(data(47:54),'bigendian');
    eph.data(ephidx('SQRA'), satid)   = r8(data(55:62),'bigendian'); 
    eph.data(ephidx('TOE') , satid)   = u4(data(63:66),'bigendian'); 
    eph.data(ephidx('CiC') , satid)   = r4(data(67:70),'bigendian'); 
    eph.data(ephidx('CrC') , satid)   = r4(data(71:74),'bigendian'); 
    eph.data(ephidx('CiS') , satid)   = r4(data(75:78),'bigendian'); 
    eph.data(ephidx('CrS') , satid)   = r4(data(79:82),'bigendian'); 
    eph.data(ephidx('CuC') , satid)   = r4(data(83:86),'bigendian'); 
    eph.data(ephidx('CuS') , satid)   = r4(data(87:90),'bigendian'); 
    eph.data(ephidx('Omega0'), satid) = r8(data(91:98),'bigendian')*pi;   %to circles
    eph.data(ephidx('Omega') , satid) = r8(data(99:106),'bigendian')*pi;  %to circles
    eph.data(ephidx('i0')    , satid) = r8(data(107:114),'bigendian')*pi; %to circles 
    eph.data(ephidx('Omegadot'),satid)= r4(data(115:118),'bigendian')*pi; %to circles 
    eph.data(ephidx('IDOT')  , satid) = r4(data(119:122),'bigendian')*pi; %to circles 
    eph.data(ephidx('URA')   , satid) = uratometer(u2(data(123:124),'bigendian')); 
    eph.data(ephidx('Health'), satid) = u2(data(125:126),'bigendian'); 
    eph.data(ephidx('FIF'), satid)    = u2(data(127:128),'bigendian'); 
    
end
