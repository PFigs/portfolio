function plotcontrol(sHandles,sEpoch,sAlgo,sStat)
%PLOTCONTROL is responsible for plotting the data in the PPP LAB GUI
%   This functions takes the user inputs already parsed and displays them
%   in realtime, meaning that a user can switch between position plotting
%   and any other plot that is available.
%
%   INPUT
%   sHandles - Contains the handles needed to control the plots
%   sEpoch   - Contains the information regarding the obersev epoch
%   sAlgo    - Contains the information regarding the last (full) iteration
%              of the running algorithm
%
%   Plot Type correspondence
%   1 -    Position 2D (EN)
%   2 -    Position 3D (ENU)
%   3 -    Cycle Slips
%   4 -    Residuals
%   5 -    Ambiguities
%   6 -    Pseudo Ranges
%   7 -    Carrier Phase
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012
    

    % If the algorithm is not running the plot can occur
    running = sHandles.execution;

    % Decides what to plot on the left axis if realtime is on
    if get(sHandles.lrealtime,'Value') || ~running
        %Position 2D (EN)
        if sHandles.sSettings.graph.leftplottype == 1
            if running
                plot(sHandles.leftaxes,...
                    sStat.userenu(sEpoch.iEpoch,1),...
                sStat.userenu(sEpoch.iEpoch,2),'b.'); 
                drawnow
            else
                % clear the axis
                plot(sHandles.leftaxes,...
                     sStat.userenu(1:sEpoch.iEpoch,1),...
                     sStat.userenu(1:sEpoch.iEpoch,2),'b.'); 
            end
            
            
        %Position 3D (ENU)    
        elseif sHandles.sSettings.graph.leftplottype == 2
        elseif sHandles.sSettings.graph.leftplottype == 3
%             plotguidops(sHandles.leftaxes,sStat)
        elseif sHandles.sSettings.graph.leftplottype == 4
        elseif sHandles.sSettings.graph.leftplottype == 5
        elseif sHandles.sSettings.graph.leftplottype == 6
        elseif sHandles.sSettings.graph.leftplottype == 7
        end
    end
    if get(sHandles.rrealtime,'Value') || ~running
        if sHandles.sSettings.graph.rightplottype == 1
        elseif sHandles.sSettings.graph.rightplottype == 2
        elseif sHandles.sSettings.graph.rightplottype == 3
        elseif sHandles.sSettings.graph.rightplottype == 4
        elseif sHandles.sSettings.graph.rightplottype == 5
        elseif sHandles.sSettings.graph.rightplottype == 6
        elseif sHandles.sSettings.graph.rightplottype == 7
        end
    end
    
end


function plotguidops(handle,sStat)
    pdop = sStat.pdop;
    hdop = sStat.hdop;
    vdop = sStat.vdop;
    gdop = sStat.gdop;
    
    hold on;
    plot(handle,pdop);
    plot(handle,hdop);
    plot(handle,vdop);
    plot(handle,gdop);
 
end
