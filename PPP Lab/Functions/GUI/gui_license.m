function varargout = gui_license(varargin)
% GUI_LICENSE MATLAB code for gui_license.fig
%      GUI_LICENSE, by itself, creates a new GUI_LICENSE or raises the existing
%      singleton*.
%
%      H = GUI_LICENSE returns the handle to a new GUI_LICENSE or the handle to
%      the existing singleton*.
%
%      GUI_LICENSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_LICENSE.M with the given input arguments.
%
%      GUI_LICENSE('Property','Value',...) creates a new GUI_LICENSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_license_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_license_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_license

% Last Modified by GUIDE v2.5 23-Jul-2012 04:00:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_license_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_license_OutputFcn, ...
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


% --- Executes just before gui_license is made visible.
function gui_license_OpeningFcn(hObject, eventdata, handles, varargin)
    
    logo = imread('img/istlogoname.png');
    imshow(logo,'Parent',handles.istaxes);
    logo = imread('img/itlogoname.png');  % Load a test image
    imshow(logo,'Parent',handles.itaxes);
    logo = imread('img/cc.png');
    imshow(logo,'Parent',handles.ccimg);
    handles.decision = 0;
    movegui(hObject,'center');
    guidata(hObject, handles);
    uiwait(handles.cclicense);


% --- Outputs from this function are returned to the command line.
function varargout = gui_license_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.decision;
    delete(handles.cclicense);


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
    handles.decision = 1;
    guidata(hObject, handles);
    uiresume(handles.cclicense);
    
% --- Executes on button press in nokbutton.
function nokbutton_Callback(hObject, eventdata, handles)
    handles.decision = 0;
    guidata(hObject, handles);
    uiresume(handles.cclicense);
%     gui_license_OutputFcn(hObject, eventdata, handles);


% --- Executes when user attempts to close cclicense.
function cclicense_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'waitstatus'),'waiting')
        uiresume(hObject);
    else
        delete(hObject);
    end
