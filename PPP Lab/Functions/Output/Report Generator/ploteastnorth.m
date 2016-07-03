function ploteastnorth(outname,east,north,conf,lastepoch)

    %PLOT EN POSITION
    fig = figure('Visible','off');
    axs = axes('Parent',fig,'PlotBoxAspectRatio',[1 1 1]);
    hold(axs,'on');
    set(fig,'units','normalize');
    gradientplot(axs,east,north,'light','cadet blue','dark','Dark Olive Green');
%     errorellipse(axs, cov(east,north),'mu',[0,0],'conf',conf,'style','.k','normal','off');
%     errorellipse( axs, cov(east,north),'mu',[mean(east(end:-1:end-50)),mean(north(end:-1:end-50))],'conf',conf,'style','.b');
    
    axis equal;
    xlabel('East (m)');
    ylabel('North (m)');
%     leghandle = legend(axs,[sprintf('%02d',conf*100) '% confidence'],'Location','best');
%     legend(axs,'boxoff');   
%     markers=findobj(get(leghandle,'children'), 'Type', 'line', '-and', '-not', 'Marker', 'none');
%     set(markers(1),'color','b');
    
    % Export
    assert(tryexport(outname,fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear axs
    
end