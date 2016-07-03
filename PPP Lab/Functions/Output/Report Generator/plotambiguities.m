function [figname,figid,satid] = plotambiguities(folderpath,outname,ambiguities,nEpoch)
    
    satid = 0;
    for n=1:userparams('MAXSAT')
        if ~all(ambiguities(n,:)==0)
            satid = satid + 1;
            figname(satid,:) = [outname,sprintf('%03d',satid)];
            figid(satid)     = n;
            fig          = figure('Visible','off');
            axs          = axes('Parent',fig);
            ambiguities(n,ambiguities(n,:)==0) = NaN;
                
            amb = ambiguities(n,:) - min(ambiguities(n,:));
            plot(axs,amb)

            xlim(axs,[0 nEpoch]);
            xlabel('Epochs (s)');
            ylabel('Estimated ambiguity (m)');
            title(axs,['Satellite ',sprintf('%d',n)]);  

            pos = ylim;
            x = pos(1) + 0.13;
            y = pos(2) + 0.4;
            [~,d] = fpart(pos(2));
            if pos(2) < 10 && d ~=0
                y = pos(2) + 0.04;
            end
            text(x, y, sprintf('+ (%f)',min(ambiguities(n,:))));

            % Export
            assert(tryexport([folderpath,figname(satid,:)],fig,2)==0);

            % Clean up
            delete(fig);
            clear fig
            clear axs
        end
    end

end