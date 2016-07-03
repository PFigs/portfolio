function sAlgo = compareorbits( sAlgo, TOW, WD  )
%COMPAREORBITS computes broadcast and igs orbits
%   This function returns the satellite positions in ECEF and ENU as well
%   as azimuth and elevation in order to compare the end result of them.
%   
%   
%   
%  Pedro Silva, Instituto Superior Tecnico, February 2012
    
    % Initializations
    userxyz = sAlgo.refpoint;
    eph     = sAlgo.eph;

    [satigs, igstsv ] = precisepos( userxyz, eph, WD, TOW,'nev');
%     [satigs3, igstsv2 ] = precisepos( userxyz, eph, WD, TOW,'nev' );
%     [satigs4, igstsv2 ] = precisepos( userxyz, eph, WD, TOW,'lagrange' );
    [satbrd, ecc]       = satpos(eph,userxyz,TOW); 
    brdtsv              = dtsv(eph, ecc, TOW, sAlgo.freqmode); % Tsv correction   %send nSat
        
    [~, dirbrd, enubrd] = directorcos(userxyz,satbrd,'enu');
    [~, dirigs, enuigs] = directorcos(userxyz,satigs,'enu');
    
    brdaz  = azimuth(dirbrd,'rad');
    brdelv = elevation(dirbrd,'rad');
    igsaz  = azimuth(dirigs,'rad');
    igselv = elevation(dirigs,'rad');
    
    % final atributions
    sAlgo.satxyz   = [satbrd satigs];
    sAlgo.satenu   = [enubrd enuigs];
    sAlgo.satelv   = [brdelv igselv];
    sAlgo.sataz    = [brdaz  igsaz ];
    sAlgo.satclk   = [brdtsv igstsv];

end
