function [eph,dirty] = decodeAIDEPH( payload, eph )
%DECODEAIDEPH decodes AID's EPH payload
%   This function retrieves the data necessary to calculate the satellite 
%   orbits
%
%   NOTE that,
%       bitshift ( 2 ,  1 ) => 00100 ( <- right  )
%       bitshift ( 2 , -1 ) => 00001 ( -> left )
%       
%   ATTENTION: 
%   SEMI-CIRCLE UNITS BEING CONVERTED TO CIRCLE!
%
%   INPUT
%   PAYLOAD - message payload
%
%   OUTPUT
%   EPH     - ephemerides matrix
%
% Pedro Silva, Instituto Superior Tecnico, January 2012
       
    
    % Check if message has data
    how = u4(payload(5:8)); %obtains HOW
    if how == 0
        dirty = 0;
        return;
    else
        dirty = 1;
    end

    % Bit masks
    k  = 1:24;
    BM = 2.^k-1;
    
    % Retrieve data
    satid      = u4(payload(1:4));
    eph.update = satid;    
    eph.data(ephidx('SID'), satid)  = satid;

    % SUBFRAME 1 WORD 3
    sf1w3                             = u4(payload(9:12));
    iodc                              = bitshift(bitand(sf1w3,BM(2)),10);
    eph.data(ephidx('health'), satid) = bitand(bitshift(sf1w3,-2),BM(6));
    eph.data(ephidx('ura'), satid)    = uratometer(bitand(bitshift(sf1w3,-8),BM(4)));
    eph.data(ephidx('CodeL2'), satid) = bitand(bitshift(sf1w3,-12),BM(2));
    eph.data(ephidx('wn'), satid)     = 1024+bitshift(sf1w3,-14);

    % SUBFRAME 1 WORD 4 to 6 ignored
    
    % SUBFRAME 1 WORD 7
    sf1w7                          = u4(payload(25:28));
    eph.data(ephidx('tgd'), satid) = tc2dec(bitand(sf1w7,BM(8)),8)*2^(-31); % seconds
    
    % SUBFRAME 1 WORD 8
    sf1w8                           = u4(payload(29:32));
    eph.data(ephidx('toc'), satid)  = bitand(sf1w8,BM(16))*2^4; % seconds
    eph.data(ephidx('iodc'), satid) = bitor(iodc,bitand(bitshift(sf1w8,-16),BM(8)));
    
    % SUBFRAME 1 WORD 9
    sf1w9                          = u4(payload(33:36));
    eph.data(ephidx('af1'), satid) = tc2dec(bitand(sf1w9,BM(16)),16)*2^(-43); % sec/sec
    eph.data(ephidx('af2'), satid) = tc2dec(bitand(bitshift(sf1w9,-16),BM(8)),8)*2^(-55); % sec/sec^2
    
    % SUBFRAME 1 WORD 10
    sf1w10                         = u4(payload(37:40));
    eph.data(ephidx('af0'), satid) = tc2dec(bitand(bitshift(sf1w10,-2),BM(22)),22)*2^(-31); % seconds

    
    % SUBFRAME 2 WORD 3
    sf2w3                              = u4(payload(41:44));
    eph.data(ephidx('CRS'), satid)     = tc2dec(bitand(sf2w3,BM(16)),16)*2^(-5);
    eph.data(ephidx('IODESF2'), satid) = bitand(bitshift(sf2w3,-16),BM(8));

    % SUBFRAME 2 WORD 4
    sf2w4                         = u4(payload(45:48));
    mo                            = bitshift(bitand(sf2w4,BM(8)),24);
    eph.data(ephidx('DN'), satid) = tc2dec(bitand(bitshift(sf2w4,-8),BM(16)),16)*2^(-43)*pi;

    % SUBFRAME 2 WORD 5
    sf2w5                         = u4(payload(49:52));
    eph.data(ephidx('M0'), satid) = tc2dec(bitor(mo,bitand(sf2w5,BM(24))),32)*2^(-31)*pi;

    % SUBFRAME 2 WORD 6
    sf2w6                          = u4(payload(53:56));
    exc                            = bitshift(bitand(sf2w6,BM(8)),24);
    eph.data(ephidx('CUC'), satid) = tc2dec(bitand(bitshift(sf2w6,-8),BM(16)),16)*2^(-29);

    % SUBFRAME 2 WORD 7
    sf2w7                          = u4(payload(57:60));
    eph.data(ephidx('ECC'), satid) = bitor(exc,bitand(sf2w7,BM(24)))*2^(-33);

    % SUBFRAME 2 WORD 8
    sf2w8                           = u4(payload(61:64));
    sqra                            = bitshift(bitand(sf2w8,BM(8)),24); 
    eph.data(ephidx('CUS'), satid)  = tc2dec(bitand(bitshift(sf2w8,-8),BM(16)),16)*2^(-29);

    % SUBFRAME 2 WORD 9
    sf2w9                           = u4(payload(65:68));
    eph.data(ephidx('SQRA'), satid) = bitor(sqra,bitand(sf2w9,BM(24)))*2^(-19);

    % SUBFRAME 2 WORD 10
    sf2w10                          = u4(payload(69:72));
    %eph.aodo                       = bitand(bitshift(sf2w10,-2),M5); % IGNORED
    eph.data(ephidx('FIF'), satid)  = bitand(bitshift(sf2w10,-7),BM(1));
    eph.data(ephidx('TOE'), satid)  = bitand(bitshift(sf2w10,-8),BM(16))*2^4;

    % SUBFRAME 3 WORD 3
    sf3w3                          = u4(payload(73:76));
    omegao                         = bitshift(bitand(sf3w3,BM(8)),24); 
    eph.data(ephidx('CIC'), satid) = tc2dec(bitand(bitshift(sf3w3,-8),BM(16)),16)*2^(-29);

    % SUBFRAME 3 WORD 4
    sf3w4                             = u4(payload(77:80));
    eph.data(ephidx('omega0'), satid) = tc2dec(bitor(omegao,bitand(sf3w4,BM(24))),32)*2^(-31)*pi;

    % SUBFRAME 3 WORD 5
    sf3w5                          = u4(payload(81:84));
    io                             = bitshift(bitand(sf3w5,BM(8)),24);
    eph.data(ephidx('CIS'), satid) = tc2dec(bitand(bitshift(sf3w5,-8),BM(16)),16)*2^(-29);

    % SUBFRAME 3 WORD 6
    sf3w6                         = u4(payload(85:88));
    eph.data(ephidx('I0'), satid) = tc2dec(bitor(io,bitand(sf3w6,BM(24))),32)*2^(-31)*pi;

    % SUBFRAME 3 WORD 7
    sf3w7                          = u4(payload(89:92));
    omega                          = bitshift(bitand(sf3w7,BM(8)),24);
    eph.data(ephidx('CRC'), satid) = tc2dec(bitand(bitshift(sf3w7,-8),BM(16)),16)*2^(-5);

    % SUBFRAME 3 WORD 8
    sf3w8                            = u4(payload(93:96));
    eph.data(ephidx('omega'), satid) = tc2dec(bitor(omega,bitand(sf3w8,BM(24))),32)*2^(-31)*pi;

    % SUBFRAME 3 WORD 9
    sf3w9                               = u4(payload(97:100));
    eph.data(ephidx('omegadot'), satid) = tc2dec(bitand(sf3w9,BM(24)),24)*2^(-43)*pi;

    % SUBFRAME 3 WORD 10
    sf3w10                             = u4(payload(101:104));
    eph.data(ephidx('idot'), satid)    = tc2dec(bitand(bitshift(sf3w10,-2),BM(14)),14)*2^(-43)*pi;
    eph.data(ephidx('iodesf3'), satid) = bitand(bitshift(sf3w10,-16),BM(8));
 
end
