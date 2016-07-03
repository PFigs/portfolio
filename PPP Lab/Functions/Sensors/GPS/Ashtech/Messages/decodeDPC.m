function ranges = decodeDPC(data)
%DECODEDPC decodes DPC data payload
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
    rcvtime = u4(data(1:4),'bigendian') * 1e-03; % seconds
    prn     = u4(data(9:12),'bigendian');
    prn     = dec2bin(prn,32);
    prn     = prn(end:-1:1);
    satlist = find(prn=='1');

    % Decode measurements
    ranges = ashtechstructs( 'DPC' ); % retrieves structure declaration
    idx    = 13;
%     fprintf('\tTOW: %f\n',rcvtime);
    for s=satlist
        % SAT INFORMATION
        health = bitand(bitshift(data(idx),-7),1);
        satelv = bitand(data(idx),127);
        idx = idx + 1; %14
        snrl1 = bitand(data(idx),127);
        
        % L1 DATA
        idx = idx + 1; %15
        pl1 = bitshift(u4(data(idx:idx+3),'bigendian'),-1)* 1e-10 * C;
        wl1 = bitand(data(idx+3),1); %warning bit
        idx = idx + 4; %19
        sgn = bitand(bitshift(data(idx),-7),1); %signal bit
        phi = bitshift(u4(data(idx:idx+3),'bigendian'),-3);
        phi = bitand(phi,2^28-1);
        idx = idx + 4; %23
        phf = bitand(data(idx-1),7);
        phf = u2([phf,data(idx)],'bigendian');
        ph1 = phi + phf * 5.0e-04;
        if sgn, ph1 = -1*ph1; end;
        idx = idx + 1; %24
        do1 = u3(data(idx:idx+2),'bigendian');
        idx = idx + 3; %27

        % L2 DATA
        pl2 = bitshift(u4(data(idx:idx+3),'bigendian'),-1)* 1e-10 * C;
        wl2 = bitand(data(idx+3),1); %warning bit
        idx = idx + 4; %31
        sgn = bitand(bitshift(data(idx),-7),1); %signal bit
        phi = bitshift(u4(data(idx:idx+3),'bigendian'),-3);
        phi = bitand(phi,2^28-1);
        idx = idx + 4; %35
        phf = bitand(data(idx-1),7);
        phf = u2([phf,data(idx)],'bigendian');
        ph2 = phi + phf * 5.0e-04;
        if sgn, ph2 = -1*ph2; end;
        idx = idx + 1; %36
        do2 = u3(data(idx:idx+2),'bigendian');
        idx = idx + 3; %39
        
        % SAVE DATA
        if pl1 ~= 0 && pl2 ~= 0
            ranges.HEALTH(s)    = health;
            ranges.SATELV(s)    = satelv;
            ranges.SNRL1(s)     = snrl1;
            ranges.PRL1(s)      = pl1;    % Pseudo Range L1
            ranges.PRL2(s)      = pl2;    % Pseudo Range L2
            ranges.CPL1(s)      = ph1;    % Carrier Phase L1
            ranges.CPL2(s)      = ph2;    % Carrier Phase L2
            ranges.DOL1(s)      = do1*0.002;    % Doppler L1
            ranges.DOL2(s)      = do2*0.002;    % Doppler L2
            ranges.WARNINGL1(s) = wl1;    % Warning bit L1
            ranges.WARNINGL2(s) = wl2;    % Warning bit L2
        end
    end
    
    if satlist
        ranges.TOW     = rcvtime;
        ranges.SATLIST = satlist;
    else
        disp('parsemsg: There where no satellites');
    end

end
