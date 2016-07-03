function [ str ] = idxtoephfield( idx )
%IDXTOEPHFIELD Summary of this function goes here
%   Detailed explanation goes here
    if idx == 1
        str = 'SID';
    elseif idx == 2
        str = 'WN';
    elseif idx == 3
        str = 'CodeL2';
    elseif idx == 4;
        str = 'URA';
    elseif idx == 5
        str = 'Health';
    elseif idx == 6
        str = 'IODC';
    elseif idx == 7
        str = 'L2P';
    elseif idx == 8
        str = 'TGD';
    elseif idx == 9
        str = 'TOC';
    elseif idx == 10
        str ='AF2';
    elseif idx == 11
        str = 'AF1';
    elseif idx == 12
        str = 'AF0';
    elseif idx == 13
        str = 'IODE';
    elseif idx == 14
        str = 'IODESF3';
    elseif idx == 15
        str = 'TOE';
    elseif idx == 16
        str = 'FIF';
    elseif idx == 17
        str = 'M0';
    elseif idx == 18
        str ='ECC';
    elseif idx == 19
        str = 'SQRA';
    elseif idx == 20
        str = 'DN';
    elseif idx == 21
        str = 'Omega0';
    elseif idx == 22
        str = 'I0';
    elseif idx == 23
        str = 'Omega';
    elseif idx == 24
        str = 'Omegadot';
    elseif idx == 25
        str = 'IDOT';
    elseif idx == 26
        str = 'CRC';
    elseif idx == 27
        str = 'CRS';
    elseif idx == 28
        str = 'CUC';
    elseif idx == 29
        str = 'CUS';
    elseif idx == 30
        str = 'CIC';
    elseif idx == 31
        str = 'CIS';
    elseif idx == 32
        str = 'TOW';
    elseif idx == 33
        str = 'UPDATE';
    else
        fprintf('idxtoephfield: Ooops did not find match for %d\n',idx);
        str = 'Unknown';
    end

end

