function handles = gui_initstatus(handles,varargin)
    
    % Set images to gui
    logo = imread('img/istlogoname.png');
    imshow(logo,'Parent',handles.istaxes);
    logo = imread('img/itlogoname.png');  % Load a test image
    imshow(logo,'Parent',handles.itaxes);
    logo = imresize(imread('img/gmv.png'),8);  % Load a test image
    imshow(logo,'Parent',handles.gmvaxes);
    
    % Start clock
    clk = clock;
    gpstow = getweeksec(weekday(date)-1,clk(4),clk(5),clk(6));
    set(handles.towstatustext,'String',num2str(fix(gpstow)));
    handles.towclock = timer('TimerFcn',{@towclock_Callback,handles.towstatustext},...
                             'ObjectVisibility','off','startdelay',1,...
                             'Period',1,...
                             'executionmode','fixedspacing',...
                             'ObjectVisibility','off');   
    start(handles.towclock);
    set(handles.statustext,'String','At your service');
    
end


function towclock_Callback(hObject, eventdata, handle)
% Timer function for updating the status clock
    clk = clock;
    gpstow = getweeksec(weekday(date)-1,clk(4),clk(5),clk(6));
    set(handle,'String',num2str(fix(gpstow)));
end