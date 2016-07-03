function nok=tryexport(outname,fig,lim)    

    if nargin == 2
        lim = 5;
    end

    count = 0;
    while count < lim
        count = count +1;
        try
              saveas(gcf,outname,'fig');
%              try
%                export_fig(outname,'-png','-transparent','-m3',fig);
%              catch
%             print2eps(outname,fig);
             print(fig, '-dpng', outname);
%              end
            nok = 0;
            count = inf;
        catch
            disp('*Failed to save file...');
            nok = 1;
        end
    end
    
end