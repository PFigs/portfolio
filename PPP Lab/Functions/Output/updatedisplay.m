function updatedisplay( iEpoch, TOW, sAlgo, sStat, level)
%UPDATEDISPLAY writes informtion to the display regarding the current epoch
%   This function controls how much information is written to the display
%   each epoch. One can easily suppress the information by passing 0 as
%   optional argument. 
%
%   OUTPUT INFORMATION LEVEL
%   0 - SUPPRESSED
%   1 - Position, error distance
%   2 - 1 + user position graphic
%   3 - 1 + 2 + Satellite constellation
%
%   INPUT
%   SEPOCH   - Strucutre with epoch data
%   SALGO    - Structure with algorythm data
%   SSTAT    - Strucutre with statistic data
%   HANDLES  - Structure with figure handles
%   VARARGIN - Level of information to display
%
% Pedro Silva, Instituto Superior Tecnico, February 2012
    
    if nargin < 5
        level = 2;
    end
    
    if level
        
        % Just to say its alive
        if level == -1
           if ~mod(iEpoch,500)
              fprintf('. ');
           end
           return;
        end
        
        % This modes will ask more processing power
        lla    = eceftolla(sStat.userxyz(iEpoch,:));
        dst    = sAlgo.distance;
        
        % Terminal statistics
        if level >= 1
            fprintf('\n@%d: Epoch %d with estimate\n',TOW,iEpoch);
            fprintf('X:  %.5f\tY: %.5f\tZ:  %.5f\n',sStat.userxyz(iEpoch,1),...
                                                    sStat.userxyz(iEpoch,2),...
                                                    sStat.userxyz(iEpoch,3));
            fprintf('LAT:  %.5f\tLONG: %.5f\tALT:  %.5f\n',lla(1),lla(2),lla(3));
            fprintf('Distance to ref: %f\n',dst);
            fprintf('PDOP: %.5f\n',sStat.pdop(iEpoch));
            fprintf('HDOP: %.5f\n',sStat.hdop(iEpoch));
            fprintf('VDOP: %.5f\n',sStat.vdop(iEpoch));
            fprintf('GDOP: %.5f\n',sStat.gdop(iEpoch));
            fprintf('USED SATS (%d): ',sAlgo.nSat);
            fprintf('%d ',sAlgo.availableSat);
            fprintf('\n');
        end
        
        % Instataneous position plotting
        if level >= 2
             handles = gethandles();
            if isnan(handles.pos)
                handles = gethandles('pos');
            end
            if level == 3
                plot(handles.pos,sStat.userenu(iEpoch,1),sStat.userenu(iEpoch,2)); 
            else
                if  ~mod(iEpoch,60)
                    plot(handles.pos,sStat.userenu(iEpoch,1),sStat.userenu(iEpoch,2),'.','linewidth',2); 
                end
            end
                
        end
    end
    
    drawnow;
               
end

%    if sAlgo.lastAvlbSat
%        fprintf('\n@%d: Epoch %d with estimate\n',sEpoch.TOW,sEpoch.iEpoch);
%        disp(eceftolla(sAlgo.userxyz)); disp(sAlgo.distance);
%        userenu = eceftoenu(sAlgo.userxyz,sAlgo.refpoint,'ecef'); %converts sat coord
%        hold on;
%        plot(poshandle,userenu(:,1),userenu(:,2),'x'); 
%        hold off;
%        enu = eceftoenu(sAlgo.satxyz,sAlgo.refpoint,'ecef');
%        sataz  = azimuth(enu,'rad');
%        satelv = elevation(enu,'rad');
%        polar( usersathandle, sataz, satelv,'dk');
%        polar( usersathandle1, sAlgo.sataz, sAlgo.satelv,'dk');
%        drawnow;
%    end

       % Not available in offline
%        disp(sAlgo.availableSat)
%        disp(sAlgo.sataz-sEpoch.ranges.SATAZ(sAlgo.availableSat)')
%        disp(sAlgo.satelv-sEpoch.ranges.SATELV(sAlgo.availableSat)')
