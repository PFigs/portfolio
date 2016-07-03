function plotenu(outname,east,north,up,enumin,enumax,lastepoch)

    % Figure details
    fig = figure('Visible','off');
    axs = axes('Parent',fig);
    hold(axs,'on');
    set(fig,'units','normalize');
    plot(axs,east,'-','color',rgb('blue')); 
    plot(axs,north,'-','color',rgb('dark green')); 
    plot(axs,up,'-','color',rgb('orange'));
    
    % Limits
    xlim([1 lastepoch]);
    ylim([floor(enumin) ceil(enumax)]);
    
    % Cosmetics
    title(axs,'Receiver position in ENU');
    xlabel('Epochs (s)');
    ylabel('North, East, Up (m)');
    hleg = legend(axs,'East','North','Up','Location','NorthEast');
    set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1],'box','off')
    
    % Export
    assert(tryexport(outname,fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear axs
    
end