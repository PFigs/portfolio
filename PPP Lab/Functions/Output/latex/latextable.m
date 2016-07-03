function latextable( fid, data, labels, captions)
%LATEXTABLE creates Latex table from a an array of cells
%   
%   INPUT
%   FID      - File descriptor 
%   DATA     - Cell array
%              {1} - row labels (separated by ',')
%              {2} - collumn labels (separated by ',')
%              {3} - Data as it should be printed [Row x Col]
%   LABELS   - Latex labels
%   CAPTIONS - Latex captions
%
%  Pedro Silva, Instituto Superior Tecnico, May 2012


    % Check if sizes are matching
    N = length(data(:,1)); % number of tables
    
    
    % slip input strings
    labels   = regexp(labels,',','split');
    captions = regexp(captions,',','split');
    
%     if N ~= length(captions) || N ~= length(labels)
%         commoncaption = 1;
%         if N == 1
%             error('latexfigure: Insuficient data');
%         end
%     else
%         commoncaption = 0;
%     end
    
    miniscale     = repmat({[sprintf('%1.1f',1/N),'\\linewidth']},N,1);
    scale         = repmat({'\\linewidth'},N,1);
    miniplacement = repmat({'!hpb'},N,1);
   
    
    %receives cell array with collumns
    latexline(fid,'\begin{table}[p]');
    count = 0;
    for K = 1:N
        count     = count + 1;
        table     = data(K,:);                      % table to write
        rlabels   = regexp(table{1},',','split');
        clabels   = regexp(table{2},',','split');
        values    = table{3};                        % values
        ncollumns = length(clabels);                 % number of collumns
        nrows     = length(rlabels);                 % number of rows
                
        colstr = [repmat(sprintf('|c'), 1, ncollumns),'|'];
        
        if N > 1
            fprintf(fid,['\t\\begin{minipage}[',miniplacement{count},']{',miniscale{count},'}\r\n']);
        end
        fprintf(fid,'\\centering\r\n');
        fprintf(fid,'\t\t\\caption{%s}\r\n',captions{count});
        fprintf(fid,'\t\t\\label{fig:%s}\r\n',labels{count});
        
        fprintf(fid,'\t\t\\begin{tabular}{%s}\r\n',colstr);
        
        
        fprintf(fid,'\t\t\\hline\r\n');
        % Write clabels
        fprintf(fid,'\t\t');
        for c = 1:ncollumns - 1
            fprintf(fid,'%s & ',clabels{c});
        end
        fprintf(fid,'%s \\\\\r\n ',clabels{c+1});
        fprintf(fid,'\t\t\\hline\r\n');
        
        
        % For each collumn
        for r = 1:nrows % data in collumn
            % write a full line
            fprintf(fid,'\t\t');
            for c = 1:ncollumns-1
                if c == 1 
                   fprintf(fid,'%s & ',rlabels{r});
                else
                   fprintf(fid,' & ');
                end
                fprintf(fid,'$%3.3f$',values(r,c)); 
                
            end   
%             fprintf(fid,'%f \\\\\r\n',values(r,c));
            fprintf(fid,'\\\\\r\n');
            fprintf(fid,'\t\t\\hline\r\n');
        end
        fprintf(fid,'\t\t\\end{tabular}\r\n');

        if N > 1
            fprintf(fid,'\t\\end{minipage}\r\n');
        end
    end
    
    latexline(fid,'\end{table}');



end
