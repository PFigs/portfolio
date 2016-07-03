function [st] = gethandles( varargin )
%GETHANDLES returns handles for the figures
%   This function returns handles for ploting the receiver position and
%   satellite constelation.
%
%   INPUT
%   None (switcher should be passed)
%
%   OUTPUT
%   ST - Structure with handles created
%
% Pedro Silva, Instituto Superior Tecnico, February 2012

    % Structure declaration
    persistent sthdl;
    persistent fighandle;
    
    % Retrieves handle type to create
    if nargin
        type = varargin{1};
    else
        type = '';
    end
    
    if strcmpi(type,'figs')
        st = fighandle;
        return;
    end
        
    
    % Creates structure only for the first pass
    if isempty(sthdl) || strcmpi(type,'clean')
        sthdl = struct('sat',NaN,'pos',NaN,'D2',NaN,'D3',NaN,...
                       'enu',NaN,'east',NaN,'north',NaN,'up',NaN);
        set(0,'Units','normalized');
        get(0,'ScreenSize');
    end
    
    if isempty(fighandle) || strcmpi(type,'clean')
       fighandle = NaN(5,1); 
    end
    
    % Creates handle for user position
    if isnan(sthdl.pos) && strcmpi(type,'pos')          
        fighandle(1) = figure('Name','Receiver position','NumberTitle','off');
        sthdl.pos = axes('Parent',fighandle(1));
        title('Receiver position in EN coordinates',...
              'fontsize',12,'fontweight','b');
        xlabel('East (m)','fontsize',11,'fontweight','b');
        ylabel('North (m)','fontsize',11,'fontweight','b');
        hold(sthdl.pos);
        
        % Determines figure positons
        set(fighandle(1),'Units','normalized');
        set(fighandle(1),'Position',[0.0125 0.5 0.3 0.40]);
        
    end
    
    % Creates handle for satellite position
    if isnan(sthdl.sat) && strcmpi(type,'sat')
        sthdl.sat = figure('Name','User calculated satellite elevation and azimuth','NumberTitle','off');
        title('Satellite constelation','fontsize',12,'fontweight','b');
        % Determines figure positons
        set(sthdl.sat,'Units','normalized');
        set(sthdl.sat,'Position',[0.525 0.5 0.45 0.40]);
        fillPage(sthdl.sat);
        
    end
    
    % Creates handle for east coordinate
    if isnan(sthdl.east) && strcmpi(type,'east') 
        fighandle(3) = figure('Name','ENU Coordinates - EAST','NumberTitle','off');
        sthdl.east = axes('Parent',fighandle(3));
        title('East coordinate','fontsize',12,'fontweight','b');
        xlabel('Epochs (s)','fontsize',11,'fontweight','b');
        ylabel('East (m)','fontsize',11,'fontweight','b');
        hold(sthdl.east);
        
        % Determines figure positons
        set(fighandle(3),'Units','normalized');
        set(fighandle(3),'Position',[0.0125 0 0.3 0.40]);

    end
    
    % Creates handle for north coordinate
    if isnan(sthdl.north) && strcmpi(type,'north') 
        fighandle(4) = figure('Name','ENU Coordinates - NORTH','NumberTitle','off');
        sthdl.north = axes('Parent',fighandle(4));
        title('North coordinate','fontsize',12,'fontweight','b');
        xlabel('Epochs (s)','fontsize',11,'fontweight','b');
        ylabel('North (m)','fontsize',11,'fontweight','b');
        hold(sthdl.north);
        
        % Determines figure positons
        set(fighandle(4),'Units','normalized');
        set(fighandle(4),'Position',[0.35 0 0.3 0.40]);

    end
    
    % Creates handle for up coordinate
    if isnan(sthdl.up) && strcmpi(type,'up') 
        fighandle(5) = figure('Name','ENU Coordinates - UP','NumberTitle','off');
        sthdl.up = axes('Parent',fighandle(5));
        title('Up coordinate','fontsize',12,'fontweight','b');
        xlabel('Epochs (s)','fontsize',11,'fontweight','b');
        ylabel('Up (m)','fontsize',11,'fontweight','b');
        hold(sthdl.up);
        
        % Determines figure positons
        set(fighandle(5),'Units','normalized');
        set(fighandle(5),'Position',[0.6875 0 0.3 0.40]);

    end
    
    if isnan(sthdl.enu) &&  strcmpi(type,'enu')
        fighandle(8) = figure('Name','ENU Coordinates','NumberTitle','off');
        sthdl.enu = axes('Parent',fighandle(8));
        title('ENU coordinates','fontsize',12,'fontweight','b');
        xlabel('Epochs (s)','fontsize',11,'fontweight','b');
        ylabel('East, North, Up (m)','fontsize',11,'fontweight','b');
        hold(sthdl.enu);
        
        % Determines figure positons
        set(fighandle(8),'Units','normalized');
        set(fighandle(8),'Position',[0.0125 0 0.3 0.40]);

    end
    
    
    if isnan(sthdl.D2) && (strcmpi(type,'ACC'))
        
        fighandle(6) = figure('Name','2D Accuracy statistics','NumberTitle','off');
        sthdl.D2 = axes('Parent',fighandle(6));
        title('2D Accuracy Statistics','fontsize',12,'fontweight','b');
        ylabel('value (m)');
        xlabel('Accuracy Statistics');
        hold(sthdl.D2);
        
        % Determines figure positons
        set(fighandle(6),'Units','normalized');
        set(fighandle(6),'Position',[0.35 0.5 0.3 0.40]);
        set(sthdl.D2,'XTick',1:4);
        set(sthdl.D2,'XTickLabel',{'DMRS','CEP50','CEP90','CEP95'})
        grid on;

    end
    
    
        
    if isnan(sthdl.D3) && (strcmpi(type,'ACC'))
        fighandle(7) = figure('Name','3D Accuracy statistics','NumberTitle','off');
        sthdl.D3 = axes('Parent',fighandle(7));
        title('3D Accuracy Statistics','fontsize',12,'fontweight','b');
        ylabel('value (m)');
        xlabel('Accuracy Statistics');
        hold(sthdl.D3);
        
        % Determines figure positons
        set(fighandle(7),'Units','normalized');
        set(fighandle(7),'Position',[0.6875 0.5 0.3 0.40]);
        set(sthdl.D3,'XTick',1:4);
        set(sthdl.D3,'XTickLabel',{'MSRE','SEP50','SEP90','SEP99'})
        grid on;

    end
    
    % MATLAB can not set input/output variable persistent
    st = sthdl;
    
end

