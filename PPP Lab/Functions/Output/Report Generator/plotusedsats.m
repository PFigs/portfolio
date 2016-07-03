function plotusedsats(outname,data,nEpochs,nSat)

    fig       = figure('Visible','off');
    axs       = axes('Parent',fig);
    hold(axs,'on');
    
    plot(axs,data(1:32,:)','-b','LineWidth',2.5)
    
    xlim(axs,[0,nEpochs]);
    ylim(axs,[1,nSat]);
    set(axs,'ytick',1:nSat);
    set(axs,'yminorgrid','on');
    
    title(axs,'Used Satellites');
    xlabel('Epochs (s)');
    ylabel('Satellite number');  
    
    % Export
    assert(tryexport(outname,fig,2)==0);
    box on;
    % Clean up
    delete(fig);
    clear fig
    clear axs

end