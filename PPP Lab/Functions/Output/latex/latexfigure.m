function latexfigure(fid,figsname,labels,captions,varargin)
%WRITEFIGURE writes N figures side by side to a latex document
%   Allthough it is called latexsubfigure the package subfigure is not used
%   to display the figures, instead a minipage is used.
%   This package avoids problems with figure's legend numeration.
%
%   INPUT
%       FID - File descriptor
%       FIGNAME - Figure's name
%       LABEL   - Figure's label (send only one to set a global label)
%       CAPTION - Caption text to output (send only one to set a global caption)
%
%       VARARGIN
%           SCALE   - Scale factor (default: linewidth)
%           FIGCMD  - Use scale or width for figure
%   NOTE:
%       LABEL/CAPTION override each other when there is a dimension
%       mismatch
%
%   USAGE
%      latexsubfigure(1,'amehd,bombay,anthony,tont','a,b,c,d',...
%                       'to,not,be,some','scale','0.5','figcmd','scale')
%
%       The first figure will be set to SCALE of 0.5
%
%      latexsubfigure(1,'amehd,bombay,anthony,tont','a,b,c,d',...
%                       'to,not,be,some','scale','2in,3cm,4in')
%
%       The first 3 pictures will have a custom width of 2 inches, 3
%       centimeters and 4 inches respectively. As for the 4th picture it
%       will have the default \linewidth
%
% Pedro Silva, Instituto Superior Tecnico, May 2012

    % slip input strings
    labels   = regexp(labels,',','split');
    figsname = regexp(figsname,',','split');
    captions = regexp(captions,',','split');
    N        = length(figsname);
    
    if N ~= length(captions) || N ~= length(labels)
        commoncaption = 1;
        if N == 1
            error('latexfigure: Insuficient data');
        end
    else
        commoncaption = 0;
    end
    
    miniscale     = repmat({[sprintf('%1.1f',1/N),'\\linewidth']},N,1);
    scale         = repmat({'\\linewidth'},N,1);
    figcmd        = repmat({'width'},N,1);
    miniplacement = repmat({'!hpb'},N,1);
    figplacement  = repmat({'p'},N,1);
    
    % Default is used if a size mismatch is found - allows flexibility
    if nargin >= 5 && ~mod(nargin-4,2)
       for i=1:2:size(varargin,2)
           if strcmpi(varargin{i},'scale')
               custom   = regexp(varargin{i+1},',','split');
               k = 1;
               for each = custom
                  scale{k} = each{1}; 
                  k = k+1;
               end
           elseif strcmpi(varargin{i},'miniscale')
               custom = regexp(varargin{i+1},',','split');
               k = 1;
               for each = custom
                  miniscale{k} = each{1}; 
                  k = k+1;
               end
           elseif strcmpi(varargin{i},'figcmd')
              custom = regexp(varargin{i+1},',','split');
               k = 1;
               for each = custom
                  figcmd{k} = each{1}; 
                  k = k+1;
               end
           elseif strcmpi(varargin{i},'miniplacement')
               custom = regexp(varargin{i+1},',','split');
               k = 1;
               for each = custom
                  miniplacement{k} = each{1}; 
                  k = k+1;
               end
           elseif strcmpi(varargin{i},'figplacement')
               custom = regexp(varargin{i+1},',','split');
               k = 1;
               for each = custom
                  figplacement{k} = each{1}; 
                  k = k+1;
               end             
           end
       end
    end
    
    
    %TODO use latex check string
    count = 1;
    fprintf(fid,['\\begin{figure}[',figplacement{count},']\r\n']);
    for fig = figsname
        if N > 1
            fprintf(fid,['\\begin{minipage}[',miniplacement{count},']{',miniscale{count},'}\r\n']);
        end
        fprintf(fid,'\\centering\r\n');
        fprintf(fid,['\\includegraphics[',figcmd{count},'=',scale{count},']{%s}\r\n'],fig{1});
        if ~commoncaption
            fprintf(fid,'\\caption{%s}\r\n',captions{count});
            fprintf(fid,'\\label{fig:%s}\r\n',labels{count});
        end
        if N > 1
            fprintf(fid,'\\end{minipage}\r\n');
        end
        count = count + 1;
    end
    if commoncaption
        fprintf(fid,'\\caption{%s}\r\n',captions{1});
        fprintf(fid,'\\label{fig:%s}\r\n',labels{1});
    end
    fprintf(fid,'\\end{figure}\r\n');
    
end

