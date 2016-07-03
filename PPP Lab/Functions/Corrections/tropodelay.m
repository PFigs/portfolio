function [ zpd ] = tropodelay( userxyz, satxyz )
%TROPO Summary of this function goes here
%   Detailed explanation goes here

%     userlla = ecef2lla(userxyz);
%     h = userlla(3);
%     
%     a1 = 77.624;    %Constante do modelo 
%     a2 = -12.92;    %Constante do modelo
%     a3 = 371900;    %Constante do modelo
%     p0 = 1013.25;   %Press�o atmosf�rica ao n�vel do mar (mbar)
%     e0 = 11.7;      %Pressao parcial do vapor de �gua ao nivel do mar (mbar)
%     T0 = 288.15;    %Temperatura absoluta ao nivel do mar standard 
% 
%     Nd_0 = a1*p0/(T0);                  %Componente 'dry' da refractividade 
%     Nw_0 = a2*e0/T0 + a3*e0/(T0)^2;     %Componete 'wet da refractividade
% 
%     hd = 0.011385*p0/(Nd_0*10^-6);                 %Extens�o da componente 'dry'
%                                                    %da troposfera
% 
%     hw = 0.0113851/(Nw_0*10^-6)*(1225/T0+0.05)*e0; %Extens�o da componente 'wet'
%                                                    %da troposfera
%     
% 	dry = (1e-6)*Nd_0/(hd^4)*-1/5*(hd-h)^5; %Ciclo de calculo dos
% 	wet = (1e-6)*Nw_0/(hw^4)*-1/5*(hw-h)^5; %desvios troposf�ricos
% 	zpd = dry + wet;  %Desvio troposf�rico total

    [rlat,rlong,ralt] = xyztolla(userxyz(1),userxyz(2),userxyz(3));
    enu  = eceftoenu( satxyz(1), satxyz(2), satxyz(3), rlat, rlong, ralt );
    elv  = deg(elevation(enu));
    zpd  = 2.47/(sin(elv)+0.0121);
                                                   
end

