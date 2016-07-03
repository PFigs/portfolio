function [ iono ] = decodeAIDHUI( payload )
%DECODEAIDHUI decodes AID's HUI payload
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
    iono = ubloxstructs('ION');
    
    % Decodes Payload
    iono.health   = x4(payload(1:4));
    iono.utcA0    = r8(payload(5:12));   
    iono.utcA1    = r8(payload(13:20));
    iono.utcTOW   = i4(payload(21:24));
    iono.utcWNT   = i2(payload(25:26));
    iono.utcLS    = i2(payload(27:28));
    iono.utcWNF   = i2(payload(29:30));
    iono.utcDN    = i2(payload(31:32));
    iono.utcLSF   = i2(payload(33:34));
    iono.utcSpare = i2(payload(35:36));
    iono.alpha(1) = r4(payload(37:40));
    iono.alpha(2) = r4(payload(41:44));
    iono.alpha(3) = r4(payload(45:48));
    iono.alpha(4) = r4(payload(49:52));
    iono.beta(1)  = r4(payload(53:56));
    iono.beta(2)  = r4(payload(57:60));
    iono.beta(3)  = r4(payload(61:64));
    iono.beta(4)  = r4(payload(65:68));
    bitfield      = x4(payload(69:72));
    iono.fhealth  = bitfield(1);
    iono.futc     = bitfield(2);
    iono.fklob    = bitfield(3);


end

