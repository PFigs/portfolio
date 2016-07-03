function [linelabel,collumnlabels,stdsat] = buildresidualstd(residuals)
    
    linelabel = [];
    stdsat = zeros(32,4);
    for psat = 1:userparams('MAXSAT')
        
        valid = ~isnan(residuals(psat,:));
        if all(valid==0), continue; end;
        stdsat(psat,1) = std(residuals(psat,valid));
        stdsat(psat,2) = min(residuals(psat,valid));
        stdsat(psat,3) = max(residuals(psat,valid));
        stdsat(psat,4) = mean(residuals(psat,valid));
        
        if  stdsat(psat,1) == 0, continue; end;
        linelabel = [linelabel,'\textbf{PRN ',num2str(psat),'},'];
    end
    stdsat = stdsat(stdsat(:,1)~=0,:);
    linelabel(end)=[];
    collumnlabels = ['\textbf{Metric},\textbf{STD (m)},\textbf{Min (m)},\textbf{Max (m)},\textbf{Mean (m)}'];
        
end