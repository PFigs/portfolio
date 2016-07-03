% function [figgdop,fighdop,figpdop,figvdop]=plotdops(folderpath,outname,pdop,hdop,vdop,gdop,nEpoch)
function [figname]=plotdops(folderpath,outname,pdop,hdop,vdop,gdop,nEpoch)

    figname = [outname,'/gdop'];
    fig     = figure('Visible','off');
    axs     = axes('Parent',fig);
    hold(axs,'on');
    
%     toplot = [{gdop},{hdop},{vdop},{pdop}];
    hdop(isnan(hdop))=-1;
    gdop(isnan(gdop))=-1;
    pdop(isnan(pdop))=-1;
    vdop(isnan(vdop))=-1;
    
    
    absmax = max(max([hdop,gdop,vdop,pdop]));
    
    % Get max
    maxvec = abs([mean(hdop),mean(pdop),mean(vdop),mean(gdop)]);
    maxval = 0;
    order  = [];
    for k=1:4
       %get max to head
       if maxvec(k) > maxval
           maxval = maxvec(k);
           order = [k,order];
       else
           order = [order,k];
       end
       
       if length(order) > 1 && length(order) >= 3
           % the first one is the max
           for m = 2:length(order) 
              if m == length(order), break, end;
              if maxvec(order(m)) < maxvec(order(m+1))
                  tmp = order(m);
                  order(m)   = order(m+1);
                  order(m+1) = tmp;
              end
           end
       end
    end
    strleg = [];
    for k=1:4
       if order(k) == 1
           area(axs,hdop,'FaceColor',rgb('silver'),'EdgeColor',rgb('silver'),...
               'LineWidth',2);
           strleg = [strleg, {'HDOP'}];
       elseif order(k) == 2
           area(axs,pdop,'Facecolor',rgb('olive'),'EdgeColor',rgb('olive'),...
               'LineWidth',2);
           strleg = [strleg, {'PDOP'}];
       elseif order(k) == 3
           area(axs,vdop,'FaceColor',rgb('orange'),'EdgeColor',rgb('orange'),...
               'LineWidth',2);
           strleg = [strleg, {'VDOP'}];
       elseif order(k) == 4
           area(axs,gdop,'Facecolor',rgb('blue'),'EdgeColor',rgb('blue'),...
               'LineWidth',2);
           strleg = [strleg, {'GDOP'}];
       end
        
    end

    legend(axs,strleg,'Location','SouthEast');
    xlim(axs,[0 nEpoch]);
    xlabel('Epochs (s)');
    ylim([0,ceil(absmax)+2])
    set(axs,'ytick',1:(ceil(absmax)+2))
    set(gca,'Layer','top')
    ylabel('DOP Value');
    
    assert(tryexport([folderpath,figname],fig,2)==0);
    delete(fig);
    clear fig
    clear axs

end