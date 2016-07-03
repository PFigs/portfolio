function createreport(sEpoch,sAlgo,sSettings,sStat,runname,varargin)
%CREATEREPORT
%
%   INPUT
%   sEpoch    - structure with epoch data
%   sAlgo     - structure with algo data
%   sSettings - structure with settings data
%   sStat     - structure with statistics
%   runname   - Name to identify the report
%
%   OUTPUT
%   Creates a directory with the tex files and figures necessary to compile
%   a pdf report. It also prints out the necessary makefiles and saves the
%   data in a .mat file
%
%   Pedro Silva, Instituto Superior Tecnico, February 2013


    if nargin < 6
        printkml = 0;
    else
        printkml = 1;
    end

    if sSettings.algorithm.csdetection
        strobs = [runname,'-CSON-'];
    else
        strobs = [runname,'-CSOFF-'];
    end

    if sSettings.algorithm.datagaps
        strobs = [strobs,'-REGENON-'];
    else
        strobs = [strobs,'-REGENOFF-'];
    end
    if sSettings.algorithm.antex
        strobs = [strobs,'-ATX-'];
    else
        strobs = [strobs,'-NotATX-'];
    end
    if sSettings.algorithm.smooth
        strobs = [strobs,'-SM-'];
    else
        strobs = [strobs,'-NotSM-'];
    end

    strobs = [strobs,sAlgo.algtype,sAlgo.flags.freqmode,sAlgo.flags.orbitproduct(1:3),sAlgo.flags.clockproduct(1:3)];

    folderpath                = ['./Report/',strobs,'/'];
    twopoints                 = datestr(now);
    twopoints(twopoints==':') = '-';
    disp('Saving workspace...');
    try
        save([folderpath,'data/',twopoints,sAlgo.algtype,'.mat'],'sEpoch','sAlgo','sStat','sSettings');
    catch
        try
            disp('Retrying - creating folder');
            mkdir([folderpath,'data/']);
            save([folderpath,'data/',twopoints,sAlgo.algtype,'.mat'],'sEpoch','sAlgo','sStat','sSettings');
        catch
            disp('couldn''t save run data');
        end
    end

    if printkml
        llapoints = eceftolla(sStat.userxyz(1:135,:));
        pwr_kml('test',llapoints);
    end

    reportgenerator(sSettings,sAlgo,sStat,sEpoch,'force','silent','name',...
                    [twopoints,'-',strobs],'folderpath',folderpath,'skip','00010');

end