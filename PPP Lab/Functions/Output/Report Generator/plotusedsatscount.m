function plotusedsatscount(outname,data,nEpochs,nSat)
%Plots the number of satellites used each epoch 

    fig       = figure('Visible','off');
    axs       = axes('Parent',fig);
    hold(axs,'on');
    
    const = sum(~isnan(data));
    miny  = min(const)-1;
    maxy  = max(const)+1;
    const(const==0) = NaN;
    plot(axs,const,'-b','LineWidth',2.5)
    
    xlim(axs,[0,nEpochs]);
    %ylim(axs,[miny,maxy]);
    ylim(axs,[5,10]);
    set(axs,'ytick',5:10);
    set(axs,'yminorgrid','on');
    
    xlabel('Epochs (s)');
    ylabel('Number of used satellites');  
    
    box on;
    % Export
    assert(tryexport(outname,fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear axs

end