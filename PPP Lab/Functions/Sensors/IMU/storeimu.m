function storeimu( IMU, TOW )
%STOREIMU saves IMU measurements to logfile

    fid = fopen(IMU.logfyle,'a');
    fprintf(fid,'%d ',TOW+1);
    fprintf(fid,'%f %f %f ',IMU.velocity);
    fprintf(fid,'%f %f %f\r\n',IMU.position);
    fclose(fid);
% Save windows elsewhere
end

