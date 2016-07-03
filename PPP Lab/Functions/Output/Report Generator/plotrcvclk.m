function plotrcvclk(outname,clk,lastepoch)

    % Figure details
    fig = figure('Visible','off');
    axs = axes('Parent',fig);
    hold(axs,'on');
    set(fig,'units','normalize');
    plot(axs,clk,'-','color',rgb('blue')); 
    
    % Limits
    xlim([1 lastepoch]);
    
    % Cosmetics
    xlabel('Epochs (s)');
    ylabel('Receiver error (m)');
    
    % Export
    assert(tryexport(outname,fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear axs
    
end