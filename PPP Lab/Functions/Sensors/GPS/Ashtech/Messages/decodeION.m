function [ iono ] = decodeION( payload )
%DECODEION decodes ION payload
%   This message contains information regarding the ionosphere thus
%   allowing ionosphere correction
%
%   INPUT
%   PAYLOAD - message payload
%
%   OUTPUT
%   RANGES  - structure with parsed payload
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    % Retrieves ION structure
    iono = ashtechstructs('ION');
    
    % Decodes Payload
    iono.alpha(1) = r4(payload(1:4),'bigendian');
    iono.alpha(2) = r4(payload(5:8),'bigendian');
    iono.alpha(3) = r4(payload(9:12),'bigendian');
    iono.alpha(4) = r4(payload(13:16),'bigendian');
    iono.beta(1)  = r4(payload(17:20),'bigendian');
    iono.beta(2)  = r4(payload(21:24),'bigendian');
    iono.beta(3)  = r4(payload(25:28),'bigendian');
    iono.beta(4)  = r4(payload(29:32),'bigendian');
    
    iono.utcA1    = r8(payload(33:40),'bigendian'); % First order terms of polynomial
    iono.utcA0    = r8(payload(41:48),'bigendian'); % Constant terms of polynomial  
    
    iono.utcTOT   = i4(payload(49:52),'bigendian'); % Reference time for UTC data
    iono.utcWNT   = i2(payload(53:54),'bigendian'); % UTC reference week number
    iono.utcDTLS  = i2(payload(55:56),'bigendian'); % GPS-UTC differences at reference time
    iono.utcWNLSF = i2(payload(57:58),'bigendian'); % Week number when leap second became effective
    iono.utcDN    = i2(payload(59:60),'bigendian'); % Day number when leap second became effective
    iono.utcDTLSF = i2(payload(61:62),'bigendian'); % Delta time between GPS and UTC after correction
    iono.WN       = i2(payload(63:64),'bigendian'); % GPS week number
    
    iono.TOW      = u4(payload(65:68),'bigendian'); % Time of the week (in seconds)
    iono.bulwn    = u2(payload(69:70),'bigendian'); % GPS week number when message was read
    iono.bultow   = u4(payload(71:74),'bigendian'); % Time of the week when message was read
    
end
