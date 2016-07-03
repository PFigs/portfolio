function [figname,figid,satid] = plotsatclk(folderpath,outname,sats,clk,satres,nEpoch,usedphase)

    satid   = 0;
    figname = [];
    figid   = [];
    for psat = sats
        satclk = clk(psat,:);
        satclk(satclk==0) = NaN;
        if all(isnan(satclk)), continue; end;
%         satres = res(psat,:);
        satid  = satid + 1;
        
        %multiple plot
        figname(satid,:) = [outname,sprintf('%02d',psat)];
        figid(satid)     = psat;
        fig              = figure('Visible','off');

        axs1              = axes('xlim',[1 nEpoch],'Parent',fig);
        
        
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
        line(1:nEpoch,satclk(1:nEpoch),'parent',axs1);
        line(1:nEpoch,satres{1}(psat,1:nEpoch),'color',rgb('dark green'),'parent',axs2);
        if usedphase
            line(1:nEpoch,satres{2}(psat,1:nEpoch),'color',rgb('spring green'),'parent',axs3);
            legend_mod([axs1,axs2,axs3],'Satellite Clock','Code Residuals','Phase Residuals','Location','SouthEast');
        else
            legend_mod([axs1,axs2],'Satellite Clock','Code Residuals','Location','SouthEast');
        end
        linkaxes([axs1 axs2 axs3],'x');
        linkaxes([axs2 axs3],'xy');
        
        set(get(axs1,'title'),'string',['Satellite ',sprintf('%02d',psat)]);  
        set(get(axs1,'ylabel'),'string','Satellite Clock Delay (m)');                               
        set(get(axs1,'xlabel'),'string','Epochs (s)');     
        set(get(axs2,'ylabel'),'string','Residuals (m)');     
        
        set(axs3,'ytick',[])
        
        % Export
        assert(tryexport([folderpath,figname(satid,:)],fig,2)==0);
        % Clean up
        try
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
