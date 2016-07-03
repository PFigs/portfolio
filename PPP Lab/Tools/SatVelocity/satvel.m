    


% Simple method

% [cosvec,~,~,nvec]  = directorcos(sAlgo.userxyz,satpos(eph,sAlgo.userxyz,sEpoch.TOW),'enu');
[ ~, ~, ~, iTime ] = satpos(eph,sAlgo.userxyz,sEpoch.TOW);
satv    = (satcoord(eph,iTime'-1,1) - satcoord(eph,iTime'+1,1))./2;
% satv    = diag(satv*cosvec');


% Remondi and other
[ rxyz, eccanomaly, vxyz ] = satcoord(eph,TOW,delta);

% Sanguino