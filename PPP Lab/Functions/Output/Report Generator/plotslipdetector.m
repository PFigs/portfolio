function [figname,figid,satid] = plotslipdetector(folderpath,outname,omc,th,nEpoch)

    satid = 0;
    for psat=1:userparams('MAXSAT')
        if ~all(isnan(omc(psat,:)))
            satid = satid + 1;
            figname(satid,:) = [outname,sprintf('%03d',psat)];
            figid(satid)     = psat;
            fig              = figure('Visible','off');
            axs              = axes('Parent',fig);
            hold(axs,'on');

            plot(axs,omc(psat,:),'.b');
            plot(axs,th(psat,:),'color',rgb('olive'),'linewidth',2);
            
            pastlimit = omc(psat,:)>th(psat,:);
            if any(pastlimit) && ~all(isnan(omc(psat,pastlimit)))
                aux = 1:size(omc(psat,:),2);
                plot(axs,aux(pastlimit),omc(psat,pastlimit),'ok','MarkerSize',10,'linewidth',2)
            end
            
            xlim(axs,[0 nEpoch]);
            xlabel('Epochs (s)');
            ylabel('Detector residuals and threshold (m)');
            title(['Satellite ',sprintf('%d',psat)]);
            legend('Residuals','Threshold','Cycle Slip','location','SouthEast');

            % Export
            assert(tryexport([folderpath,figname(satid,:)],fig,2)==0);

            % Clean up
            delete(fig);
            clear fig
            clear axs
        end
    end

end
