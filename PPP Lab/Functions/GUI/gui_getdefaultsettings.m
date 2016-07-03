function screen = gui_getdefaultsettings()

        % ONLINE PANEL
        screen.online.enable         = 'on';
        screen.online.enablebutton   = 1;
        screen.online.gpscom         = 'COM1';
        screen.online.gpsreceiver    = 1;
        screen.online.gpsobsperiod   = 3600;
        screen.online.gpsrate        = 1;
        screen.online.gpslog         = 1;
        screen.online.gpsstore       = 1;
        screen.online.gpsreset       = 0;
        screen.online.gpsconf        = 0;
        screen.online.useimu         = 0;
        screen.online.gpsreceiverstr = 'Pro Flex 500';
        screen.online.gpslogstr      = 'SN';
        
        % OFFLINE PANEL
        screen.offline.enable        = 'off';
        screen.offline.enablebutton  = 0;
        screen.offline.gpsday        = 29;
        screen.offline.gpsmonth      = 3;
        screen.offline.gpsyear       = 2012;
        screen.offline.gpsstartepoch = NaN;
        screen.offline.gpsfinalepoch = NaN;
        screen.offline.gpslogtype    = 1;
        screen.offline.readimu       = 0;
        screen.offline.gpslogtypestr = 'SN';
        if isunix
            screen.offline.gpsdisplaypath = '../Aquisition/rcvdata/'; % default path
        else
            screen.offline.gpsdisplaypath = '..\Aquisition\rcvdata\'; % default path
        end
        
        % ALGORITHM PANEL
        screen.algo.algoselector         = 1;
        screen.algo.algoorbitproduct     = 1;
        screen.algo.algoclockproduct     = 1;
        screen.algo.algointerpolation    = 1;
        screen.algo.algopolysatdeg       = 12;
        screen.algo.algopolyclkdeg       = 3;
        screen.algo.algosatvelocity      = 1;
        screen.algo.algodatagaps         = 0;
        screen.algo.algocsdetection      = 0;
        screen.algo.algocscorrection     = 0;
        screen.algo.algotropocorrection  = 0;
        screen.algo.algoionocorrection   = 0;
        screen.algo.algoselectorstr      = 'SPP';
        screen.algo.algoorbitproductstr  = 'Broadcast';
        screen.algo.algoclockproductstr  = 'Broadcast';
        screen.algo.algointerpolationstr = 'Neville';
        screen.algo.algosatvelocitystr   = 'Ephemerides';
        
        % IMU PANEL
        screen.imu.enable       = 'off';
        screen.imu.imucom       = 'COM2';
        screen.imu.imudevice    = 1;
        screen.imu.imudevicestr = '6DoF';
        screen.imu.imurate      = 0.01;
        screen.imu.imucalibrate = 1;
        screen.imu.imustore     = 1;
        
        
        % Verbose level
        screen.displaymode = 0;
        
end