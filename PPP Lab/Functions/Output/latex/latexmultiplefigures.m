function latexmultiplefigures(fid,figname,figid,nFigs,label,caption)

    n = 1;
    % Even
    if ~mod(nFigs,2)
        while n <= nFigs
        latexfigure(fid,[figname(n,:),',',figname(n+1,:)],...
                [label,sprintf('%d%d',figid(n),figid(n+1))],...
                [caption,' ',...
                sprintf('%d',figid(n)),' and ',sprintf('%d',figid(n+1))]);
        n=n+2;
        end

    % Odd
    elseif ~mod(nFigs-1,2)
        while n < nFigs-1
        latexfigure(fid,[figname(n,:),',',figname(n+1,:)],...
            [label,sprintf('%d%d',figid(n),figid(n+1))],...
            [caption,' ',...
            sprintf('%d',figid(n)),' and ',sprintf('%d',figid(n+1))]);
        n=n+2;
        end
        latexfigure(fid,figname(n,:),...
                [label,sprintf('%d',figid(n))],...
                [caption,' ',...
                sprintf('%d',figid(n))]);

    % Odd but just one    
    else
        latexfigure(fid,figname(n,:),...
                [label,sprintf('%d',figid(n))],...
                [caption,' ',...
                sprintf('%d',figid(n))]);
    end

end
