function [ status, filepath, type ] = pullfile( WN, WD, TOW, product, varargin )
%PULLFILE retrieves the best available orbit file from IGS servers
%   This function will figure which is the best file that should be
%   available and will look for it in the IGS servers.
%   To determine which file should be available the function uses the
%   information present at the IGS homepage and transcribed here.
%
%   INPUT
%   WN - GPS Week Number
%   WD - GPS Week Day (between 0 (Sunday) and 6 (Saturday))
%   TOW - GPS Time of Week (starts at Sunday midnight)
%   VARARGIN: BASEDIR - Allows the user to change the default download
%                       dir. It should be terminated with a slash /.
%                       DEFAULT: IGSFiles/
%
%   OUTPUT
%   STATUS - Download sucess (1 success, 0 failed)
%   FILEPATH - Filepath from execution dir
%
%   ##### From IGS homepage ###############################################
%       Three types of GPS ephemeris, clock and earth orientation solutions 
%       are computed.
%
%   Final
%       The final combinations are available at 12 days latency.
%
%   Rapid
%       The Rapid product is available with approximately 17 hours latency.
%
%   UltraRapid
%       The UltraRapid combinations are released four times each day (at  
%       0300, 0900, 1500, and 2100 UT) and contain 48 hours worth of 
%       orbits; the first half computed from observations and the second 
%       half predicted orbit.The files are named according to the midpoint 
%       time in the file: 00, 06, 12, and 18 UT.
%   #######################################################################
%
%   Pedro Silva, Instituto Superior Técnico, Outubro 2011
%   Last Revision: November 2011

    % CHECK INPUT
    error(nargchk(3, 4, nargin)) % future usage: error(narginchk(., .));
    if nargin == 5
        baseDir = varargin{4};
        if baseDir(end) ~= '/'
            fprintf('pullfile: Directory (%s) should be terminated by /',baseDir);
            baseDir = strcat(baseDir,'/');
            fprintf('Corrected baseDir to %s',baseDir);
        end
    else
        baseDir = 'IGSFiles/'; % FASTEST mode depends on previous operations to ref
    end
    
    if ~isscalar(WN)
       error('pullfile: WD is not an scalar' );
    end
    
    if ~isscalar(WD)
       error('pullfile: WD is not an scalar' );
    end
    
    if ~isscalar(TOW)
       error('pullfile: TOW is not an scalar' );
    end
    
    % OBTAINS TIME INFORMATION
    clk    = clock; % Retrive current running time
    sdate  = datenum(date); 
    currtm = getweeksec(weekday(sdate)-1, clk(4), clk(5), clk(6));
    currwn = getweeknum(clk(1),sdate); %DEBUG
    strWN  = sprintf('%04d',WN);
    strWD  = sprintf('%d',WD);
    
    force  = zeros(2,1);
    if strcmpi(product,'IGS')
        force(1) = 1;
    elseif strcmpi(product,'IGR')
        force(2) = 1;
    elseif strcmpi(product,'Best')
        force = [1 1];
    end
    
    % Final
    if (currwn-WN > 2 || ((currwn-WN)==2 && TOW >= 432000)) && force(1) 
        type    = 'igs';
        downDir = strcat(baseDir,'igs/');
        if ~exist(downDir,'dir'), mkdir(baseDir,'igs'); end;
        filename(1,:) = strcat('igs', strWN, strWD,'.sp3');
        filename(2,:) = strcat('igs', strWN, strWD,'.clk');
   
    % Rapid - 17 hours    
    elseif ((currwn-WN)>=1 || TOW-currtm > 61200 ) && force(2)
        type    = 'igr';
        downDir = strcat(baseDir,'igr/');
        if ~exist(downDir,'dir'), mkdir(baseDir,'igr'); end;
        filename(1,:) = strcat('igr', strWN, strWD,'.sp3');
        filename(2,:) = strcat('igr', strWN, strWD,'.clk');
    
    % Ultra Rapid
    else 
        type    = 'igu';
        downDir = strcat(baseDir,'igu/');
        if ~exist(downDir,'dir'), mkdir(baseDir,'igu'); end;
        % Determines the correct time to obtain the ultra rapid product
        if abs(weekday(date)-WD) > 1
            hour = 18; 
        else
            time = clk(4);
            if time >= 22,     hour = 18;
            elseif time >= 16, hour = 12;
            elseif time >= 10, hour = 6;
            else               hour = 0;
            end
        end
        filename = strcat('igu', strWN, strWD,'_', sprintf('%02d',hour),'.sp3');
    end
    
    
    % OBTAINS FILE IF NOT PRESENT
    for k=1:size(filename,1)
        if ~exist(strcat(downDir,filename(k,:)),'file')
            [status,path] = getfile(strcat(strWN, '/',filename(k,:),'.Z'),filename(k,:),downDir);
            filepath(k,:) = path;
        else
            path          = strcat(downDir,filename(k,:));
            filepath(k,:) = path;
            status        = 1;  % Success;
        end
    end
    
end


function [ status, filepath ] = getfile( webdir, filename, folder )
%GETFILE Retrieves an orbit file from any available IGS server
%   The function will download and move the uncompressed file to the FOLDER
%   provided. It will look for the file in the closest server (Europe) and 
%   if it fails then it searches for the file in every other server
%   starting by American servers and then Korean.
%
%   NOTE: The functions does not terminate if it can not find the file. The
%   user should be responsible for taking action.
%
%   INPUT
%   WEBDIR - The directory where to find the file with the given FILENAME
%   FILENAME - The file's name
%   FOLDER - Where to move the downloaded file   
%
%   OUTPUT
%   STATUS - 1 if the file was not downloaded, 0 otherwise
%   FILEPATH - The DIRECTORY + FILENAME where the file was moved
%
%   Pedro Silva, Instituto Superior Técnico, Outubro 2011
%   Last revision: November 2011

    % Available IGS FTP servers
    IGN   = 'ftp://igs.ensg.ign.fr/pub/igs/products/';      % France
    CDDIS = 'ftp://cddis.gsfc.nasa.gov/pub/gps/products/';  % US - MD
    IGSCB = 'ftp://igscb.jpl.nasa.gov/pub/product/';        % US - CA
    SOPAC = 'ftp://garner.ucsd.edu/pub/products/';          % US - CA
    KASI  = 'ftp://nfs.kasi.re.kr/gps/products/';           % Korea
    zfile = strcat(filename,'.Z');
    
    [filepath, status] = urlwrite(strcat(IGN,webdir),zfile);
    if ~status    
        [filepath, status] = urlwrite(strcat(IGSCB,webdir),zfile);  
        if ~status
            [filepath, status] = urlwrite(strcat(CDDIS,webdir),zfile);
            if ~status
                [filepath, status] = urlwrite(strcat(SOPAC,webdir),zfile);
                if ~status
                   [filepath, status] = urlwrite(strcat(KASI,webdir),zfile);
                end
            end
        end
    end
    if status
        % DECOMPRESS FILES - MATLAB's gunzip limitation and/or JAVA bug
        % Discussion: http://www.mathworks.com/matlabcentral/newsreader/view_thread/280855
        if isunix    
            system('gunzip *.Z');
        else
            system('sgunzip');
        end
        movefile(filename,folder);
        filepath = strcat(folder,filename);
    end
end
