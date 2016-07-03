function [ ranges ] = decodeRXMRAW( payload )
%DECODERXMRAW decodes RXM's RAW data payload
%
%   INPUT
%   PAYLOAD - message data
%
%   OUTPUT
%   RANGES  - structure with parsed data
%
% Pedro Silva, Instituto Superior Tecnico, January 2012
        
        % Initialisations
        nSat   = double(payload(7));
        ranges = ubloxstructs('RAW',nSat);
        
        % Retrieves data from the message
        ranges.TOW   = i4(payload(1:4))*1e-03;
        ranges.WN    = i2(payload(5:6));
        for k=0:nSat-1
            nBlock = 24*k;
            satid                   = payload(29+nBlock);
            ranges.SATLIST(satid)   = satid;
            ranges.CPL1(satid)      = r8(payload(9+nBlock:16+nBlock)); 
            ranges.PRL1(satid)      = r8(payload(17+nBlock:24+nBlock)); 
            ranges.DOL1(satid)      = r4(payload(25+nBlock:28+nBlock)); 
            ranges.QUALITYL1(satid) = tc2dec(payload(30+nBlock),8); 
            ranges.SNRL1(satid)     = tc2dec(payload(31+nBlock),8); 
            ranges.WARNINGL1(satid) = payload(32+nBlock);    
        end
        
end

