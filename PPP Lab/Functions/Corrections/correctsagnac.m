function [satxyz,iTime,conv] = correctsagnac(userxyz, satxyz, odot, TOW,last)
        
%     OMEGAE   = earthparams('OMEGAE');
    
%     last    = satxyz;
    satdist = sqrt(sum((satxyz-userxyz).^2,2));  % Obtains sat distance
    delta   = satdist'/gpsparams('C');           % Obtains time difference
    iTime   = TOW - delta;                       % Updates time
    
    % Rotates coordinates
    gama        = (earthparams('OMEGAE')-odot').*delta';
    satxyz(:,1) =  satxyz(:,1).*cos(gama) + satxyz(:,2).*sin(gama);
    satxyz(:,2) = -satxyz(:,1).*sin(gama) + satxyz(:,2).*cos(gama);
    satxyz(:,3) =  satxyz(:,3);

    conv = all(sqrt(sum((satxyz-last).^2,2)) <= eps);
    
    
end