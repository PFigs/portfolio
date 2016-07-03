function plotconstellation(outname,data)

    fig = figure('Visible','off');
    
%     aux=zeros(size(data.sataz,1),1);
%     for k=1:size(data.sataz,1)
%        if all(isnan(data.sataz(k,:)))
%            aux(k)=1;
%        end
%     end
%     data.sataz(aux==1,:) = [];
    
%     aux=zeros(size(data.satelv,1),1);
%     for k=1:size(data.satelv,1)
%        if all(isnan(data.satelv(k,:)))
%            aux(k)=1;
%        end
%     end
%     data.satelv(aux==1,:) = [];
    
    h   = mmpolar(data.sataz,90-deg(data.satelv),'.k',...
        'RLimit',[0 90],...
        'TTickDelta',30,...
        'RTickUnits','º',...
        'RTickValue',[0 30 60 90],...
        'RTickLabel',[{'90º'},{'60º'},{'30º'},{'0º'}],...
        'Style','compass','Border','on',...
        'BackgroundColor',rgb('white'),...
        'RGridLineStyle',':',...
        'FontSize',9);
    set(h,'MarkerFaceColor',rgb('Deep Sky Blue'));
    set(h,'MarkerEdgeColor','black');

    % Export
    assert(tryexport(outname,fig,2)==0);
    
    % Clean up
    delete(fig);
    clear fig
    clear h

end