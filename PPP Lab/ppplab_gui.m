function varargout = ppplab_gui(varargin)
% PPPLAB_GUI MATLAB code for ppplab_gui.fig
%      PPPLAB_GUI, by itself, creates a new PPPLAB_GUI or raises the existing
%      singleton*.
%
%      H = PPPLAB_GUI returns the handle to a new PPPLAB_GUI or the handle to
%      the existing singleton*.
%
%      PPPLAB_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PPPLAB_GUI.M with the given input arguments.
%
%      PPPLAB_GUI('Property','Value',...) creates a new PPPLAB_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ppplab_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ppplab_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ppplab_gui


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ppplab_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ppplab_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% TO DO

% Finish load all the fields
% Initialization is not being done for some fields (interp for example)

% Add log path input (use menus)
% Log type (only one now xD)
% Deeper Interpolation settings (degree)
% Disable IGS and Interpolation when not needed

% Take in mind that background color is not the same under unix and windows

 % %
%   % --------------------------------------------------------------------+
%   %  Variable initial setup                                             |
 % % .--------------------------------------------------------------------+                                               
function ppplab_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function is executed just before the GUI is made visible thus all
% initialization should be done here. 
% Please remember that the create functions are run before this one
    addpath(genpath('Functions/'));
    
    % Evaluates debug flag
    if nargin == 4
        handles.debug     = 1;
    else
        handles.debug     = 0;
    end
    
    
    if gui_license
        % First initializations
        handles = gui_initstatus(handles,handles.debug);
        handles = gui_initaxes(handles,handles.debug);
        movegui(hObject,'center');
%         set(hObject, 'Color', [0.941 0.941 0.941]);

        % Retrieve data from previous session
        if exist('.gui_session.mat','file');
            load('.gui_session.mat');
            handles.sSettings  = sSettings;
        else
            handles.usersettings = gui_settingspanel(handles.debug);
            handles.sSettings    = gui_setppplabsettings(handles.usersettings, handles.debug);
        end

        % Disable buttons that might cause problems       
        set(handles.lplotbutton,'enable','off');
        set(handles.rplotbutton,'enable','off');
        set(handles.pausebutton,'enable','off');
        set(handles.generatereport,'enable','off');
        defaultBackground = get(0,'defaultUicontrolBackgroundColor');
        set(hObject,'Color',defaultBackground)
        
        % Creates fields in handles struct
        handles.execution = 0;
        handles.output    = hObject;
        guidata(hObject, handles);
    else
        handles.output    = hObject;
        guidata(hObject, handles);
        delete(hObject);
    end

function varargout = ppplab_gui_OutputFcn(hObject, eventdata, handles) 
    if ~isempty(handles)
        varargout{1} = handles.output;
    else
        varargout{1} = handles;
    end


%%%    
% 
% %  --------------------------------------------------------------------+
   %  Plot control (LEFT)
%%% .--------------------------------------------------------------------+    

%%% DATA SELECTOR

function leftdataselector_Callback(hObject, eventdata, handles)
% Allows the user to select data to be plotted on the left axis
    
    contents = cellstr(get(hObject,'String'));
    contents = contents{get(hObject,'Value')};
    handles.sSettings.graph.leftplottype = get(hObject,'Value');
    if handles.debug
        fprintf('Plot value %d\n',handles.sSettings.graph.leftplottype);
        fprintf('To plot %s\n',contents)
    end
    guidata(hObject, handles)

function leftaxes_ButtonDownFcn(hObject, eventdata, handles)
% ZOOMS IN or OUT when the user clicks on the axes
    mouseside = get(gcf,'SelectionType');
    zoomres   = 1/2;
    xy        = get(0,'PointerLocation');
    
    % ZOOM IN
    if strcmpi(mouseside,'normal')
        limx = handles.sSettings.graph.llimits(1:2)'./2;
        limy = handles.sSettings.graph.llimits(3:4)'./2;
        limz = handles.sSettings.graph.llimits(5:6)'./2;

    % ZOOM OUT    
    else
        limx = handles.sSettings.graph.llimits(1:2)'.*2;
        limy = handles.sSettings.graph.llimits(3:4)'.*2;
        limz = handles.sSettings.graph.llimits(5:6)'.*2;       
    end    

    if limx(2) > limx(1), 
        set(handles.leftaxes,'xlim',limx); 
        handles.sSettings.graph.llimits(1:2) = limx;
        set(handles.lxlower,'String',num2str(limx(1)));
        set(handles.lxupper,'String',num2str(limx(2)));
    end
    if limy(2) > limy(1),
        set(handles.leftaxes,'ylim',limy); 
        handles.sSettings.graph.llimits(3:4) = limy;
        set(handles.lylower,'String',num2str(limy(1)));
        set(handles.lyupper,'String',num2str(limy(2)));   
    end    
    if limz(2) > limz(1),
        set(handles.leftaxes,'zlim',limz); 
        handles.sSettings.graph.llimits(5:6) = limz;
        set(handles.lzlower,'String',num2str(limz(1)));
        set(handles.lzupper,'String',num2str(limz(2)));      
    end
    guidata(hObject, handles)


%%% Limits    
function lxlower_Callback(hObject, eventdata, handles)
% Evaluates the X lower limit for the left axis 
    handles.sSettings.graph.llimits(1) = str2double(get(hObject,'String'));
    guidata(hObject, handles);

function lxupper_Callback(hObject, eventdata, handles)
% Evaluates the X upper limit for the left axis 
    handles.sSettings.graph.llimits(2) = str2double(get(hObject,'String'));
    guidata(hObject, handles);

function lylower_Callback(hObject, eventdata, handles)
% Evaluates the Y lower limit for the left axis
    handles.sSettings.graph.llimits(3) = str2double(get(hObject,'String'));
    guidata(hObject, handles);     
    
function lyupper_Callback(hObject, eventdata, handles)
% Evaluates the Y upper limit for the left axis 
    handles.sSettings.graph.llimits(4) = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    
function lzlower_Callback(hObject, eventdata, handles)
% Evaluates the Z lower limit for the left axis
    handles.sSettings.graph.llimits(5) = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    
function lzupper_Callback(hObject, eventdata, handles)
% Evaluates the Z upper limit for the left axis 
    handles.sSettings.graph.llimits(6) = str2double(get(hObject,'String'));
    guidata(hObject, handles);

    
%%% States    
function lrealtime_Callback(hObject, eventdata, handles)
% Allows the user to toggle real time plotting on the left axis
    handles.sSettings.graph.lstates(1) =  get(hObject,'Value');
    guidata(hObject, handles);
    
function lxgrid_Callback(hObject, eventdata, handles)
% Allows the user to toggle the X grid on the left axis
    handles.sSettings.graph.lstates(2) =  get(hObject,'Value');
    guidata(hObject, handles);

function lygrid_Callback(hObject, eventdata, handles)
% Allows the user to toggle the Y grid on the left axis
    handles.sSettings.graph.lstates(3) =  get(hObject,'Value');
    guidata(hObject, handles);

function lzgrid_Callback(hObject, eventdata, handles)
% Allows the user to toggle the Z grid on the left axis
    handles.sSettings.graph.lstates(4) =  get(hObject,'Value');
    guidata(hObject, handles);

    
    
%%% Buttons    
function lplotbutton_Callback(hObject, eventdata, handles)
% Plots data for the run that has finished
    plotcontrol(handles,handles.sEpoch,handles.sAlgo,handles.sStat);

function lrefreshbutton_Callback(hObject, eventdata, handles)
% Changes the plot to accomodate for the new axis' limits
    lim = handles.sSettings.graph.llimits(1:2)';
    if lim(2) > lim(1)
        set(handles.leftaxes,'xlim',lim);
    end
    lim = handles.sSettings.graph.llimits(3:4)';
    if lim(2) > lim(1)
        set(handles.leftaxes,'ylim',lim);
    end
    lim = handles.sSettings.graph.llimits(5:6)';
    if lim(2) > lim(1)
        set(handles.leftaxes,'zlim',lim);
    end
    if handles.sSettings.graph.lstates(2)
        set(handles.leftaxes,'XGrid','on');
    else
        set(handles.leftaxes,'XGrid','off');
    end
    if handles.sSettings.graph.lstates(3)
        set(handles.leftaxes,'YGrid','on');
    else
        set(handles.leftaxes,'YGrid','off');    
    end
    if handles.sSettings.graph.lstates(4)
        set(handles.leftaxes,'ZGrid','on');
    else
        set(handles.leftaxes,'ZGrid','off');    
    end

function lclearbutton_Callback(hObject, eventdata, handles)
% Clears the left plot (only its data)    
    cla(handles.leftaxes,'reset'); 
    set(handles.leftaxes,'DrawMode','fast')
    hold(handles.leftaxes,'on');
    set(handles.leftaxes,'xlim',handles.sSettings.graph.llimits(1:2)');
    set(handles.leftaxes,'ylim',handles.sSettings.graph.llimits(3:4)');
    try
    set(handles.leftaxes,'zlim',handles.sSettings.graph.llimits(5:6)');
    end
    
function lresetbutton_Callback(hObject, eventdata, handles)
% Clears the left plot to its default state
    cla(handles.leftaxes,'reset'); 
    set(handles.leftaxes,'xlim',[-10 10]);
    set(handles.leftaxes,'ylim',[-10,10]);
    set(handles.leftaxes,'zlim',[-10,10]);
    set(handles.lxlower,'String','-10');
    set(handles.lxupper,'String','10');
    set(handles.lylower,'String','-10');
    set(handles.lyupper,'String','10');
    set(handles.lzlower,'String','-10');
    set(handles.lzupper,'String','10');
    set(handles.leftaxes,'DrawMode','fast')
    hold(handles.leftaxes,'on');
 
    
%%% Create functions    
function leftdataselector_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end    

function lxlower_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function lylower_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function lzlower_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function lxupper_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function lyupper_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function lzupper_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



    
    
    
    
 %%%    
% 
%%%%  --------------------------------------------------------------------+
%   %  Plot control (RIGHT)
 %%%.---------------------------------------------------------------------+    

 %%% DATA SELECTOR
function rightdataselector_Callback(hObject, eventdata, handles)


function rightdataselector_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rightaxes_ButtonDownFcn(hObject, eventdata, handles)
% ZOOMS IN or OUT when the user clicks on the axes
    mouseside = get(gcf,'SelectionType');
    zoomres   = 2;
    xy        = get(0,'PointerLocation');
    
    % ZOOM IN
    if strcmpi(mouseside,'normal')
        limx = handles.sSettings.graph.rlimits(1:2)'.*1/zoomres;
        limy = handles.sSettings.graph.rlimits(3:4)'.*1/zoomres;
        limz = handles.sSettings.graph.rlimits(5:6)'.*1/zoomres;
    % ZOOM OUT    
    else
        limx = handles.sSettings.graph.rlimits(1:2)'.*zoomres;
        limy = handles.sSettings.graph.rlimits(3:4)'.*zoomres;
        limz = handles.sSettings.graph.rlimits(5:6)'.*zoomres;
    end    

    if limx(2) > limx(1), 
        set(handles.rightaxes,'xlim',limx); 
        handles.sSettings.graph.rlimits(1:2) = limx;
        set(handles.rxlower,'String',num2str(limx(1)));
        set(handles.rxupper,'String',num2str(limx(1)));
    end
    if limy(2) > limy(1),
        set(handles.rightaxes,'ylim',limy); 
        handles.sSettings.graph.rlimits(3:4) = limy;
        set(handles.rylower,'String',num2str(limy(1)));
        set(handles.ryupper,'String',num2str(limy(1)));
    
    end    
    if limz(2) > limz(1),
        set(handles.rightaxes,'zlim',limz); 
        handles.sSettings.graph.rlimits(5:6) = limz;
        set(handles.rzlower,'String',num2str(limz(1)));
        set(handles.rzupper,'String',num2str(limz(2)));    
    end
    guidata(hObject, handles)

%%% Limits    
function rxlower_Callback(hObject, eventdata, handles)
% Evaluates the X lower limit for the right axis 
    handles.sSettings.graph.rlimits(1) = str2double(get(hObject,'String'));
    guidata(hObject, handles);    

function rxupper_Callback(hObject, eventdata, handles)
% Evaluates the X upper limit for the right axis
    handles.sSettings.graph.rlimits(2) = str2double(get(hObject,'String'));
    guidata(hObject, handles);    
    
function rylower_Callback(hObject, eventdata, handles)
% Evaluates the Y lower limit for the right axis
    handles.sSettings.graph.rlimits(3) = str2double(get(hObject,'String'));
    guidata(hObject, handles);    
    
    
function ryupper_Callback(hObject, eventdata, handles)
% Evaluates the Y upper limit for the right axis
    handles.sSettings.graph.rlimits(4) = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    

function rzlower_Callback(hObject, eventdata, handles)
% Evaluates the Z lower limit for the right axis
    handles.sSettings.graph.rlimits(5) = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    
function rzupper_Callback(hObject, eventdata, handles)    
% Evaluates the Z lower limit for the right axis
    handles.sSettings.graph.rlimits(6) = str2double(get(hObject,'String'));
    guidata(hObject, handles);    

    

%%% States
function rrealtime_Callback(hObject, eventdata, handles)
% Allows the user to toggle real time plotting on the right axis
    handles.sSettings.graph.rstates(1) =  get(hObject,'Value');
    guidata(hObject, handles);

function rxgrid_Callback(hObject, eventdata, handles)
% Allows the user to toggle the X grid on the right axis
    handles.sSettings.graph.rstates(2) =  get(hObject,'Value');
    guidata(hObject, handles);

function rygrid_Callback(hObject, eventdata, handles)
% Allows the user to toggle the Y grid on the right axis
    handles.sSettings.graph.rstates(3) =  get(hObject,'Value');
    guidata(hObject, handles);

function rzgrid_Callback(hObject, eventdata, handles)
% Allows the user to toggle the Z grid on the right axis
    handles.sSettings.graph.rstates(4) =  get(hObject,'Value');
    guidata(hObject, handles);


    
    
%%% Buttons
function rplotbutton_Callback(hObject, eventdata, handles)
    % Plots data from the previous run on the right axis
    plotcontrol(handles,handles.sEpoch,handles.sAlgo,handles.sStat);

function rrefreshbutton_Callback(hObject, eventdata, handles)
% Changes the plot to accomodate for the new axis' limits
    lim = handles.sSettings.graph.rlimits(1:2)';
    if lim(2) > lim(1)
        set(handles.rightaxes,'xlim',lim);
    end
    lim = handles.sSettings.graph.rlimits(3:4)';
    if lim(2) > lim(1)
        set(handles.rightaxes,'ylim',lim);
    end
    lim = handles.sSettings.graph.rlimits(5:6)';
    if lim(2) > lim(1)
        set(handles.rightaxes,'zlim',lim);
    end
    if handles.sSettings.graph.rstates(2)
        set(handles.rightaxes,'XGrid','on');
    else
        set(handles.rightaxes,'XGrid','off');
    end
    if handles.sSettings.graph.rstates(3)
        set(handles.rightaxes,'YGrid','on');
    else
        set(handles.rightaxes,'YGrid','off');
    end
    if handles.sSettings.graph.rstates(4)
        set(handles.rightaxes,'ZGrid','on');
    else
        set(handles.rightaxes,'ZGrid','on');
    end

function rclearbutton_Callback(hObject, eventdata, handles)
% Clears the right plot 
% save the limits reset the thing and put it back together
    cla(handles.rightaxes,'reset'); 
    set(handles.rightaxes,'DrawMode','fast')
    hold(handles.rightaxes,'on');
    set(handles.rightaxes,'xlim',handles.sSettings.graph.rlimits(1:2)');
    set(handles.rightaxes,'ylim',handles.sSettings.graph.rlimits(3:4)');
    set(handles.rightaxes,'zlim',handles.sSettings.graph.rlimits(5:6)');


function rresetbutton_Callback(hObject, eventdata, handles)
% Resets the right axis to its default state
    cla(handles.rightaxes,'reset'); 
    set(handles.rightaxes,'xlim',[-10 10]);
    set(handles.rightaxes,'ylim',[-10,10]);
    set(handles.rightaxes,'zlim',[-10,10]);
    set(handles.rxlower,'String','-10');
    set(handles.rxupper,'String','10');
    set(handles.rylower,'String','-10');
    set(handles.ryupper,'String','10');
    set(handles.rzlower,'String','-10');
    set(handles.rzupper,'String','10');
    set(handles.rightaxes,'DrawMode','fast')
    hold(handles.rightaxes,'on');

    
%%% Create functions
function rxlower_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
 
function rxupper_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rylower_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ryupper_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rzlower_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rzupper_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    







%%%%
   % 
  %  --------------------------------------------------------------------+
 %   %  Status Control
%    .---------------------------------------------------------------------+    
     
function statustext_ButtonDownFcn(hObject, eventdata, handles)
% Dumps structure information in the MATLAB SHELL
    clc
    numb = fix(abs(rand*6));
    if numb < 1
        set(hObject,'String','Still at your service');
    elseif numb < 2
        set(hObject,'String','What a nice weather today');
    elseif numb < 3
        set(hObject,'String','Easter eggs? I''m not your godfather');
    elseif numb < 4
        set(hObject,'String','1+1=2');
    elseif numb < 5
        set(hObject,'String','It could well be a trivial issue');
    else
        set(hObject,'String','Where is the cake?');
    end    
    
    handles.sSettings.displaymode = ~handles.sSettings.displaymode;
    fprintf('Toggling display to %d\n',handles.sSettings.displaymode)
    fprintf('Contents of sSettings\n')
    disp(handles.sSettings);
    fprintf('Contents of sSettings.lsates\n')
    disp(handles.sSettings.graph.lstates');
    fprintf('Contents of sSettings.rsates\n')
    disp(handles.sSettings.graph.rstates');
    fprintf('Contents of sSettings.llimits\n')
    disp(handles.sSettings.graph.llimits');
    fprintf('Contents of sSettings.rlimits\n')
    disp(handles.sSettings.graph.rlimits');
    try
        fprintf('Contents of sEpoch\n')
        disp(handles.sEpoch);
    catch
        fprintf('\tNot known yet\n');
    end
    try
        fprintf('Contents of sAlgo\n')
        disp(handles.sAlgo);
    catch
        fprintf('\tNot known yet\n');
    end        
        

   

 % %    % %  -------------------------------------------------------------+
%    % %   %  Algorithm Panel                                             |
 % %    % % .-------------------------------------------------------------+   

function startbutton_Callback(hObject, eventdata, handles)
% Main loop callback that is activated on the 'start' button press.
% This loop is where the processing of the data will take place.
% On the fly changes to the parameters can be accepted in the future.

    
    if get(hObject,'Value')
        handles.execution    = 1;
        set(hObject,'String','Stop');
        set(handles.lplotbutton,'enable','on');
        set(handles.rplotbutton,'enable','on');
        set(handles.pausebutton,'enable','on');
        
        sSettings = handles.sSettings;
        save('.gui_session.mat','sSettings');
        if strcmpi(sSettings.operation,'ONLINE')
            set(handles.statustext,'String','Obtaining data from receiver')    
        else
            set(handles.statustext,'String','Reading file')
        end       
        
        [sEpoch,sAlgo,sStat] = configppplab(sSettings);
        obsperiod            = handles.sSettings.receiver.obsperiod;
        time                 = 0;
        if ~sEpoch.operation, set(handles.statustext,'String','Processing data'); end

        % Enter the main loop
        while 1
            while ~get(handles.pausebutton,'Value') && get(hObject,'Value') ...
                  && sEpoch.iEpoch < sEpoch.nbEpoch && time <= obsperiod
                % do work
                time = time + 1;
                if time == obsperiod, break; end;
                [ sEpoch, sAlgo, sStat ] = workflow( sEpoch, sAlgo, sStat, sSettings);
                plotcontrol(handles,sEpoch,sAlgo,sStat);
                handles.sAlgo = sAlgo;
                handles.sStat = sStat;
            end
            % Evals if user paused execution
            if get(handles.pausebutton,'Value')
                set(handles.pausebutton,'String','Continue')
                waitfor(handles.pausebutton, 'Value', 0);
                set(handles.pausebutton,'String','Pause')
            else
                break;
            end
        end
        strdate                 = datestr(now);
        strdate(strdate==':') = '-';
        save(['run',strdate,'.mat'],'sEpoch')
        handles.execution = 0;
        sSettings.time.gpsweekday = sEpoch.WD;
        sSettings.time.gpsweek    = sEpoch.WN;
        handles.sSettings         = sSettings;
        handles.sEpoch            = sEpoch;
        handles.sAlgo             = sAlgo;
        handles.sStat             = sStat;
        guidata(hObject, handles);
        set(hObject,'Value',0);
        set(hObject,'String','Start');
        set(handles.statustext,'String','Data processing completed')
        set(handles.generatereport,'enable','on');
    else
        % Algorithm is not running
        handles. execution = 0;
        set(handles.pausebutton,'String','Pause')
        set(handles.pausebutton,'Value',0)
        set(hObject,'String','Start');  
        set(handles.statustext,'String','Run stopped');
    end
    
% For future reference a callback might be used to draw the data in the
% axis special attention must be given to the estimate update which must be
% propagated somehow
% function drawdata_Callback(hObject, eventdata, handles,sEpoch,sAlgo,sStat)
% % Timer function for updating the status clock
%     handles.sSettings.graph.lstates(1) = get(handles.lrealtime,'Value');
%     handles.sSettings.graph.rstates(1) = get(handles.rrealtime,'Value');
%     plotcontrol(handles,sEpoch,sAlgo,sStat);

function generatereport_Callback(hObject, eventdata, handles)
% hObject    handle to generatereport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function gui_CloseRequestFcn(hObject, eventdata, handles)
% This functions is run when the user exits the GUI. Clean up routines
% should be carried out here.
    
    if isequal(get(hObject,'waitstatus'),'waiting')
        uiresume(hObject);
    end
    stop(handles.towclock);
    delete(hObject);


function pausebutton_Callback(hObject, eventdata, handles)

   
% --------------------------------------------------------------------
function fileguimenu_Callback(hObject, eventdata, handles)

function openguimenu_Callback(hObject, eventdata, handles)

function settingspanel_Callback(hObject, eventdata, handles)
    handles.usersettings = gui_settingspanel(handles.debug);
    handles.sSettings    = gui_setppplabsettings(handles.usersettings, handles.debug);
    guidata(hObject, handles);


    
    
% --------------------------------------------------------------------
function viewmenu_Callback(hObject, eventdata, handles)

function onepanelview_Callback(hObject, eventdata, handles)
    if strcmpi(get(hObject,'checked'),'on')
        set(hObject,'checked','off')
        set(handles.devbytext,'Visible','off');
        set(handles.rightdatapanel,'Visible','off');
        handles.leftdatapos = get(handles.leftdatapanel,'position');
        handles.guipos      = get(handles.gui,'position');
        handles.statuspos   = get(handles.statuspanel,'position');
        set(handles.statuspanel,'position',[265 30 330 33]);
        set(handles.gui,'position',[97 290 620 699]);
        set(handles.leftdatapanel,'position',[60 77 500 608]);
        movegui(handles.gui,'center');
    else
        set(hObject,'checked','on')
        set(handles.rightdatapanel,'Visible','on');
        set(handles.devbytext,'Visible','on');
        set(handles.leftdatapanel,'position',handles.leftdatapos);
        set(handles.gui,'position',handles.guipos);
        set(handles.statuspanel,'position',handles.statuspos);
        movegui(handles.gui,'center');
    end
    guidata(hObject, handles);
%         set(handles.istaxes,'Visible','off');
%         set(handles.itaxes,'Visible','off');
%         set(handles.gmvaxes,'Visible','off');


% For future dev
function [w,h] = pixel2normalized(pix,posvector)
% Input is desired length in pixels,
% and a normalized posvector indicating the part of the screen that we are usin

% We need the size of 1 pixel:
% First get size of screen in pixels
[wpix,hpix] = getscreensize;

% One pixels will take up 1/wpix of the whole screen
% The window will take up posvector(3) of the whole screen.,
% so one pixel in a window will be relatively larger
w=(pix/wpix)/posvector(3);
h=(pix/hpix)/posvector(4);



