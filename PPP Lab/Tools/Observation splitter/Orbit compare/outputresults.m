function outputresults( sStat, satlist, varargin )
%OUTPUTRESULTS displays and writes the comparator outputs
  
    nSat    = length(satlist);
    
    % ENU POSITION
%     for n=1:nSat
%         poshandle = figure('Name',['Satellite ' sprintf('%d',satlist(n))],'NumberTitle','off');
%         posaxis = axes('Parent',poshandle);
%         title('Satellite position in ENU coordinates (period of 60 seconds)',...
%               'fontsize',12,'fontweight','b');
%         xlabel('East (Mm)','fontsize',11,'fontweight','b');
%         ylabel('North (Mm)','fontsize',11,'fontweight','b');
%         zlabel('Up (Mm)','fontsize',11,'fontweight','b');
%         hold(posaxis);
%         brd = [];
%         igs = [];
%         for k=1:60:size(sStat.satenu,2)
%             brd = [brd; sStat.satenu(k).data(n,1), sStat.satenu(k).data(n,2), sStat.satenu(k).data(n,3)];
%             igs = [igs; sStat.satenu(k).data(n,4),sStat.satenu(k).data(n,5),sStat.satenu(k).data(n,6)];
%         end
%         brd = brd .*1e-06;
%         igs = igs .*1e-06;
%         plot(posaxis,brd(:,1),brd(:,2),'k.');
%         plot(posaxis,igs(:,1),igs(:,2),'bd');
%     end


    % DIFFERENCE XYZ
    for m=1:nSat
        h = figure('Name',['Orbit difference for satellite ' sprintf('%d',satlist(m))],...
            'NumberTitle','off','visible','off');
        diffaxis = axes('Parent',h);
        title(['Difference in XYZ coordinates for satellite ' sprintf('%d',satlist(m))],...
              'fontsize',12,'fontweight','b');
        xlabel(diffaxis,'Epochs(s)','fontsize',11,'fontweight','b');
        ylabel(diffaxis,'Orb_{eph} - Orb_{igs} (m)','fontsize',11,'fontweight','b');
        hold(diffaxis);

        obs=1:size(sStat.satenu,2);
        for k=obs
            x(k,1) = sStat.satxyz(k).data(m,1) - sStat.satxyz(k).data(m,4);
            y(k,1) = sStat.satxyz(k).data(m,2) - sStat.satxyz(k).data(m,5);
            z(k,1) = sStat.satxyz(k).data(m,3) - sStat.satxyz(k).data(m,6);
            nxyz(k,1) = norm([x(k,1) y(k,1) z(k,1)]);
        end

        plot(diffaxis,x,'.g');
        plot(diffaxis,y,'.k');
        plot(diffaxis,z,'.b');
        plot(diffaxis,nxyz,'*c');
        xlim(diffaxis,[0 obs(end)]);
        hleg = legend('X','Y','Z','||[X Y Z]||',...
          'Location','NorthEastOutside');
        set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1])
        drawnow
        set(h,'PaperType','a4','PaperOrientation','landscape');
        fillPage(h);
        fname(m,:) = sprintf('Print/DiffXYZ%02d.pdf',satlist(m));
        print(h,'-dpdf',fname(m,:))
    end
    aux=cellstr(fname)';
    finalname = 'Print/xyzdiffs.pdf';
    if exist(finalname)
       delete(finalname); 
    end
    append_pdfs(finalname, aux{:});
    delete(aux{:});


    % ENU DIFFERENCE 
    for m=1:nSat
        % Creates handle for user position
        h = figure('Name',['Orbit difference for satellite ' sprintf('%d',satlist(m))],...
            'NumberTitle','off','visible','off');
        diffaxis = axes('Parent',h);
        title(['Difference in ENU coordinates for satellite ' sprintf('%d',satlist(m))],...
              'fontsize',12,'fontweight','b');
        xlabel(diffaxis,'Epochs(s)','fontsize',11,'fontweight','b');
        ylabel(diffaxis,'Orb_{eph} - Orb_{igs} (m)','fontsize',11,'fontweight','b');
        hold(diffaxis);

        obs=1:size(sStat.satenu,2);
        for k=obs
            e(k,1) = sStat.satenu(k).data(m,1) - sStat.satenu(k).data(m,4);
            n(k,1) = sStat.satenu(k).data(m,2) - sStat.satenu(k).data(m,5);
            u(k,1) = sStat.satenu(k).data(m,3) - sStat.satenu(k).data(m,6);
            nenu(k,1) = norm([e(k,1) n(k,1) u(k,1)]);
        end

        plot(diffaxis,e,'.g');
        plot(diffaxis,n,'.k');
        plot(diffaxis,u,'.b');
        plot(diffaxis,nenu,'*c');
        xlim(diffaxis,[0 obs(end)]);
        hleg = legend('East','North','Up','||[E N U]||',...
          'Location','NorthEastOutside');
        set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1])
        drawnow
        set(h,'PaperType','a4','PaperOrientation','landscape');
        fillPage(h);
        fname(m,:) = sprintf('Print/DiffENU%02d.pdf',satlist(m));
        print(h,'-dpdf',fname(m,:))
    end
    aux=cellstr(fname)';
    finalname = 'Print/enudiffs.pdf';
    if exist(finalname)
       delete(finalname); 
    end
    append_pdfs(finalname, aux{:});
    delete(aux{:});

    % CLK DIFFERENCE
    for m=1:nSat
        % Creates handle for user position
        h = figure('Name',['Orbit difference for satellite ' sprintf('%d',satlist(m))],...
            'NumberTitle','off','visible','off');
        diffaxis = axes('Parent',h);
        title(['Difference in CLK value for satellite ' sprintf('%d',satlist(m))],...
              'fontsize',12,'fontweight','b');
        xlabel(diffaxis,'Epochs(s)','fontsize',11,'fontweight','b');
        ylabel(diffaxis,'TSV_{eph} - CLK_{igs} (m)','fontsize',11,'fontweight','b');
        hold(diffaxis);

        obs=1:size(sStat.satenu,2);
        for k=obs
            clk(k,1) = sStat.satclk(k).data(m,1) - sStat.satclk(k).data(m,2);
        end

        plot(diffaxis,clk,'*c');
        xlim(diffaxis,[0 obs(end)]);
        drawnow
        set(h,'PaperType','a4','PaperOrientation','landscape');
        fillPage(h);
        fname(m,:) = sprintf('Print/DiffCLK%02d.pdf',satlist(m));
        print(h,'-dpdf',fname(m,:))
    end
    aux=cellstr(fname)';
    finalname = 'Print/clkdiffs.pdf';
    if exist(finalname)
       delete(finalname); 
    end
    append_pdfs(finalname, aux{:});
    delete(aux{:});
    

end

