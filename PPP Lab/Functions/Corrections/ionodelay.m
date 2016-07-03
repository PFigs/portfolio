function Tiono = ionodelay( iono, lat, long, satEl, satAz, TOW, freqmode )
%IONODELAY computes the delay introduced by the ionosphere layer
%   The model use is presented in the IS 200 document
%
%   INPUT
%   IONO    - Coefficients for the Ionospheric model
%   LAT     - User's Latitude [degrees]
%   LONG    - User's Longitude [degrees]
%   SATEL   - Elevation [radians]
%   SATAZ   - Azimuth [radians]
%   TOW     - Time of week [seconds]
%
%   OUTPUT
%   TIONO   - Delay introduced by the ionosphere (in seconds)
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    % To ease model reading
    PHIu    = lat/180;
    LAMBDAu = long/180;
    E       = satEl./pi;
    A       = satAz./pi;
    alpha   = iono.alpha(:,1);
    beta    = iono.beta(:,1);
    
    % Obliquity factor
    F = 1.0 + 16.0*(0.53 - E).^3;
    
    % Earht's central angle between the user position and the earth
    % projection of ionospheric intersection point [semi-circles]
    PSI = 0.0137./(E + 0.11) - 0.22; % semi circles
    
    % Calculates geodetic latitude of the earth projection of the
    % ionospheric intersection point (mean ionospheric height assumed
    % 350km) [semi-circles]
    PHIi  = PHIu + PSI.*cos(A);
    if PHIi > 0.416
        PHIi = 0.416;
    elseif PHIi < -0.416
        PHIi = -0.416;
    end
    
    % Geodetic longitude of the earth projection of the ionospheric
    % intersection point [semi-circles]
    LAMBDAi = LAMBDAu + (PSI.*sin(A))./cos(PHIi);
    
    % Geomagnetic latitude of the earth projection of the ionospheric
    % intersection point (mean ionospheric height assumed 350km)
    % [semi-circles]
    PHIm = PHIi + 0.064.*cos(LAMBDAi-1.617);
    
    % Local time [sec]
    t = 4.32*(10^4).*LAMBDAi + TOW;
    
    % Model parameters
    AMP = alpha(1)*1 + alpha(2)*PHIm ...
        + alpha(3)*PHIm.^2 + alpha(4)*PHIm.^3;
    if AMP < 0
        AMP = 0; 
    end
    
    PER = beta(1)*1 + beta(2)*PHIm ...
        + beta(3)*PHIm.^2 + beta(4)*PHIm.^3;
    if PER < 72000
        PER = 72000;
    end
    
    % Phase [radians]
    x = (2*pi*(checktime(t-50400)))./PER;
    if abs(x) < 1.57
        Tiono = F.*(5.0e-09 + AMP.*(1 - (x.^2)/2 + (x.^4)/24));
    else 
        Tiono = F.*(5.0e-09);
    end
    
    if strcmpi(freqmode,'L2')
        Tiono = gpsparams('gama').*Tiono;
    end
end

