function plotcomponent(outname,data,nEpoch,yname,color)

    fig = figure('Visible','off');
    axs = axes('Parent',fig);
    
    plot(axs,data,'-','color',color); 
    
    xlim(axs,[0 nEpoch]);
    xlabel('Epochs (s)');
    ylabel(yname);
    
    % Export
    assert(tryexport(outname,fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear axs
    
end