function plotbox(outname,data,xlb,ylb,colors)

    % Figure details
    fig = figure('Visible','off');
    axs = axes('Parent',fig);
    hold(axs,'on');
    
    if isempty(colors) || nargin == 4
        boxplot(axs,data,'whisker',Inf,'plotstyle','compact');
        xlabel(xlb)
    else
        boxplot(axs,data,xlb,'colors',colors,'whisker',Inf);
    end
    ylabel(ylb)
    
    % Export
    assert(tryexport(outname,fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear axs
end