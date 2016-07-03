function [tzp,drycomp,mw] = zenithdelay( latitude, altitude, satElevation, doy)
%ZENITHDELAY computes the troposheric delay according to the user position
%satellite elevation and interpolated metereological information.
%   The function computes a dry and wet component and makes use of mapping
%   functions to further adjust the model to the users position
%
%   INPUT
%   LATITUDE     - User's latitude [degrees]
%   ALTITUDE     - User's altitude [meters]
%   SATELEVATION - Satellite elevation [radians]
%   DOY          - Day of the year
%
%   OUTPUT
%   TZP          - Zenith path delay TZP = MFw*ZPDwet + MFd*ZPDdry
%
%   SOURCE
%   Kaplan, E. D; Hegarty, C.J.; GPS PRINCIPLES AND APPLICATIONS, 2ND EDITION
%   2006, pages 316 - 319
%
%   Pedro Silva, Instituto Superior Tecnico, January 2011

    % Computes WGS coordinates
    N         = sign(latitude);
    
    % Checks for valid input or not possible to complete
    if altitude <= 0 || altitude > 3000 || isnan(latitude)
        tzp     = 2.47./(sin(satElevation)+0.0121);
        drycomp = tzp/2;
        mw      = tzp/2;
        return;
    end
    if latitude <= 15 
        tzp     = 2.47./(sin(satElevation)+0.0121);
        drycomp = tzp;
        mw      = tzp/2;
        return; 
    end
    
    %Average Meteorological Parameters for Tropospheric Delay
    % pressure (mbar), Temperature (K), water vapure pressure (mbar)
    % temperature lapse (K/m), water vapor lapse (unitless)
    average = struct('latitude',[15, 30, 45, 60, 75],...
                     'p0',[1013.25, 1017.25, 1015.75, 1011.75, 1013.00],...
                     't0',[299.65, 294.15, 283.15, 272.15, 263.65],...
                     'e0',[26.31, 21.79, 11.66, 6.78, 4.11],...
                     'b0',[6.3e-03, 6.05e-03,5.58e-03,5.39e-03,4.53e-03],...
                     'l0',[2.77, 3.15, 2.57, 1.81, 1.55]);

    % Seasonal Meteorological Parameters for Tropospheric Delay
    season  = struct('latitude',[15, 30, 45, 60, 75],...
                     'dp',[0, -3.75, -2.25, -1.75, -0.50],...
                     'dt',[0, 7, 11, 15, 14.50],...
                     'de',[0, 8.85, 7.24, 5.36, 3.39],...
                     'db',[0, 0.25e-03, 0.32e-03, 0.81e-03, 0.62e-03 ],...
                     'dl',[0, 0.33, 0.46, 0.74, 0.30]);

    llimit = average.latitude((average.latitude<latitude));
    llat   = llimit(end);
    lidx   = find(average.latitude == llat);
    hlimit = average.latitude((average.latitude>latitude));
    hlat   = hlimit(1);
    hidx   = find(average.latitude == hlat);

    %if hlimit == llimit not in scope

    p = calcparam(average.p0(:),season.dp(:),lidx,hidx,llat,hlat,latitude,doy,N);
    t = calcparam(average.t0(:),season.dt(:),lidx,hidx,llat,hlat,latitude,doy,N);
    e = calcparam(average.e0(:),season.de(:),lidx,hidx,llat,hlat,latitude,doy,N);
    b = calcparam(average.b0(:),season.db(:),lidx,hidx,llat,hlat,latitude,doy,N);
    l = calcparam(average.l0(:),season.dl(:),lidx,hidx,llat,hlat,latitude,doy,N);

    [ dry , wet ] = zpdcomponents(altitude, p, t, e, b, l);
    [ md  , mw  ] = mappingfunction(latitude,altitude,satElevation);
%    [ md, mw]= viennafunction()    
    tzp     = md*dry + mw*wet;
    drycomp = md*dry;
    
end

function [param, av,se] = calcparam(average, season, lidx, hidx, llat, hlat, lat, doy, N)
%CALCPARAM obtains the parameter from the table interpolation
%
% INPUT
% AVERAGE, SEASON - Data arrays
% LIDX, HIDX - Lower and higher idx
% LLAT, HLAT - Lower and Higher latitudes
% LAT - User latitude
% N   - If Northern or southern latitutes
%
% OUTPUT
% PARAM - Final interpolated value
% AV - Average interpolated value
% SE - Seasonal interpolated value
%
% Pedro Silva, Instituto Superior Tecnico, January 2011


    av = average(lidx) + (average(hidx) - average(lidx))*(lat-llat)/(hlat-llat);
    se = season(lidx)  + (season(hidx)  - season(lidx)) *(lat-llat)/(hlat-llat);

    if N
        Dmin = 28; 
    else
        Dmin = 211; 
    end;
    
    D     = fix(doy);
    param = av - se * cos( 2*pi*(D-Dmin)/365.25 );
    
end


function [dry, wet] = zpdcomponents(H, p, t, e, b, l)
%ZPDCOMPONENTS calculates the DRY and WET delay
% INPUT
% H - Altitude
% p,t,e,b,l - Interpolated values
%
% OUTPUT
% DRY, WET - Dry and wet delays
%
% SOURCE
% Kaplan, E. D; Hegarty, C.J.; GPS PRINCIPLES AND APPLICATIONS, 2ND EDITION
% 2006, page 317
%
% Pedro Silva, Instituto Superior Tecnico, January 2011

    % Constants
    k1 = 77.604;
    k2 = 382000;
    Rd = 287.054;
    gm = 9.784;
    g  = 9.80665;
    
    dry = (1-b*H/t)^(g/(Rd*b))*(10^-6*k1*Rd*p/gm);
    wet = (1-b*H/t)^((l+1)*g/(Rd*b)-1)*(10^-6*k2*Rd/(gm*(l+1)-b*Rd)*e/t);

end


function [mdry, mwet] = mappingfunction(lat,h,E)
%MAPPINGFUNCTION returns the wet and dry mapping function
% 
% INPUT
% LAT - Latitude
% H - Altitude
% E   - Satellite Elevation in radians
%
% OUTPUT
% MDRY, MWET - Dry and wet mapping functions
%
% SOURCE
% Kaplan, E. D; Hegarty, C.J.; GPS PRINCIPLES AND APPLICATIONS, 2ND EDITION
% 2006, pages 318 - 319
% 
% Pedro Silva, Instituto Superior Tecnico, January 2011
    lat = rad(lat);
    %CONSTANTS
    a = ( 1.18972 - 0.026855*h + 0.10664*cos(lat))/1000;
    b = 0.0035716;
    c = 0.082456;
    
    mdry = 1 + a / ( 1 + b / (1 + c));
    mdry = mdry ./ ( sin(E) + a ./ ( sin(E) + b ./ ( sin(E) + c ) ) );
    
    a = ( 0.61120 - 0.035348*h + 0.01526*cos(lat))/1000;
    b = 0.0018576;
    c = 0.062741;
    
    mwet = 1 + a / ( 1 + b / ( 1 + c));
    mwet = mwet ./( sin(E) + a ./ ( sin(E) + b ./ ( sin(E) + c ) ) );
    
end







