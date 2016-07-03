function [figname,figid,satid]=plotsnr(folderpath,outname,snr,sats,nEpoch)
    satid = 0;
    for psat = sats
        satid = satid + 1;
        figname(satid,:)   = [outname,sprintf('%02d',psat)];
        figid(satid)       = psat;
        fig            = figure('Visible','off');
        axs            = axes('xlim',[1 nEpoch],'ylim',[0 50],'Parent',fig);
        hold(axs,'on');
        title(['Satellite ',sprintf('%d',psat)]);
        xlabel('Epochs (s)');
        ylabel('SNR (dB Hz)');

        satsnr = snr(psat,:);
        satsnr(satsnr==0) = NaN;
        plot(axs,1:nEpoch,satsnr(1:nEpoch));
        xlim(axs,[0 nEpoch]);
%         satres  = res(psat,:);        
%         %multiple plot
%         figname(satid,:) = [outname,sprintf('%02d',psat)];
%         figid(satid)     = psat;
%         fig              = figure('Visible','off');
% 
%         axs1              = axes('xlim',[1 nEpoch],'ylim',[0 50],'Parent',fig);
%         
%         
%         axs2              = axes('Position',get(axs1,'Position'),...
%                                    'XAxisLocation','bottom',...
%                                    'YAxisLocation','right',...
%                                    'Color','none',...
%                                    'XColor','k','YColor',rgb('dark green'),...
%                                    'xlim',[1 nEpoch],...
%                                    'ylim',[-10 10],...
%                                    'Parent',fig); %code
% 
%         axs3              = axes('Position',get(axs1,'Position'),...
%                                    'XAxisLocation','bottom',...
%                                    'YAxisLocation','right',...
%                                    'Color','none',...
%                                    'XColor','k','YColor',rgb('dark green'),...
%                                    'xlim',[1 nEpoch],...
%                                    'ylim',[-10 10],...
%                                    'Parent',fig); %code
%         
%                                
%         hold(axs1,'on');
%         line(1:nEpoch,satsnr(1:nEpoch),'parent',axs1);
%         line(1:nEpoch,satres(1,1:nEpoch),'color',rgb('dark green'),'parent',axs2);
%         if size(satres,1) == 2
%             line(1:nEpoch,satres(2,1:nEpoch),'color','dark blue','parent',axs3);
%         end
%         linkaxes([axs1 axs2 axs3],'x');
%         linkaxes([axs2 axs3],'xy');
%         
%         set(get(axs1,'title'),'string',['Satellite ',sprintf('%d',psat)]);
%         set(get(axs1,'ylabel'),'string','SNR (dB Hz)');                               
%         set(get(axs1,'xlabel'),'string','Epochs (s)');     
%         set(get(axs2,'ylabel'),'string','Residuals (m)');     
%         
%         set(axs3,'ytick',[])

        % Export
        assert(tryexport([folderpath,figname(satid,:)],fig,2)==0);

        % Clean up
        delete(fig);
        clear fig
        clear axs
    end
    
    figname = char(figname);    
end