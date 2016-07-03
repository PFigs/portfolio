function ranges = decodeRPC(data)
%DECODERPC decodes RPC data payload
%
% INPUT
% DATA - Data payload
%
% OUTPUT
% RANGES - Pseudorange and carrier phase
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    C =  gpsparams('c');
    
    %decode header parameters
    rcvtime = bitshift(u4(data(1:4),'bigendian'),-2) * 1e-03; % seconds
    prn     = bitshift(u4(data(9:12),'bigendian'),-2);
    prn     = bitor(prn,bitshift(bitand(data(8),3),30));
    prn     = dec2bin(prn,32);
    prn     = prn(end:-1:1);
    satlist = find(prn=='1');
    
    % Decode measurements
    ranges = ashtechstructs( 'RPC' ); % retrieves structure declaration
    idx    = 12;

    for i=satlist
        % L1 DATA
        idx = idx+1;
        pl1 = bitshift(u4(data(idx:idx+3),'bigendian'),-3); %correto
        pl1 = bitor(pl1,bitshift(bitand(data(idx-1),3),29))* 1e-10 * C;
        wl1 = bitand(bitshift(data(idx+3),-2),1); %warning bit
        sgn = bitand(bitshift(data(idx+3),-1),1); %signal bit
        idx = idx + 4;
        phi = bitshift(u4(data(idx:idx+3),'bigendian'),-5);
        phi = bitor(phi,bitshift(bitand(data(idx-1),1),27));
        idx = idx + 4;
        phf = bitshift(data(idx),-2);
        phf = bitor(phf,bitshift(bitand(data(idx-1),31),6));
        ph1 = phi + phf * 5.0e-04;
        if sgn, ph1 = -1*ph1; end;
        
        % L2 DATA
        idx = idx+1;
        pl2 = bitshift(u4(data(idx:idx+3),'bigendian'),-3);
        pl2 = bitor(pl2,bitshift(bitand(data(idx-1),3),29))* 1e-10 * C;
        wl2 = bitand(bitshift(data(idx+3),-2),1); %warning bit
        sgn = bitand(bitshift(data(idx+3),-1),1); %signal bit
        idx = idx + 4;
        phi = bitshift(u4(data(idx:idx+3),'bigendian'),-5);
        phi = bitor(phi,bitshift(bitand(data(idx-1),1),27));
        idx = idx + 4;
        phf = bitshift(data(idx),-2);
        phf = bitor(phf,bitshift(bitand(data(idx-1),31),6));
        ph2 = phi + phf * 5.0e-04;
        if sgn, ph2 = -1*ph2; end;

        % SAVE DATA
        if pl1 ~= 0 && pl2 ~= 0
            ranges.PRL1(i)= pl1;   % Pseudo Range L1
            ranges.PRL2(i)= pl2;   % Pseudo Range L2
            ranges.CPL1(i)= ph1;   % Carrier Phase L1
            ranges.CPL2(i)= ph2;   % Carrier Phase L2
            ranges.WARNINGL1(i)= wl1;  % Warning bit L1
            ranges.WARNINGL2(i)= wl2;  % Warning bit L2
        end
    end
    
    if satlist
        ranges.TOW     = rcvtime;
        ranges.SATLIST = satlist;
    else
        disp('parsemsg: There where no satellites');
    end

end
