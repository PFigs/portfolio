function reportgenerator(sSettings,sAlgo,sStat,sEpoch,varargin)
%REPORTGENERATOR creates several latex files that are compiled under a
%latex template.
%
% Pedro Silva, Instituto Superior Tecnico, May 2012
    fids = fopen('all');
    for f=fids
        fclose(f);
    end
    
    reportname  = 'PPPReport';
    folderpath  = './Report/';
    papertype   = 'a4paper';
    fontsize    = 11;
    margins     = [2 2 1 1]; %[left bottom right top]
    latexstyle  = 'report';
    sections    = {};
    isections   = 0;
    forceflag   = 0;
    skipgmaps   = 0;
    reporttitle = 'PPP Lab Suite Report';
    silent      = 0;
    ellipseconf = 0.95;
    skipsections = zeros(10,1);

    if nargin >= 5
       for i=1:size(varargin,2)
           if strcmpi(varargin{i},'folderpath')
               folderpath = varargin{i+1};
           elseif strcmpi(varargin{i},'name') || strcmpi(varargin{i},'report name')
               reportname = varargin{i+1};
           elseif strcmpi(varargin{i},'clean')
               if exist([folderpath,'Makefile'],'file')
                   system(['cd ',folderpath,'; make clean']);
               else
                   forceflag = 1;
               end
           elseif strcmpi(varargin{i},'force')
               forceflag = 1;
           elseif strcmpi(varargin{i},'skip')
               skipsections = varargin{i+1};
               skipsections=skipsections == '1';
               
           elseif strcmpi(varargin{i},'silent')
               silent    = 1;
           elseif strcmpi(varargin{i},'margins')
               if length(varargin{i+1}) == 4
                   margins = varargin{i+1};
               end  
           elseif strcmpi(varargin{i},'paper')
               papertype = varargin{i+1};
           elseif strcmpi(varargin{i},'latexstyle')
               latexstyle = varargin{i+1};
           elseif strcmpi(varargin{i},'-docleaning') || strcmpi(varargin{i},'-wipe')
               system(['cd ',folderpath,'; make wipe']);
               return
           end
       end
    end        
     
    if ~exist([folderpath,'pics'],'dir')
        mkdir([folderpath,'pics']);
%     else
%         try
%         rmdir([folderpath,'pics/*.*'],'s');
%         end
    end
    
    if ~exist([folderpath,'tex'],'dir')
        mkdir([folderpath,'tex']);
%     else
%         try
%         delete([folderpath,'tex/*.*']);    
%         end
    end
    
    lastepoch = sEpoch.iEpoch;
    % TRIM FAT
    try sStat.ambiguities(:,lastepoch+1:end) = []; end;
    try sStat.userxyz(lastepoch+1:end,:) = []; end;
    try sStat.userenu(lastepoch+1:end,:) = []; end;
    try sStat.residuals(:,lastepoch+1:end) = []; end;
    try sStat.satelv(:,lastepoch+1:end) = []; end;
    try sStat.sataz(:,lastepoch+1:end) = []; end;
    try sStat.usedsats(:,lastepoch+1:end) = []; end;
    try sStat.pdop(lastepoch+1:end) = []; end;
    try sStat.gdop(lastepoch+1:end) = []; end;
    try sStat.vdop(lastepoch+1:end) = []; end;
    try sStat.hdop(lastepoch+1:end) = []; end;
    try sStat.rcvclk(lastepoch+1:end) = []; end;
    try sStat.sigmaamb(:,lastepoch+1:end) = []; end;
    try sStat.sigmaclk(lastepoch+1:end) = []; end;
    try sStat.sigmaeast(lastepoch+1:end) = []; end;
    try sStat.sigmanorth(lastepoch+1:end) = []; end;
    try sStat.sigmaup(lastepoch+1:end) = []; end;
    
    
    % Prepare data
    valid  =~isnan(sStat.userxyz(:,1));
    x      = sStat.userxyz(valid,1);
    y      = sStat.userxyz(valid,2);
    z      = sStat.userxyz(valid,3);
%     reflla = eceftolla(sStat.refpoint);

    % ENU
    fulleast  = sStat.userenu(:,1);
    fullnorth = sStat.userenu(:,2);
    fullup    = sStat.userenu(:,3);
    east   = sStat.userenu(valid,1);
    north  = sStat.userenu(valid,2);
    up     = sStat.userenu(valid,3);
    emin   = min(east);
    emax   = max(east);
    nmin   = min(north);
    nmax   = max(north);
    umin   = min(up);
    umax   = max(up);
    enumax = max(max([emax nmax umax]));
    enumin = min(min([emin nmin umin]));
    
    % Standard deviations
    usedphase  = any(any(sStat.ambiguities~=0));
    sigmaeast  = std(east);
    sigmanorth = std(north);
    sigmaup    = std(up);
%     sigmaclk   = timesigmaclk(end);
    
%     refenu = eceftoenu(sStat.refpoint);
    
    
    % PDOP
    pdop = sStat.pdop;
    hdop = sStat.hdop;
    vdop = sStat.vdop;
    gdop = sStat.gdop;
    
    satsCA = [];
    satsL1 = [];
    satsL2 = [];
    
    % Number of valid epochs
    nbEpochs = length(valid);
    nEpoch   = sum(valid);
    nSat     = userparams('MAXSAT');
    
    
    %% GENERIC RUN INFORMATION
    % document runinfo.tex
    if ~skipsections(1)
    disp('Creating run information...');
    isections           = isections +1;
    sections{isections} = 'tex/runinfo.tex';   % filename
    sections{isections+1} = 'Run information'; % title
    try
        fid = fopen([folderpath,sections{1} ],'w');
        if fid == -1 
            throw(ppplabexceptions('openfile'));
        end
        sectionfolder = ['pics/',sections{isections}(5:end-4)];
        if ~exist([folderpath,sectionfolder],'dir')
            mkdir([folderpath,sectionfolder]);
        end
        
        latexparagraph(fid,['%% CREATED ON ',datestr(now)]);


        % ALGORITHM INFORMATION
        latexline(fid,...
            ['This run was processed with \textbf{%s} (iterations until error is less than %e) during ',...
            '%d epochs, with data being processed in \textbf{%d} epochs. ']...
            , sAlgo.algtype, userparams('TOLERANCE'), lastepoch, sStat.hit);        
        if strcmpi(sAlgo.flags.freqmode,'L1')
            latexparagraph(fid,'Only single frequency data was used (L1).');
        elseif strcmpi(sAlgo.flags.freqmode,'L2')
            latexparagraph(fid,'Only single frequency data was used (L2).'); 
        elseif strcmpi(sAlgo.flags.freqmode,'L1L2')
            latexparagraph(fid,'Dual frequency data was used (L1 and L2)');
        end
        
        meanlla=eceftolla([mean(x),mean(y),mean(z)]);
        latexparagraph(fid,'The resulting average position is %f %f %f in ECEF and %f %f %f in LLA.',...
                       mean(x),mean(y),mean(z),meanlla);
        
        
        % MASKS USED
        latexparagraph(fid,['A \textbf{%d$^\circ$ elevation mask} is being used alongside with a \textbf{%d dbHz SNR mask}. ',...
                        'Satellites that do not meet this requirements will be left out of the processing loop.'],...
                        deg(userparams('MASKELV')),userparams('MASKSNR'));
        
        
        % CORRECTIONS USED       
        % Precise ephemerides
        str  = [];
        args = {};
        if sAlgo.flags.usepreciseorbits && sAlgo.flags.usepreciseclk
            str = 'Precise ephemerides and clocks were pulled from ';
            if ~strcmpi(sAlgo.flags.orbitproduct,'GMV')
                str = [str,...
                         'the International GNSS Service (IGS), using %s product. '];
                args = [args, sAlgo.flags.orbitproduct];
            else
                str = [str,...
                         'GMV''s Magic GNSS, using the best available ',...
                         'IGS precise ephemerides and OSDT clock, with a 30s period. '];
            end
            str = [str,...
                     'The orbit and clock information was interpolated with ', ...
                     '%s method to the desired epoch. '];

            args = [args,sAlgo.flags.interpolation];
        elseif sAlgo.flags.usepreciseorbits && ~sAlgo.flags.usepreciseclk
            str = [str,...
                     'Precise orbits ( ', sSettings.algorithm.orbitproduct, ' ) were used with broadcast correction for the satellite''s clock'];
                 
        elseif ~sAlgo.flags.usepreciseorbits && sAlgo.flags.usepreciseclk
            str = [str,...
                     'Broadcast information was used for satellite''s orbits, but the ',...
                     sSettings.algorithm.clockproduct,' product was used for satellite clock information. '];
                 
        else 
            str = [str,...
                     'Broadcast information was used for satellite''s orbits and clocks. '];
        end
        latexparagraph(fid,str,args{:});
        if sSettings.algorithm.antex
            latexparagraph(fid,'ANTEX was used');
        end
        if sSettings.algorithm.smooth
            latexparagraph(fid,'Code ranges were smoothed with carrier phases');
        else
            latexparagraph(fid,'Undifferenced ranges were used.');
        end

        % CYCLE SLIPS
        if sAlgo.flags.usecycleslip
            latexparagraph(fid,'Cycle slips were detected and corrected using %s',sAlgo.flags.csalgorithm);
        else
            latexparagraph(fid,'No cycle slips were detected and corrected. ');
        end


        % DATA REGENERATION
        if sAlgo.flags.datagaps
            latexparagraph(fid,'Carrier phase measurementes were regenerated');
        else
            latexparagraph(fid,'No prediction was made for gaps in the carrier phase measuremetns');
        end
        
        
        % MODELS USED
        if sAlgo.flags.usetropo
            latexparagraph(fid,'Saastamoinen Troposhere model was used to correct the pseudo ranges. ');
        else
            latexparagraph(fid,'Pseudoranges were not corrected for the tropospheric delay. ');
        end

        if sAlgo.flags.useiono
            latexparagraph(fid,'Klobouchar model was used to correct the ionosphere delay in the pseudoranges. ');
        elseif strcmpi(sAlgo.flags.freqmode,'L1L2')
            latexparagraph(fid,'Ionosphere free pseudoranges were computed using L1 and L2 information. ');
        else
            latexparagraph(fid,'Pseudoranges were not corrected for the ionospheric delay. ');
        end

        % RECEIVER INFORMATION - ONLINE ONLY
        if sEpoch.operation
            str  = [];
            if strcmpi('Proflex',sSettings.receiver) 
                str = [str,'The data was acquired from Ashtec''s Pro Flex 500 (dual frequency receiver) '];

            elseif strcmpi('uBlox',sSettings.receiver)
                str = [str,'The data was acquired from uBlox''s 6T receiver (single frequency receiver) '];

            elseif strcmpi('ZXW',sSettings.receiver) 
                str = [str,'The data was acquired from Magellan''s ZXW (dual frequency receiver) '];

            elseif strcmpi('AC12',sSettings.receiver)
                str = [str,'The data was acquired from Magellan''s AC12 (single frequency receiver) '];

            end
            str = [str,'on %s %d of %d (GPS week %d and day %d).\n '];
            latexparagraph(fid,str,...
                        sSettings.receiver,sSettings.day,sSettings.month,...
                        sSettings.year,sSettings.gpsweek,sSettings.gpsday);
        end

        
        % CREATE AVAILABILITY PLOT CA
        if any(any(sEpoch.visibleSatsPCA(1:32,:)~=0))
        flag           = 0;
        [fignamePCA, satsCA, flag] = plotavailablesats(folderpath,[sectionfolder,'/figCAPcode'],sEpoch.visibleSatsPCA(1:32,:),lastepoch,'CA','code',flag);
        [fignameCCA, satsCA, flag] = plotavailablesats(folderpath,[sectionfolder,'/figCACPhase'],sEpoch.visibleSatsCCA(1:32,:),lastepoch,'CA','carrier phase',flag);
        
        if flag > 0
            if flag > 1
            latexfigure(fid,[fignamePCA,',',fignameCCA],...
                    'visiblesatCA',...
                    'Visible GPS satellites in C/A code and carrier phase');
            elseif flag >= 2
            
            latexfigure(fid,fignamePCA,...
                    'visiblesatCA',...
                    'Visible GPS satellites (C/A code)');
            end
        end
        end
                
        % CREATE AVAILABILITY PLOT L1
        if any(any(sEpoch.visibleSatsPL1(1:32,:)~=0))
        flag           = 0;
        [fignamePL1, satsL1, flag] = plotavailablesats(folderpath,[sectionfolder,'/figL1Pcode'],sEpoch.visibleSatsPL1(1:32,:),lastepoch,'L1','code',flag);
        [fignameCL1, satsL1, flag] = plotavailablesats(folderpath,[sectionfolder,'/figL1CPhase'],sEpoch.visibleSatsCL1(1:32,:),lastepoch,'L1','carrier phase',flag);
   
        if flag > 0
            if flag > 1
            latexfigure(fid,[fignamePL1,',',fignameCL1],...
                    'visiblesatCA',...
                    'Visible GPS satellites in L1 code and carrier phase');
            elseif flag >= 2
            
            latexfigure(fid,fignamePL1,...
                    'visiblesatCA',...
                    'Visible GPS satellites (L1 P code)');
            end
        end
        end
        
        % CREATE AVAILABILITY PLOT L2
        if any(any(sEpoch.visibleSatsPL2(1:32,:)~=0))
        flag           = 0;
        [fignamePL2, satsL2, flag] = plotavailablesats(folderpath,[sectionfolder,'/figL2Pcode'],sEpoch.visibleSatsPL2(1:32,:),lastepoch,'L2','code',flag);
        [fignameCL2, satsL2, flag] = plotavailablesats(folderpath,[sectionfolder,'/figL2CPhase'],sEpoch.visibleSatsCL2(1:32,:),lastepoch,'L2','carrier phase',flag);
        
        if flag > 0
            if flag > 1
            latexfigure(fid,[fignamePL2,',',fignameCL2],...
                    'visiblesatL2',...
                    'Visible GPS satellites in L2 code and carrier phase');
            elseif flag >= 2
            
            latexfigure(fid,fignamePL2,...
                    'visiblesatL2',...
                    'Visible GPS satellites (L2 P code)');
            end
        end
        end
        
        fclose(fid);
        close all
        isections = isections + 1;
    catch openfailure
        fclose(fid);
        close all
        if strcmpi(openfailure.identifier,'PPPLAB:REPORTGENERATOR')
            disp(['*Failed to create ',sections{isections}]);
        else
            disp(['*Failed to create ',sections{isections},' due to ',openfailure.message]);
        end
        sections{isections}   = [];
        sections{isections+1} = [];
        isections = isections - 1;
    end 
    else
        disp('Skipping run information');
    end
        
    
    %% POSITION INFORMATION
    % document positioninfo.tex
    if ~skipsections(2)
    disp('Creating positioning information...');
    isections           = isections +1;
    sections{isections} = 'tex/positioninfo.tex'; %filename
    sections{isections+1} = 'Position information'; % title
    try
        fid = fopen([folderpath,sections{isections}],'w');
        if fid == -1 
            openfailure = MException('PPPLAB:ReportGenerator', ...
            'Failed to open %s\.', sections{isections});
            throw(openfailure)
        end
        sectionfolder = ['pics/',sections{isections}(5:end-4)];
        if ~exist([folderpath,sectionfolder],'dir')
            mkdir([folderpath,sectionfolder]);
        end
        
        latexparagraph(fid,['%% CREATED ON ',datestr(now)]);

        latexparagraph(fid,...
        ['This section provides information regarding the receiver''s ',...
        'position comparing it with a reference position ($%3.3f,%3.3f,%3.3f$). ',...
        'Figure \ref{fig:gmaps} shows where the reference point is located, ',...
        'while Figure \ref{fig:enu} shows, on the right, the receiver''s distance to the '...
        'reference point in meters on a east and north reference frame. '...
        'On the left each coordinate is plotted throughout the observation time.'...    
        ],meanlla(1),meanlla(2),meanlla(3));


        % PLOT 2D Positioning
        fignamel = [sectionfolder,'/2dpos'];
        ploteastnorth([folderpath,fignamel],east,north,ellipseconf,lastepoch);
        
        % Plot East, North and Up
        fignamer = [sectionfolder,'/enu'];
%         plotenu([folderpath,fignamer],east,north,up,enumin,enumax,lastepoch);
        plotenu([folderpath,fignamer],fulleast,fullnorth,fullup,enumin,enumax,lastepoch);
        
        figbox = [sectionfolder,'/enubox'];
        plotbox([folderpath,figbox],[east,north,up],[{'East'},{'North'},{'Up'}],'Distance to reference point (m)',[rgb('blue');rgb('dark green');rgb('orange')])
        
        % Print latex command
        latexfigure(fid,[fignamel,',',fignamer],...
                    'enu',...
                    'Receiver''s ENU coordinates.'); 
        %'scale','0.95\\linewidth,\\linewidth','figcmd','width,width'


        % POLAR PLOT
        figname = [sectionfolder,'/sat'];
        plotconstellation([folderpath,figname],sStat);
        latexfigure(fid,figname,'usedsat',...
                    'Satellites used throughout the run',...
                    'figcmd','scale','scale','0.75'); 
        

        % USED  SAT
        fignamel  = [sectionfolder,'/figusedsats'];
        plotusedsats([folderpath,fignamel],sStat.usedsats,lastepoch,32);

        fignamer = [sectionfolder,'/figusedsatscount'];
        plotusedsatscount([folderpath,fignamer],sStat.usedsats,lastepoch,32);
        
        % Print latex command
        latexfigure(fid,[fignamel,',',fignamer],...
                    'usedsats',...
                    'Satellites used throughout the run'); 
                
        if ~skipgmaps
                
            % Downloads reference position from Google
            GURL   = sprintf(['https://maps.google.com/maps/api/staticmap?',...
                      'center=%f,%f&zoom=20&size=300x300',...
                      '&markers=icon:http://bit.ly/Jp8qcc%%7C%f,%f',...
                      '&maptype=satellite&sensor=false'],...
                      meanlla(1),meanlla(2),meanlla(1),meanlla(2));

            GFIG   = [sectionfolder,'/gmaps.png'];
            if ~exist([folderpath,GFIG],'file')
                [~,status] = urlwrite(GURL,[folderpath,GFIG]);
            else
                status = 1;
            end                
            if status
                latexfigure(fid,[GFIG,',',figbox],...
                            'gmaps',...
                            'Mean position location and ENU boxplot');  
            else
                latexfigure(fid,figbox,'boxplot',...
                    'ENU box plot',...
                    'figcmd','scale','scale','0.50');
            end
        
        else
            latexfigure(fid,figbox,'boxplot',...
                'ENU box plot',...
                'figcmd','scale','scale','0.50');     
        end
        
        
        % RECEIVER CLOCK
        fignamel = [sectionfolder,'/figrcvclk'];
        plotrcvclk([folderpath,fignamel],sStat.rcvclk,lastepoch)
        latexfigure(fid,fignamel,'rcvclk',...
                    'Receiver clock error',...
                    'figcmd','scale','scale','0.50');
        
        % SIGMAS EAST NORTH
        fignamel = [sectionfolder,'/figsigmaeast'];
        plotcomponent([folderpath,fignamel],sStat.sigmaeast,lastepoch,'East (m)',rgb('blue'));
        
        fignamer = [sectionfolder,'/figsigmanorth'];
        plotcomponent([folderpath,fignamer],sStat.sigmanorth,lastepoch,'North (m)',rgb('dark green'));

        latexfigure(fid,[fignamel,',',fignamer],...
                    'sigmaseastnorth',...
                    'East and North coordinate standard deviation');
        
        % SIGMAS UP CLK
        fignamel = [sectionfolder,'/figsigmaup'];
        plotcomponent([folderpath,fignamel],sStat.sigmaup,lastepoch,'Up (m)',rgb('orange'));
        
        fignamer = [sectionfolder,'/figsigmaclk'];
        plotcomponent([folderpath,fignamer],sStat.sigmaclk,lastepoch,'Clock Error (m)',rgb('gray'));
        
        latexfigure(fid,[fignamel,',',fignamer],...
                    'sigmasupandclock',...
                    'Up and clock error standard deviation');
        
        
                
                
                
                
        % AMBIGUITIES
        if  usedphase
            if ~strcmpi(sAlgo.algtype,'pppgao')
            [figname,figid,k] = plotambiguities(folderpath,[sectionfolder,'/figamb'],sStat.ambiguities,lastepoch);
            latexmultiplefigures(fid,figname,figid,k,'amb','Ambiguity N1N2 for prn'); 
            else
            [figname,figid,k] = plotambiguities(folderpath,[sectionfolder,'/figambl1'],sStat.ambiguitiesL1,lastepoch);
            latexmultiplefigures(fid,figname,figid,k,'ambl1','Ambiguity N1 for prn'); 
            [figname,figid,k] = plotambiguities(folderpath,[sectionfolder,'/figambl2'],sStat.ambiguitiesL1,lastepoch);
            latexmultiplefigures(fid,figname,figid,k,'ambl2','Ambiguity N2 for prn'); 
            end
        end 

        fclose(fid);
        close all
        isections = isections + 1;
    catch openfailure
        fclose(fid);
        close all
        if strcmpi(openfailure.identifier,'PPPLAB:REPORTGENERATOR')
            disp(['*Failed to create ',sections{isections}]);
        else
            disp(['*Failed to create ',sections{isections},' due to ',openfailure.message]);
        end
        sections{isections}   = [];
        sections{isections+1} = [];
        isections = isections - 1;
    end
    else
        disp('Skipping positioning information');
    end
    
    %% Statistics
    if ~skipsections(3)
    disp('Creating statistical information...');
    isections             = isections +1;
    sections{isections}   = 'tex/statisticinfo.tex'; %filename
    sections{isections+1} = 'Statistical information'; % title
    try
        fid = fopen([folderpath,sections{isections}],'w');
        if fid == -1 
            openfailure = MException('PPPLAB:ReportGenerator', ...
            'Failed to open %s.', sections{isections});
            throw(openfailure)
        end
        
        sectionfolder = ['pics/',sections{isections}(5:end-4)];
        if ~exist([folderpath,sectionfolder],'dir')
            mkdir([folderpath,sectionfolder]);
        end
        
        
        latexparagraph(fid,['This section provides statistical information regarding the estimated solutions and intermidiate values, such as code and phase residuals.',...
        'The tables in this section provide insight regarding the precision of the solution.',...
        'The box plots allow a quick geometric understanding of what is happening with the data, with the whisker marking the minimmun and maximum values.']);
        
    
        % CONFIDENCE VALUES
        [col2d,labels2d,col3d,labels3d,collumnlabels] = buildconfidence('formulai',east,north,up);
        tables = [{labels2d},{collumnlabels},{col2d'};...
                  {labels3d},{collumnlabels},{col3d'}];
        latextable( fid, tables,'2dstd,3dstd',...
                    ['2D Confidence regions',...
                    ',3D Confidence regions']);
    
        interval = round(nEpoch*0.25);
        [col2d,labels2d,col3d,labels3d,collumnlabels] = buildconfidence('formulai',east(end-interval:end),north(end-interval:end),up(end-interval:end));                
        tables = [{labels2d},{collumnlabels},{col2d'};...
                  {labels3d},{collumnlabels},{col3d'}];
        latextable( fid, tables,'2dcov,3dcov',...
                    ['2D confidence regions for last ',sprintf('%d',interval),' epochs',...
                    ',3D confidence regions for last ',sprintf('%d',interval),' epochs']);

        [col2d,labels2d,col3d,labels3d,collumnlabels] = buildconfidence('crr',east,north,up);
        tables = [{labels2d},{collumnlabels},{col2d'};...
                  {labels3d},{collumnlabels},{col3d'}];
        latextable( fid, tables,'CRR:2dstd,CRR:3dstd',...
                    ['CRR:2D Confidence regions',...
                    ',CRR:3D Confidence regions']);
    
        interval = round(nEpoch*0.25);
        [col2d,labels2d,col3d,labels3d,collumnlabels] = buildconfidence('crr',east(end-interval:end),north(end-interval:end),up(end-interval:end));                
        tables = [{labels2d},{collumnlabels},{col2d'};...
                  {labels3d},{collumnlabels},{col3d'}];
        latextable( fid, tables,'CRR:2dcov,CRR:3dcov',...
                    ['CRR:2D confidence regions for last ',sprintf('%d',interval),' epochs',...
                    ',CRR:3D confidence regions for last ',sprintf('%d',interval),' epochs']);
            
                
        % BOXPLOT EVOLUTION
        figbox = [sectionfolder,'/eastbox'];
        
        plotboxtimeseries([folderpath,figbox],fulleast,'Epoch interval','East (m)',lastepoch/10,lastepoch);
        latexfigure(fid,figbox,'coderesboxplot',...
                    'Observation periods',...
                    'figcmd','scale','scale','0.75'); 
        
        figbox = [sectionfolder,'/northbox'];                
        plotboxtimeseries([folderpath,figbox],fullnorth,'Epoch interval','North (m)',lastepoch/10,lastepoch);
        latexfigure(fid,figbox,'coderesboxplot',...
                    'Observation periods',...
                    'figcmd','scale','scale','0.75'); 

        figbox = [sectionfolder,'/upbox'];
        plotboxtimeseries([folderpath,figbox],fullup,'Epoch interval','Up (m)',lastepoch/10,lastepoch);
        latexfigure(fid,figbox,'coderesboxplot',...
                    'Observation periods',...
                    'figcmd','scale','scale','0.75'); 
        
                
        % TABLE STAT ENU
        [values,linelabel,collumnlabels] = buildenustd(east,north,up);
        tables = [{linelabel},{collumnlabels},{values'}];
        latextable( fid, tables,'resinfo',...
                    'Statistical information regarding ENU coordinates');
        
                
        % RESIDUALS STAT
        figbox = [sectionfolder,'/coderesbox'];
        plotbox([folderpath,figbox],sStat.residuals{1}','Satellites','Code residuals (m)',[]);
        [linelabel,collumnlabels,satresinfo] = buildresidualstd(sStat.residuals{1});
        tables = [{linelabel},{collumnlabels},{satresinfo}];
        latextable( fid, tables,'coderesinfo',...
                    'Statistical information regarding satellite residuals');
        latexfigure(fid,figbox,'coderesboxplot',...
                    'Satellite code residuals box plot',...
                    'figcmd','scale','scale','0.75');                                 
           
        if usedphase
           figbox = [sectionfolder,'/phaseresbox'];
           plotbox([folderpath,figbox],sStat.residuals{2}','Satellites','Phase residuals (m)',[]);
           [linelabel,collumnlabels,satresinfo] = buildresidualstd(sStat.residuals{2});
           tables = [{linelabel},{collumnlabels},{satresinfo}];
           latextable( fid, tables,'phaseresinfo',...
                    'Statistical information regarding satellite residuals');
           latexfigure(fid,figbox,'phaseresboxplot',...
                    'Satellite phase residuals box plot',...
                    'figcmd','scale','scale','0.75');                                 
        end  
                
        % DOPS
        figdops=plotdops(folderpath,sectionfolder,pdop,hdop,vdop,gdop,lastepoch);
        latexfigure(fid,figdops,...
        'DOPS',...
        'DOP values associated with the satellite constellation'...
        );
            
        fclose(fid);
        close all
        isections = isections + 1;
        
    catch openfailure
        fclose(fid);
        close all
        if strcmpi(openfailure.identifier,'PPPLAB:REPORTGENERATOR')
            disp(['*Failed to create ',sections{isections},' - check folder path']);
        else
            disp(['*Failed to create ',sections{isections},' due to ',openfailure.message]);
        end
        sections{isections}   = [];
        sections{isections+1} = [];
        isections = isections - 1;
    end
    else
        disp('Skipping statistical information');        
    end
    
    
    %% SATELLITE INFORMATION
    if ~skipsections(4)
    disp('Creating satellite information...');
    isections             = isections +1;
    sections{isections}   = 'tex/satellite.tex'; %filename
    sections{isections+1} = 'Satellite information'; % title
    try
        fid = fopen([folderpath,sections{isections}],'w');
        if fid == -1 
            openfailure = MException('PPPLAB:ReportGenerator', ...
            'Failed to open %s.', sections{isections});
            throw(openfailure)
        end
        
        sectionfolder = ['pics/',sections{isections}(5:end-4)];
        if ~exist([folderpath,sectionfolder],'dir')
            mkdir([folderpath,sectionfolder]);
        end
    
        
        satsCA = unique(satsCA)';
        satsL1 = unique(satsL1)';
        satsL2 = unique(satsL2)';
        
        % SATCLK USED OR DIFFERENCE IF IGS USED
        satsclk = unique([satsCA satsL1 satsL2]);
        [figname,figid,k] = plotsatclk(folderpath,[sectionfolder,'/figclk'],satsclk,sStat.satclk,sStat.residuals,lastepoch,usedphase);
        
        if sAlgo.flags.usepreciseorbits
            caption = 'Difference between broadcast and precise satellite clock';
        else
            caption = 'Satellite clock';
        end
        latexmultiplefigures(fid,figname,figid,k,'satclk',[caption,' for prn']);
                
        % SAT EPHEMERIDES OR DIFFERENCE BETWEEN SP3
        satsxyz = unique([satsCA satsL1 satsL2]);
        if sAlgo.flags.usepreciseorbits
            captionx = 'Difference between broadcast and precise satellite x coordinate';
            captiony = 'Difference between broadcast and precise satellite y coordinate';
            captionz = 'Difference between broadcast and precise satellite z coordinate';
        else
            captionx = 'Satellite x coordinate';
            captiony = 'Satellite x coordinate';
            captionz = 'Satellite x coordinate';
        end
        [figname,figid,k] = plotsatxyzdiff(folderpath,[sectionfolder,'/figxyxdiff'],satsxyz,sStat.satx,sStat.residuals,lastepoch,usedphase,captionx);
        latexmultiplefigures(fid,figname,figid,k,'satxyzdiff',[captionx,' for prn']);
        [figname,figid,k] = plotsatxyzdiff(folderpath,[sectionfolder,'/figxyydiff'],satsxyz,sStat.saty,sStat.residuals,lastepoch,usedphase,captiony);
        latexmultiplefigures(fid,figname,figid,k,'satxyzdiff',[captiony,' for prn']);
        [figname,figid,k] = plotsatxyzdiff(folderpath,[sectionfolder,'/figxyzdiff'],satsxyz,sStat.satz,sStat.residuals,lastepoch,usedphase,captionz);
        latexmultiplefigures(fid,figname,figid,k,'satxyzdiff',[captionz,' for prn']);
        
        % ELEVATION INFORMATION
        if ~isempty(satsCA)
            [figname,figid,k] = plotreselev(folderpath,[sectionfolder,'/figselvCA'],sStat.residuals,deg(sStat.satelv(1:nSat,:)),satsCA,lastepoch,usedphase);
            latexmultiplefigures(fid,figname,figid,k,'satelvca','Elevation profile for C/A prn');
        end
        
        if ~isempty(satsL1)
            [figname,figid,k] = plotreselev(folderpath,[sectionfolder,'/figselvL1'],sStat.residuals,deg(sStat.satelv(1:nSat,:)),satsL1,lastepoch,usedphase);
            latexmultiplefigures(fid,figname,figid,k,'satelvl1','Elevation profile for L1 prn');
        end
        
        
        if ~isempty(satsL2)
            [figname,figid,k] = plotreselev(folderpath,[sectionfolder,'/figselvL2'],sStat.residuals,deg(sStat.satelv(1:nSat,:)),satsL2,lastepoch,usedphase);
            latexmultiplefigures(fid,figname,figid,k,'satelvl2','Elevation profile for L2 prn'); 
        end
        
        
        % SNR INFORMATION
        clear figname;
        if ~isempty(satsCA)
            [figname,figid,k] = plotsnr(folderpath,[sectionfolder,'/figsnrca'],sAlgo.SNRCA(:,1:end),satsCA,lastepoch);
            latexmultiplefigures(fid,figname,figid,k,'snrca','SNR for CA code for prn'); 
        end
        
        clear figname;
        if ~isempty(satsL1)
            [figname,figid,k] = plotsnr(folderpath,[sectionfolder,'/figsnrl1'],sAlgo.SNRL1(:,1:end),satsL1,lastepoch);
            latexmultiplefigures(fid,figname,figid,k,'snrl1','SNR for L1 code for prn'); 
        end
        
        clear figname;
        if ~isempty(satsL2)
            [figname,figid,k] = plotsnr(folderpath,[sectionfolder,'/figsnrl2'],sAlgo.SNRL2(:,1:end),satsL2,lastepoch);
            latexmultiplefigures(fid,figname,figid,k,'snrl2','SNR for L2 code for prn'); 
        end

        % Run information written
        fclose(fid);
        close all
        isections  = isections + 1; %tile and filename
    catch openfailure
        fclose(fid);
        close all
        if strcmpi(openfailure.identifier,'PPPLAB:REPORTGENERATOR')
            disp(['*Failed to create ',sections{isections}]);
        else
            disp(['*',openfailure.message]);
        end
        sections{isections}   = [];
        sections{isections+1} = [];
        isections = isections - 1;
    end
    else
        disp('Skipping satellite information');        
    end
    
    
    %% CYCLE SLIPS
    if sSettings.algorithm.cscorrection || sSettings.algorithm.csdetection
    disp('Creating cycle slips information...');
    isections             = isections +1;
    sections{isections}   = 'tex/cycleslipsinfo.tex'; %filename
    sections{isections+1} = 'Cycle Slips information'; % title
    try
        fid = fopen([folderpath,sections{isections}],'w');
        if fid == -1 
            openfailure = MException('PPPLAB:ReportGenerator', ...
            'Failed to open %s.', sections{isections});
            throw(openfailure)
        end
        
        sectionfolder = ['pics/',sections{isections}(5:end-4)];
        if ~exist([folderpath,sectionfolder],'dir')
            mkdir([folderpath,sectionfolder]);
        end
        
        if ~all(all(isnan(sStat.mwomc),2))
        [figname,figid,k] = plotslipdetector(folderpath,[sectionfolder,'/figmw'],sStat.mwomc,sStat.mwth,lastepoch);
        latexmultiplefigures(fid,figname,figid,k,'mwcs','Melbourne-W\"{u}bbena detector'); 
        end
        
        if ~all(all(isnan(sStat.tecomc),2))
        [figname,figid,k] = plotslipdetector(folderpath,[sectionfolder,'/figtec'],sStat.tecomc,sStat.tecth,lastepoch);
        latexmultiplefigures(fid,figname,figid,k,'teccs','TEC detector'); 
        end
        
        if ~all(all(isnan(sStat.lgomc),2))
        [figname,figid,k] = plotslipdetector(folderpath,[sectionfolder,'/figlg'],sStat.lgomc,sStat.lgth,lastepoch);
        latexmultiplefigures(fid,figname,figid,k,'lgcs','Geometry-free detector'); 
        end
        
        if ~all(all(isnan(sStat.dopomcl1),2))
        [figname,figid,k] = plotslipdetector(folderpath,[sectionfolder,'/figdop'],sStat.dopomcl1,sStat.dopthl1,lastepoch);
        latexmultiplefigures(fid,figname,figid,k,'dopcs','Predicted Doppler detector (L1) for prn');
        end
        
        if ~all(all(isnan(sStat.dopomcl2),2))
        [figname,figid,k] = plotslipdetector(folderpath,[sectionfolder,'/figdop'],sStat.dopomcl2,sStat.dopthl2,lastepoch);
        latexmultiplefigures(fid,figname,figid,k,'dopcs','Predicted Doppler detector (L2) for prn');
        end
               
        fclose(fid);
        close all
        isections = isections + 1;        
    catch openfailure
        fclose(fid);
        close all
        if strcmpi(openfailure.identifier,'PPPLAB:REPORTGENERATOR')
            disp(['*Failed to create ',sections{isections},' - check folder path']);
        else
            disp(['*Failed to create ',sections{isections},' due to ',openfailure.message]);
        end
        sections{isections}   = [];
        sections{isections+1} = [];
        isections             = isections - 1;
    end
    end
    
    
    %% FILE COMPILATION
    if ~isempty(sections{1})
        disp('Compiling tex files (suppresing errors)...');
        if ~exist([folderpath,reportname,'.tex'],'file') || ~exist([folderpath,'Makefile'],'file') || forceflag
            buildtemplate(reportname,folderpath,reporttitle,sections,latexstyle,margins,papertype,fontsize);
        end
        if isunix
            if silent
                suppress = [{' &>/dev/null'} {' >/dev/null'}];
            else
                suppress = [{''} {''}];
            end
            system(['cd ',folderpath,'; make',suppress{1}]);
            system(['cd ',folderpath,'; make clean',suppress{2}]);
        else
            if silent
                suppress = [{' >nul'} {' >nul'}];
            else
                suppress = [{''} {''}];
            end
            system(['cd ',folderpath,'&& make',suppress{1}]);
%             dos(['make clean',suppress{1}]);
%             disp('Please make it yourself');
%             delete('Report/tex/*.*');
%             delete('Report/pics/*.*');
        end
        disp('Report created.');
    else
        disp('It seems that my work was already done, that or you made a mistake');
    end
   
    fids = fopen('all');
    for f=fids
        fclose(f);
    end
end

        %PLOT DATA AGAINST GAUSSIAN 
%         k       = 0;
%         strdata = {'east','north','up'};
%         for data = [east,north,up]
%             k        = k+1;
%             fignamel = [sectionfolder,'/',strdata{k},'1'];
%             figl     = figure('Visible','off');
%             axsl     = axes('Parent',figl);
%             probplot(axsl,'normal',data);
%             xlabel([strdata{k},' (m)']);
%             ylabel('Probability');
%             set(get(axsl,'title'),'string','Comparison to normal distribution');
%             
%             print2eps([folderpath,fignamel],figl);
%             close(figl);
% 
%             fignamer = [sectionfolder,'/',strdata{k},'2'];
%             figr     = figure('Visible','off');
%             axsr     = axes('Parent',figr);
%             hold(axsr,'on');
%             histfitmod(axsr,data);
%             title(axsr,'Normal distribution over data histogram');
%             xlabel([strdata{k},' (m)']);
%             ylabel('Frequency');
%             print2eps([folderpath,fignamer],figr);
%             close(figr);
%             
%             latexfigure(fid,[fignamel,',',fignamer],...
%             ['gauss:',strdata{k}],...
%             ['On the left the ',strdata{k},' coordinates are plotted',...
%             ' against its probability, while on the right an histogram of the values']...
%             );
%         end
%    

