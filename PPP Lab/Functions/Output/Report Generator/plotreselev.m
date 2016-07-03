function [figname,figid,satid] = plotreselev(folderpath,outname,satres,elv,sats,nEpoch,usedphase)

    satid   = 0;
    figname = [];
    figid   = [];
    for psat = sats
        satelv = elv(psat,:);
%         satres = res(psat,:);
        if all(satelv==0) || all(isnan(satelv))
            continue;
        end
        satid = satid + 1;

        %multiple plot
        figname(satid,:) = [outname,sprintf('%02d',psat)];
        figid(satid)     = psat;
        fig              = figure('Visible','off');

        axs1              = axes('xlim',[1 nEpoch],'ylim',[0 90],'Parent',fig);
        
        
        axs2              = axes('Position',get(axs1,'Position'),...
                                   'XAxisLocation','bottom',...
                                   'YAxisLocation','right',...
                                   'Color','none',...
                                   'XColor','k','YColor',rgb('dark green'),...
                                   'xlim',[1 nEpoch],...
                                   'ylim',[-10 10],...
                                   'Parent',fig); %code

        axs3              = axes('Position',get(axs1,'Position'),...
                                   'XAxisLocation','bottom',...
                                   'YAxisLocation','right',...
                                   'Color','none',...
                                   'XColor','k','YColor',rgb('dark green'),...
                                   'xlim',[1 nEpoch],...
                                   'ylim',[-10 10],...
                                   'Parent',fig); %code
        
        %%% satelv(1:nEpoch) --- will plot not valid epochs (no data) nEpoch needs to be from 1 to the last epoch                       
        hold(axs1,'on');
        line(1:nEpoch,satelv(1:nEpoch),'parent',axs1);
        line(1:nEpoch,deg(userparams('maskelv')),'parent',axs1);
        text(0.02*nEpoch,deg(userparams('maskelv'))+3, '\downarrow Cutoff angle','units','normalize','position',[0.05 0.14 1 ]);
%         text(0.02*nEpoch,deg(userparams('maskelv'))+3, '\downarrow Cutoff angle');
        line(1:nEpoch,satres{1}(psat,1:nEpoch),'color',rgb('dark green'),'parent',axs2);
        if usedphase
            line(1:nEpoch,satres{2}(psat,1:nEpoch),'color',rgb('spring green'),'parent',axs3);
            legend_mod([axs1,axs2,axs3],'Elevation','Code Residuals','Phase Residuals','Location','SouthEast');
        else
            legend_mod([axs1,axs2],'Elevation','Code Residuals','Location','SouthEast');
        end
        linkaxes([axs1 axs2 axs3],'x');
        linkaxes([axs2 axs3],'xy');
        
        set(get(axs1,'title'),'string',['Satellite ',sprintf('%02d',psat)]);  
        set(get(axs1,'ylabel'),'string','Elevation (\circ)');                               
        set(get(axs1,'xlabel'),'string','Epochs (s)');     
        set(get(axs2,'ylabel'),'string','Residuals (m)');     
        
        set(axs3,'ytick',[])
        
        % Export
        assert(tryexport([folderpath,figname(satid,:)],fig,2)==0);
        % Clean up
        try
            delete(h1);
            delete(h2);
            delete(fig);
        end
        clear h1
        clear h2
        clear a
        clear fig
        clear axs
        
    end
    figname = char(figname);
end


%             hleg = legend(axs1,'Elevation','Code Residuals','Location','SouthEast');
%             hleg = legend(axs2,'Elevation','Code Residuals','Location','SouthEast');
%             markers=findobj(get(hleg,'children'), 'Type', 'line', '-and', '-not', 'Marker', 'none');
%             set(markers(1),'color','b');
%             set(markers(2),'color',rgb('dark green'));




%PRETTY ONE
% satid   = 0;
% figname = [];
% figid   = [];
% for psat = sats
%     satid = satid + 1;
%     satelv = elv(psat,:);
%     satres = res(psat,:);
%     if all(satelv==0) || all(isnan(satelv))
%         continue;
%     end
% 
%     figname(satid,:) = [outname,sprintf('%02d',psat)];
%     figid(satid)     = psat;
%     fig              = figure('Visible','off');
%     axs              = axes('xlim',[0 nEpoch],'ylim',[0 90],'Parent',fig);
%     hold(axs,'on');
% 
%     xlim([0 nEpoch]);
%     ylim([0 90]);
%     title(['Satellite ',sprintf('%d',psat)]);
%     xlabel('Epochs (s)');
%     ylabel('Elevation (º)');
% 
%     satelv(satelv==0) = NaN;
%     [a,h1,h2]=plotyy(1:nEpoch,satelv(1:nEpoch),1:nEpoch,satres(1:nEpoch),'plot','Parent',axs);
%     set(a(1),'ylim',[0,90]);
%     set(a(2),'ylim',[-10,10]);
%     set(get(a(2),'ylabel'),'string','Residuals (m)')
% 
%     plot(axs,1:nEpoch,ones(nEpoch,1).*deg(userparams('maskelv')),'.k');
%     text(0.02*nEpoch,deg(userparams('maskelv'))+3, '\downarrow Cutoff angle');
% 
%     % Export
%     assert(tryexport([folderpath,figname(satid,:)],fig,2)==0);
%     % Clean up
%     try
%         delete(h1);
%         delete(h2);
%         delete(fig);
%     end
%     clear h1
%     clear h2
%     clear a
%     clear fig
%     clear axs
% 
% end

