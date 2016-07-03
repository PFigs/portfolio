function gui_setvalues(handles, screen)

    % ONLINE PANEL SETTER
    set(findall(handles.onlinepanel, '-property', 'enable'), 'enable', screen.online.enable);
    set(handles.onlineenable,'Value',screen.online.enablebutton);
    set(handles.gpscom,'String',screen.online.gpscom);
    set(handles.gpsreceiver,'Value',screen.online.gpsreceiver);
    set(handles.gpsobsperiod,'String',screen.online.gpsobsperiod);
    set(handles.gpsrate,'String',screen.online.gpsrate);
    set(handles.gpslog,'Value',screen.online.gpslog);
    set(handles.gpsstore,'Value',screen.online.gpsstore);
    set(handles.gpsreset,'Value',screen.online.gpsreset);
    set(handles.gpsconf,'Value',screen.online.gpsconf);
    set(handles.useimu,'Value',screen.online.useimu);
        
    % OFFLINE PANEL SETTER
    set(findall(handles.offlinepanel, '-property', 'enable'), 'enable', screen.offline.enable);
    set(handles.offlineenable,'Value',screen.offline.enablebutton);
    set(handles.gpsday,'String',sprintf('%d',screen.offline.gpsday));
    set(handles.gpsmonth,'String',sprintf('%d',screen.offline.gpsmonth));
    set(handles.gpsyear,'String',sprintf('%d',screen.offline.gpsyear));
    set(handles.gpsstartepoch,'String',sprintf('%d',screen.offline.gpsstartepoch));
    set(handles.gpsfinalepoch,'String',sprintf('%d',screen.offline.gpsfinalepoch));
    set(handles.gpsdisplaypath,'String',screen.offline.gpsdisplaypath);
    set(handles.gpslogtype,'Value',screen.offline.gpslogtype);
    set(handles.readimu,'Value',screen.offline.readimu);
    
    % ALGO PANEL SETTER
    set(handles.algoselector,'Value',screen.algo.algoselector);
    set(handles.algoorbitproduct,'Value',screen.algo.algoorbitproduct);
    set(handles.algoclockproduct,'Value',screen.algo.algoclockproduct);
    set(handles.algointerpolation,'Value',screen.algo.algointerpolation);
    set(handles.algopolysatdeg,'String',sprintf('%d',screen.algo.algopolysatdeg));
    set(handles.algopolyclkdeg,'String',sprintf('%d',screen.algo.algopolyclkdeg));
    set(handles.algosatvelocity, 'Value',screen.algo.algosatvelocity);
    set(handles.algodatagaps,'Value',screen.algo.algodatagaps);
    set(handles.algocsdetection,'Value',screen.algo.algocsdetection);
    set(handles.algocscorrection, 'Value',screen.algo.algocscorrection);
    set(handles.algotropocorrection, 'Value',screen.algo.algotropocorrection);    
    set(handles.algoionocorrection, 'Value',screen.algo.algoionocorrection);
    
    % IMU PANEL SETTER
    set(findall(handles.imupanel, '-property', 'enable'), 'enable', screen.imu.enable);
    set(handles.imucom,'String',screen.imu.imucom);
    set(handles.imudevice,'Value',screen.imu.imudevice);
    set(handles.imurate,'String',sprintf('%f',screen.imu.imurate));
    set(handles.imucalibrate,'Value',screen.imu.imucalibrate);
    set(handles.imustore,'Value',screen.imu.imustore);
    set(handles.readimu,'Value',strcmpi(screen.imu.enable,'on'));
    set(handles.useimu,'Value',strcmpi(screen.imu.enable,'on'));
    
    % VERBOSE
    set(handles.displaymode,'String',sprintf('%d',screen.displaymode));

end