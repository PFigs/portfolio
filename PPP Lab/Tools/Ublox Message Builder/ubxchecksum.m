function [ cksum, cka, ckb ] = ubxchecksum( data )
%CHECKSUM computes the 8 bit fletcher checksum
%   An hex string is returned along side the values of CKA and CKB
%
%   INPUT
%   DATA - The message (in ascii) which checksum is to be calculated
%
%   OUTPUT
%   CKSUM - HEX string with the checksum
%   CKA   - CKA value
%   CKB   - CKB value
%
%   Pedro Silva, Instituto Superior Tecnico, July 2011
%   Last revision: January 2012
    cka = 0;
    ckb = 0;
    for i=1:length(data)
        cka = cka + data(i);
        ckb = ckb + cka;
    end;
    
    cka = mod(cka,256);
    ckb = mod(ckb,256);
    
    cksum = sprintf('%02x%02x',cka,ckb);
    
end