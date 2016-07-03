function [figname, seensats, flag] = plotavailablesats(folderpath,outname,sats,nEpoch,link,type,flag)

    numvector  = 1:userparams('MAXSAT');

    figname = outname;
    fig     = figure('Visible','off');
    axs     = axes('Parent',fig);
    aux     = repmat(numvector',1,nEpoch);
    paux    = sats.*aux(1:32,:);
    paux(paux == 0) = NaN; % Avoids vetical lines when plotting
    xlim(axs,[0,nEpoch]);
    ylim(axs,[1,userparams('MAXSAT')]);
    set(axs,'ytick',1:userparams('MAXSAT'));
    set(axs,'yminorgrid','on');
    hold(axs,'on');
    title(axs,['Visible Satellites - ',link,' ',type,' code']);
    xlabel('Epochs (s)');
    ylabel('Satellites');  

    plot(axs,1:nEpoch,paux,'-b','LineWidth',2.5)
    
    % Export
    assert(tryexport([folderpath,outname],fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear axs
    
    seensats = unique(paux(~isnan(paux)));
    flag     = flag + 1;

end

