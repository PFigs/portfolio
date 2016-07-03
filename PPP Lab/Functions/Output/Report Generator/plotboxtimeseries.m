function plotboxtimeseries(outname,data,xlb,ylb,interval,nEpoch)

    % Figure details
    fig = figure('Visible','off');
    axs = axes('Parent',fig);
    hold(axs,'on');
    
    % Trim into several intervals
    idx = 1:interval:nEpoch;
    idx = [idx,nEpoch];
    mat = [];
    for n=1:length(idx)-1
        mat{n} = data(idx(n):idx(n+1)-1);
    end
    
    %resize last
    mat{end} = [mat{end}; nan(interval-size(mat{end},1),1)];
    
    mat = celltomatrix(mat);
    
    xlabels = createlabels(idx);
    boxplot(axs,mat',xlabels','whisker',Inf,'plotstyle','compact');
%     xlabel(xlb)
    ylabel(ylb)
    
    % Export
    assert(tryexport(outname,fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear axs
end

function mat = celltomatrix(celldata)
    celldata = celldata(:);
    mat      = zeros(length(celldata),length(celldata{1}));

    for k=1:length(celldata)
        mat(k,:)=celldata{k};
    end
end

function labels = createlabels(vec)

    for k=1:length(vec)
        str{k} = num2str(vec(k));        
    end
    
    for k=1:length(vec)-1
        labels{k} = [str{k},' - ',str{k+1},' (s)'];
    end            
    labels = labels(:);
end