function  buildtemplate(reportname,folderpath,title,sections,latexstyle,margins,papertype,fontsize)
%BUILDTEMPLATE constructs a latex master file and the corresponding
%makefile
%
%   OBJECTIVE
%   Build a simple report from several other latex files, passed through
%   sections. Please note that for each file, sections will two contiguous
%   fields, the first one for the file name and the second one for the
%   section title.
%
%   INPUTS
%   REPORTNAME - Name for the PDF file
%   FOLDERPATH - Path to the root of the latex folder (files MUST be in
%                ./tex/)
%   TITLE      - Document title
%   SECTIONS   - A cell array with {'filename k','section name k',...}
%   LATEXSTYLE - Use report for best results (default: report)
%   MARGINS    - Document margins in cm (default: 2cm) must be a 4-by-4 
%                array with the following meaning [left bottom right top]
%   PAPERTYPE  - Paper format (default: A4)
%   FONTSIZE   - Font size in pt (default: 11pt) 
%
%   OUTPUTS
%   REPORTNAME.TEX and Makefile
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012

    % Check input
    error(nargchk(4, 8, nargin, 'struct'))
    
    % The first four arguments are mandatory
    if nargin == 4
        latexstyle = 'report';
        margins    = 'margins';
        papertype  = 'a4paper';
        fontsize   = '11'; 
    end
    
    fid = fopen([folderpath,reportname,'.tex'],'w');
    if fid == -1 
        error('failed to open file');
    end
    latexline(fid,['%% CREATED ON ',datestr(now)]);
    latexline(fid,'\documentclass[%dpt,%s]{%s}','double',fontsize,papertype,latexstyle);
    latexline(fid,'\usepackage[utf8]{inputenc}');
    latexline(fid,'\usepackage[english]{babel}');
    latexline(fid,'\usepackage{amsmath}');
    latexline(fid,'\usepackage{amsfonts}');
    latexline(fid,'\usepackage{morefloats}');
    latexline(fid,'\usepackage{amssymb}');
    latexline(fid,'\usepackage{graphicx}');
    latexline(fid,'\usepackage{caption}');
    latexline(fid,'\usepackage{epstopdf}');
    latexline(fid,'\usepackage[left=%dcm,bottom=%dcm,right=%dcm,top=%dcm]{geometry}','double',margins);

    latexline(fid,'\renewcommand{\topfraction}{0.9}');
    latexline(fid,'\renewcommand{\bottomfraction}{0.8}');
    latexline(fid,'\setcounter{topnumber}{2}');
    latexline(fid,'\setcounter{bottomnumber}{2}');
    latexline(fid,'\setcounter{totalnumber}{4}');
    latexline(fid,'\setcounter{dbltopnumber}{2}');
    latexline(fid,'\renewcommand{\dbltopfraction}{0.9}');
    latexline(fid,'\renewcommand{\textfraction}{0.07}');
    latexline(fid,'\renewcommand{\floatpagefraction}{0.7}');
    latexline(fid,'\renewcommand{\dblfloatpagefraction}{0.7}','double');

    
    latexline(fid,'\begin{document}','double');
    
    latexline(fid,'\begin{center}');
    latexline(fid,'{\LARGE \textbf{%s}}\\[0.25cm]',title); clk = clock;
    latexline(fid,'\textbf{Date:} \today ~ %d:%d\\',clk(4),clk(5));
    
    if isunix
        try
            [~,user]  = unix('users'); user(1) = upper(user(1));
            [~,sysOS] = unix('lsb_release -a');
            D         = strfind(sysOS,'Description:')+1;
            R         = strfind(sysOS,'Release:');
            latexline(fid,'\textbf{Created by:} %s  (MATLAB: %s, OS: %s)',...
                user,version,sysOS(D+length('Description:'):R-2));
        catch
            latexline(fid,'\textbf{Created by:} MATLAB %s under UNIX',version);
        end
    else
        latexline(fid,'\textbf{Created by:} MATLAB %s under WINDOWS',version);
    end
    
    latexline(fid,'\end{center}','double');
    
    for each=1:2:length(sections)
        if isempty(sections{each}), continue; end;
        latexline(fid,'\section*{%s}',sections{each+1});
        latexline(fid,'\input{%s}','double',sections{each});
        if each ~= length(sections)
            latexline(fid,'\clearpage');
        end
    end
    
    latexline(fid,'\end{document}');
    fclose(fid);

    % Creates make file
    fid = fopen([folderpath,'Makefile'],'w');
    if fid == -1 
        error('failed to open file');
    end

    fprintf(fid,'# ---------------------------------------------------------\r\n');
    fprintf(fid,['# CREATED ON ',datestr(now),'\r\n']);
    fprintf(fid,'# ---------------------------------------------------------\r\n\r\n');

    fprintf(fid,'# Main filename\r\n');
    fprintf(fid,'FILE="%s"\r\n\r\n',reportname);

    fprintf(fid,'all:\r\n');
    fprintf(fid,'\tpdflatex  -shell-escape -synctex=1 -interaction=nonstopmode ${FILE}\r\n');
    fprintf(fid,'\tpdflatex  -shell-escape -synctex=1 -interaction=nonstopmode ${FILE}\r\n\r\n');

    fprintf(fid,'clean:\r\n');
        fprintf(fid,'\t(rm -rf *.bak *.aux *.bbl *.blg *.nlo *.nls *.idx *.ind *.ilg *.lof *.log *.lop *.lot *.out *.spl *.toc *.~ *.dvi *.gz)\r\n\r\n');


    fprintf(fid,'wipe:\r\n');
    fprintf(fid,'\tmake clean\r\n');
    fprintf(fid,'\trm -f *~ *.*%%\r\n');
    fprintf(fid,'\trm -f $(FILE).pdf $(FILE).ps\r\n');
    fprintf(fid,'\trm -rf ./pics\r\n');
    fprintf(fid,'\trm -rf ./tex\r\n');
    fprintf(fid,'\trm -rf *.tex\r\n');
    fprintf(fid,'\trm -rf Makefile\r\n');

    fclose(fid);
end
