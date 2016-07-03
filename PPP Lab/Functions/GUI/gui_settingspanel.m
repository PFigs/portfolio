function varargout = gui_settingspanel(varargin)
% GUI_SETTINGSPANEL MATLAB code for gui_settingspanel.fig
%      GUI_SETTINGSPANEL, by itself, creates a new GUI_SETTINGSPANEL or raises the existing
%      singleton*.
%
%      H = GUI_SETTINGSPANEL returns the handle to a new GUI_SETTINGSPANEL or the handle to
%      the existing singleton*.
%
%      GUI_SETTINGSPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_SETTINGSPANEL.M with the given input arguments.
%
%      GUI_SETTINGSPANEL('Property','Value',...) creates a new GUI_SETTINGSPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_settingspanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_settingspanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% TODO:
% Add reference point
% Add receiver messages
% Add compute dtr
% Add logging path

% Last Modified by GUIDE v2.5 24-Jul-2012 00:26:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_settingspanel_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_settingspanel_OutputFcn, ...
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


% --- Executes just before gui_settingspanel is made visible.
function gui_settingspanel_OpeningFcn(hObject, eventdata, handles, varargin)

    % Evaluates debug flag
    if nargin == 4
        handles.debug = varargin{1};
    end
handles.debug = 1;
    % Retrieve data from previous session
    if exist('.gui_settings.mat','file');
        load('.gui_settings.mat');
        handles.usersettings = usersettings;
    % Default values
    else
        handles.usersettings = gui_getdefaultsettings();
    end
    
    % Modifies screen 
    gui_setvalues(handles, handles.usersettings);
    movegui(hObject,'center');
%     set(hObject, 'Color', [0.941 0.941 0.941]);
    
    % Updates handles
    
    guidata(hObject, handles);
    uiwait(handles.settingsgui);


function varargout = gui_settingspanel_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.usersettings;
    usersettings = handles.usersettings;
    save('.gui_settings.mat','usersettings');
    delete(handles.settingsgui);





 % %
%  % --------------------------------------------------------------------+
   %    Operation Panel                                                  |
 % % % .-----------------------------------------------------------------+   
function operationpanel_SelectionChangeFcn(hObject, eventdata, handles)
    button =  get(eventdata.NewValue,'Tag');
    if strcmpi(button,'onlineenable')
        set(findall(handles.onlinepanel, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.offlinepanel, '-property', 'enable'), 'enable', 'off');
        handles.usersettings.online.enable  = 'on';
        handles.usersettings.offline.enable = 'off';
        handles.usersettings.online.enablebutton  = 1;
        handles.usersettings.offline.enablebutton = 0;
        
    elseif strcmpi(button,'offlineenable')
        set(findall(handles.offlinepanel, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.onlinepanel, '-property', 'enable'), 'enable', 'off');
        handles.usersettings.online.enable  = 'off';
        handles.usersettings.offline.enable = 'on';
        handles.usersettings.online.enablebutton  = 0;
        handles.usersettings.offline.enablebutton = 1;
    end
    
    % Update handles structure
    guidata(hObject, handles);

    
    
    

%%%%    
   % 
%%%% --------------------------------------------------------------------+
%     Receiver Panel
%%%% .-------------------------------------------------------------------+        
function gpscom_Callback(hObject, eventdata, handles)
    comstr = get(hObject,'String');
    if strcmp(comstr(1:3),'COM')
        handles.usersettings.online.gpscom = get(hObject,'String');
        if handles.debug 
            fprintf('Changed input to %s\n',comstr);
        end
    else
        errordlg('Invalid COM port','Invalid value');
    end
    
    guidata(hObject, handles);


function gpsreceiver_Callback(hObject, eventdata, handles)  
    receiver = cellstr(get(hObject,'String'));
    handles.usersettings.online.gpsreceiverstr = receiver{get(hObject,'Value')};
    handles.usersettings.online.gpsreceiver    = get(hObject,'Value');
    if handles.debug
        fprintf('Receiver changed to %s\n',handles.usersettings.online.gpsreceiverstr);
    end 
    guidata(hObject, handles);


function gpsobsperiod_Callback(hObject, eventdata, handles)
    obsperiod = str2double(get(hObject,'String'));
    if obsperiod > 0
        handles.usersettings.online.gpsobsperiod = obsperiod;
        if handles.debug
            fprintf('Observation period changed to %d\n',handles.usersettings.online.gpsobsperiod);
        end
        guidata(hObject, handles);
    end

function gpsrate_Callback(hObject, eventdata, handles)
    handles.usersettings.online.gpsrate = str2double(get(hObject,'String'));
    if handles.debug
        fprintf('Receiver rate changed to %d\n',handles.usersettings.online.gpsrate);
    end
    guidata(hObject, handles);


function gpslog_Callback(hObject, eventdata, handles)
    logtype = cellstr(get(hObject,'String'));
    handles.usersettings.online.gpslogstr = logtype{get(hObject,'Value')};  
    handles.usersettings.online.gpslog    = get(hObject,'Value');
    if handles.debug
        fprintf('Log type changed to %s\n',handles.usersettings.online.gpslogstr);
    end
    guidata(hObject, handles);    
    

function gpsstore_Callback(hObject, eventdata, handles)
    handles.usersettings.online.gpsstore = get(hObject,'Value');
    if handles.debug
        fprintf('Save data changed to %d\n',handles.usersettings.online.gpsstore);
    end
    guidata(hObject, handles);  


function gpsreset_Callback(hObject, eventdata, handles)
    handles.usersettings.online.gpsreset = get(hObject,'Value');
    if handles.debug
        fprintf('Receiver reset changed to %d\n',handles.usersettings.online.gpsreset);
    end
    guidata(hObject, handles);  



function gpsconf_Callback(hObject, eventdata, handles)
    handles.usersettings.online.gpsconf = get(hObject,'Value');
    if handles.debug
        fprintf('Receiver configuration changed to %d\n',handles.usersettings.online.gpsconf);
    end
    guidata(hObject, handles);  


function useimu_Callback(hObject, eventdata, handles)
    handles.usersettings.offline.readimu = get(hObject,'Value');
    if get(hObject,'Value')
        set(findall(handles.imupanel, '-property', 'enable'), 'enable', 'on');
        handles.usersettings.imu.enable = 'on';
    else
        set(findall(handles.imupanel, '-property', 'enable'), 'enable', 'off');
        handles.usersettings.imu.enable = 'off';
    end
    if handles.debug
        fprintf('Read IMU changed to %s\n',handles.usersettings.imu.enable);
    end
    guidata(hObject, handles); 
    
    
    
    
    
%%%%    
   % 
%%%% --------------------------------------------------------------------+
   %  File Panel
%%%% .-------------------------------------------------------------------+    
     
function gpsday_Callback(hObject, eventdata, handles)
    value = str2double(get(hObject,'String'));
    if value > 0 && value <= 31
        handles.usersettings.offline.gpsday = value;
        if handles.debug
            fprintf('Receiver rate changed to %d\n',handles.usersettings.offline.gpsday);
        end
        guidata(hObject, handles);
    end



function gpsmonth_Callback(hObject, eventdata, handles)
    value = str2double(get(hObject,'String'));
    if value > 0 && value <= 12
        handles.usersettings.offline.gpsmonth = value;
        if handles.debug
            fprintf('Receiver rate changed to %d\n',handles.usersettings.offline.gpsmonth);
        end
        guidata(hObject, handles);
    end


function gpsyear_Callback(hObject, eventdata, handles)
    value = str2double(get(hObject,'String'));
    if value > 2000    
        handles.usersettings.offline.gpsyear = value;
        if handles.debug
            fprintf('Receiver rate changed to %d\n',handles.usersettings.offline.gpsyear);
        end
        guidata(hObject, handles);   
    end
    
    
function gpsstartepoch_Callback(hObject, eventdata, handles)    
    value = str2double(get(hObject,'String'));
    if value > 0 || isnan(value)
        handles.usersettings.offline.gpsstartepoch = value;
        if handles.debug
            fprintf('Starting epoch changed to %d\n',handles.usersettings.offline.gpsstartepoch);
        end
        guidata(hObject, handles);
    end
        


function gpsfinalepoch_Callback(hObject, eventdata, handles)
    value = str2double(get(hObject,'String'));
    if value > 0 || isnan(value)
        handles.usersettings.offline.gpsfinalepoch = value;
        if handles.debug
            fprintf('Starting epoch changed to %d\n',handles.usersettings.offline.gpsfinalepoch);
        end
        guidata(hObject, handles);
    end




function gpsopenlog_Callback(hObject, eventdata, handles)
    directory = uigetdir( pwd(), 'Select a folder with GPS observations');
    if directory
        handles.usersettings.offline.gpsdisplaypath = strcat( directory,'/');
    
        if handles.debug
            fprintf('Reading observations from %s/\n',directory);
        end
        if isunix 
            slashpos   = directory == '/';
        else
            slashpos   = directory == '\';
        end
        nbvector   = 1:length(directory);
        slashpos   = nbvector(slashpos);
        foldername = directory(slashpos(end):end);
    
        set(handles.gpsdisplaypath,'String',foldername);
        guidata(hObject, handles);
    end
    

function gpslogtype_Callback(hObject, eventdata, handles)
    logtype = cellstr(get(hObject,'String'));
    handles.usersettings.offline.gpslogtypestr = logtype{get(hObject,'Value')};        
    handles.usersettings.offline.gpslogtype    = get(hObject,'Value');
    if handles.debug
        fprintf('Log type changed to %s\n',handles.usersettings.offline.gpslogtypestr);
    end
    guidata(hObject, handles);        
    
    
function readimu_Callback(hObject, eventdata, handles)
    handles.usersettings.offline.readimu = get(hObject,'Value');
    if get(hObject,'Value')
        set(findall(handles.imupanel, '-property', 'enable'), 'enable', 'on');
        handles.usersettings.imu.enable = 'on';
    else
        set(findall(handles.imupanel, '-property', 'enable'), 'enable', 'off');
        handles.usersettings.imu.enable = 'off';
    end
    if handles.debug
        fprintf('Read IMU changed to %s\n',handles.usersettings.imu.enable);
    end
    guidata(hObject, handles);  
    
    
    
    

    
    
    
    
    
    
    
%  %    
%  %
%%%% --------------------------------------------------------------------+
   %  Algo Panel
   % .-------------------------------------------------------------------+      
   
function algoselector_Callback(hObject, eventdata, handles)
    value = cellstr(get(hObject,'String'));
    handles.usersettings.algo.algoselectorstr = value{get(hObject,'Value')};        
    handles.usersettings.algo.algoselector    = get(hObject,'Value');
    if handles.debug
        fprintf('Algorithm changed to %s\n',handles.usersettings.algo.algoselectorstr);
    end
    guidata(hObject, handles);  


function algoorbitproduct_Callback(hObject, eventdata, handles)
    value = cellstr(get(hObject,'String'));
    handles.usersettings.algo.algoorbitproductstr = value{get(hObject,'Value')};        
    handles.usersettings.algo.algoorbitproduct    = get(hObject,'Value');
    if handles.debug
        fprintf('Orbit product changed to %s\n',handles.usersettings.algo.algoorbitproductstr);
    end
    guidata(hObject, handles);  



function algoclockproduct_Callback(hObject, eventdata, handles)    
    value = cellstr(get(hObject,'String'));
    handles.usersettings.algo.algoclockproductstr = value{get(hObject,'Value')};        
    handles.usersettings.algo.algoclockproduct    = get(hObject,'Value');
    if handles.debug
        fprintf('Clock product changed to %s\n',handles.usersettings.algo.algoclockproductstr);
    end
    guidata(hObject, handles);   
    
    
function algointerpolation_Callback(hObject, eventdata, handles)
    value = cellstr(get(hObject,'String'));
    handles.usersettings.algo.algoclockproductstr = value{get(hObject,'Value')}; 
    handles.usersettings.algo.algoclockproduct    = get(hObject,'Value');
    if handles.debug
        fprintf('Clock product changed to %s\n',handles.usersettings.algo.algoclockproductstr);
    end
    guidata(hObject, handles); 


function algopolysatdeg_Callback(hObject, eventdata, handles)
    value = str2double(get(hObject,'String'));
    if value > 0    
        handles.usersettings.algo.algopolysatdeg = value;
        if handles.debug
            fprintf('Interpolation degree for sat product changed to %d\n',handles.usersettings.algo.algopolysatdeg);
        end
        guidata(hObject, handles);   
    end

function algopolyclkdeg_Callback(hObject, eventdata, handles)
    value = str2double(get(hObject,'String'));
    if value > 0   
        handles.usersettings.algo.algopolyclkdeg = value;
        if handles.debug
            fprintf('Interpolation degree for sat product changed to %d\n',handles.usersettings.algo.algopolyclkdeg);
        end
        guidata(hObject, handles);   
    end

function algosatvelocity_Callback(hObject, eventdata, handles)
    value = cellstr(get(hObject,'String'));
    handles.usersettings.algo.algosatvelocitystr = value{get(hObject,'Value')}; 
    handles.usersettings.algo.algosatvelocity    = get(hObject,'Value');
    if handles.debug
        fprintf('Sat velocity changed to %s\n',handles.usersettings.algo.algosatvelocitystr);
    end
    guidata(hObject, handles); 
    
    
function algodatagaps_Callback(hObject, eventdata, handles)
    handles.usersettings.algo.algodatagaps = get(hObject,'Value');
    if handles.debug
        fprintf('Data gaps changed to %d\n',handles.usersettings.algo.algodatagaps);
    end
    guidata(hObject, handles);  


function algocsdetection_Callback(hObject, eventdata, handles)
    handles.usersettings.algo.algocsdetection = get(hObject,'Value');
    if handles.debug
        fprintf('Cycle slip detection changed to %d\n',handles.usersettings.algo.algocsdetection);
    end
    guidata(hObject, handles);  

function algocscorrection_Callback(hObject, eventdata, handles)
    handles.usersettings.algo.algocscorrection = get(hObject,'Value');
    if handles.debug
        fprintf('Cycle slip correction changed to %d\n',handles.usersettings.algo.algocscorrection);
    end
    guidata(hObject, handles);  

function algotropocorrection_Callback(hObject, eventdata, handles)
    handles.usersettings.algo.algotropocorrection = get(hObject,'Value');
    if handles.debug
        fprintf('Tropo correction changed to %d\n',handles.usersettings.algo.algotropocorrection);
    end
    guidata(hObject, handles);  

function algoionocorrection_Callback(hObject, eventdata, handles)    
    handles.usersettings.algo.algoionocorrection = get(hObject,'Value');
    if handles.debug
        fprintf('Iono correction changed to %d\n',handles.usersettings.algo.algoionocorrection);
    end
    guidata(hObject, handles);  
    
    
    
    
    
    
%%%%
%  
%%%% --------------------------------------------------------------------+
   %  IMU Panel
%%%% .-------------------------------------------------------------------+     
   
function imucom_Callback(hObject, eventdata, handles)
    handles.usersettings.imu.imucom = get(hObject,'String');   
    if handles.debug
        fprintf('IMU COM changed to %s\n',handles.usersettings.imu.imucom);
    end
    guidata(hObject, handles);  
 
function imudevice_Callback(hObject, eventdata, handles)
    value = cellstr(get(hObject,'String'));
    handles.usersettings.imu.imudevicestr = value{get(hObject,'Value')}; 
    handles.usersettings.imu.imudevice    = get(hObject,'Value');
    if handles.debug
        fprintf('IMU device changed to %s\n',handles.usersettings.imu.imudevicestr);
    end
    guidata(hObject, handles); 


function imurate_Callback(hObject, eventdata, handles)  
    handles.usersettings.imu.imurate = str2double(get(hObject,'String'));   
    if handles.debug
        fprintf('IMU COM changed to %s\n',handles.usersettings.imu.imurate);
    end
    guidata(hObject, handles);  
    
    
function imucalibrate_Callback(hObject, eventdata, handles)
    handles.usersettings.imu.imucalibrate = get(hObject,'Value');
    if handles.debug
        fprintf('IMU calibration changed to %d\n',handles.usersettings.imu.imucalibrate);
    end
    guidata(hObject, handles); 


function imustore_Callback(hObject, eventdata, handles)
    handles.usersettings.imu.imustore = get(hObject,'Value');
    if handles.debug
        fprintf('IMU calibration changed to %d\n',handles.usersettings.imu.imustore);
    end
    guidata(hObject, handles); 

function displaymode_Callback(hObject, eventdata, handles)
    handles.usersettings.displaymode = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    
%%%%
%  
%%%% --------------------------------------------------------------------+
%  %  Cleanup functions
%%%% .-------------------------------------------------------------------+        
% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
    uiresume(handles.settingsgui);



function settingsgui_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'waitstatus'),'waiting')
        uiresume(hObject);
    else
        delete(hObject);
    end
    
    
    
%%%%
   %  
  %%% -------------------------------------------------------------------+
   %  Create functions
   % .-------------------------------------------------------------------+       
    
function gpsobsperiod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    
function algointerpolation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function algopolysatdeg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function algopolyclkdeg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function algosatvelocity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsyear_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsmonth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsday_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsstartepoch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsfinalepoch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsdisplaypath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpslogtype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsreceiver_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpscom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsrate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpslog_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function imucom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function imudevice_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function imurate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function algoorbitproduct_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function algoclockproduct_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function algoselector_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsreset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gpsreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function displaymode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displaymode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
