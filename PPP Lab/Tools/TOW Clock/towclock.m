function varargout = towclock(varargin)
% TOWCLOCK MATLAB code for towclock.fig
%      TOWCLOCK, by itself, creates a new TOWCLOCK or raises the existing
%      singleton*.
%
%      H = TOWCLOCK returns the handle to a new TOWCLOCK or the handle to
%      the existing singleton*.
%
%      TOWCLOCK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOWCLOCK.M with the given input arguments.
%
%      TOWCLOCK('Property','Value',...) creates a new TOWCLOCK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before towclock_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to towclock_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help towclock

% Last Modified by GUIDE v2.5 28-Jan-2012 02:16:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @towclock_OpeningFcn, ...
                   'gui_OutputFcn',  @towclock_OutputFcn, ...
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


% --- Executes just before towclock is made visible.
function towclock_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to towclock (see VARARGIN)

% Choose default command line output for towclock
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes towclock wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = towclock_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in runit.
function runit_Callback(hObject, eventdata, handles)
% hObject    handle to runit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of runit

    while get(hObject,'value')
        clk  = clock;
        hour = clk(4);
        min  = clk(5);
        sec  = clk(6);
        tow = getweeksec(weekday(datenum(date))-1, hour, min, fix(sec));
        
        drawnow;
        
        
        set(handles.hourdisplay,'String',hour);
        set(handles.mindisplay,'String',min);
        set(handles.secdisplay,'String',fix(sec));
        
        set(handles.TOW,'String',tow);
        
    end    



% --- Executes during object creation, after setting all properties.
function hourdisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hourdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
clk = clock;
hour = clk(4);
set(hObject,'String',hour);





% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over runit.
function runit_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to runit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% clk = clock;
% 
% hour = clk(4);
% min  = clk(5);
% sec  = clk(6);
% 
% set(handles.hourdisplay,'String',hour);
% set(handles.mindisplay,'String',min);
% set(handles.secdisplay,'String',sec);


% --- Executes during object creation, after setting all properties.
function datedisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',date);


% --- Executes during object creation, after setting all properties.
function mindisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mindisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
clk  = clock;
min  = clk(5);
set(hObject,'String',min);


% --- Executes during object creation, after setting all properties.
function secdisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
clk  = clock;
sec  = fix(clk(6));
set(hObject,'String',sec);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
