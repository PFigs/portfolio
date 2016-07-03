function [values,linelabel,collumnlabels] = buildenustd(east,north,up)

    sigmaeast  = std(east);
    sigmanorth = std(north);
    sigmaup    = std(up);

    mineast   = min(east);
    minnorth  = min(north);
    minup     = min(up);
    
    maxeast   = max(east);
    maxnorth  = max(north);
    maxup     = max(up);
    
    meaneast  = mean(east);
    meannorth = mean(north);
    meanup    = mean(up);


    values        = [sigmaeast,sigmanorth,sigmaup,mineast,minnorth,...
                    minup,maxeast,maxnorth,maxup,meaneast,meannorth,meanup];
    linelabel     = [...
                    '\textbf{STD East},\textbf{STD North},\textbf{STD Up},',...
                    '\textbf{Min East},\textbf{Min North},\textbf{Min Up},',...
                    '\textbf{Max East},\textbf{Max North},\textbf{Max Up},',...
                    '\textbf{Mean East},\textbf{Mean North},\textbf{Mean Up}'];
    collumnlabels = ['\textbf{Metric},\textbf{Value (m)}'];
        
end