function [satxyz,satclk,sataz,satelv,cosvec,nvec,windup,zpd,mw,satxyzdiff,satclkdiff] = getConstellation(iEpoch,DOY,WD,TOW,userxyz,eph,flags,tropo,rcvenu,windup,antex,sun)
%GETCONSTELLATION Summary of this function goes here
%   Detailed explanation goes here

    % Obtain satellite coordinates
    [ satxyz, satclk, ~, satxyzdiff, satclkdiff] = precisepos(iEpoch,userxyz, eph, WD, TOW, flags, antex, sun); 

    % Obtain corrections
    [cosvec, enuvec, satenu, nvec] = directorcos(userxyz,satxyz,'enu');
    satelv                         = elevation(enuvec,'rad');
    sataz                          = azimuth(satenu,'rad');
    
    % Obtain tropo delay
    lla               = eceftolla(userxyz);
    [zpd,drycomp,mw]  = zenithdelay(lla(1),lla(3),satelv,DOY); 
    if tropo, zpd     = drycomp; end;
    
    
    % For antenna and wind up error
%     Satellite unitary vector
%     if flags.usepreciseorbits
%         nSat = size(satxyz,1);
%         ns = sqrt(sum(satxyz.^2,2));
%         K  = zeros(nSat,3);
%         J  = zeros(nSat,3);
%         I  = zeros(nSat,3);
%         E  = zeros(nSat,3);
%         for l = 1:nSat
%             K(l,:) = -satxyz(l,:)./ns(l,:);
%             E(l,:) = (sun - satxyz(l,:))./sqrt(sum((sun-satxyz(l,:)).^2,2));
%             J(l,:) = cross(K(l,:),E(l,:));
%             I(l,:) = cross(J(l,:),K(l,:));
%             R = [I(l,:);J(l,:);K(l,:)];
%             satxyz(l,:) = satxyz(l,:) + (R*antex(eph.satid(l),:)')';
%         end        
%     end
%     
    % Wind up error
%     [ ~, ~, ~, satop ] = satcoord(eph,TOW,1);
%     windup             = correctwindup(windup,rcvenu,userxyz,satop);
        
end

