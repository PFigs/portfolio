function storeashtech( message, path )
%STOREASHTECH saves data to a file for offline processing

    % Saves raw message
%     persistent name;
% %     if ~strcmpi(message.receiver,'ZXW')
%     % Save message to file
%         if ~isempty(name) && ~isnan(message.rawmsg(1))
%             fid = fopen(name,'ab');
%             fwrite(fid,message.rawmsg);
%             message.rawmsg = NaN;   % To avoid repetition
%             fclose(fid);
% 
%         % Waits for a MPC message and only then starts to write
%         elseif isempty(name) &&((strcmpi(message.msgID,'MPC') || strcmpi(message.msgID,'RPC')))
%             timestr = datestr(now);
%             timestr(timestr == ':') = '-';
%             name = [path,'raw/ashtech',timestr,'.bin'];
%             fid     = fopen(name,'a');
%             if fid == -1
%                 error('PPPLAB:storeraw','Failed to open file');
%             end
%             clk = clock;
%             fprintf(fid,'$PASHR,PFS,%04d%02d%02d%02d%02d%02.0f,',clk(1),clk(2),clk(3),clk(4),clk(5),clk(6));
%             fprintf(fid,'%07d,',1*1e3);
%             if strcmpi(message.msgID,'MPC')
%                 fprintf(fid,'%010d\r\n',message.ranges.SEQ);
%             else
%                 fprintf(fid,'**********\r\n');
%             end
%             fwrite(fid,message.rawmsg);
%             message.rawmsg = NaN;   % To avoid repetition
%             fclose(fid);
%         end  
%     end

    if message.dirty
        message.dirty = 0; % Ok I got it!
        % Saves Ephemerides
        if isstruct(message.eph) && strcmpi(message.msgID,'SNV') 
            message = message.eph;
            id      = message.update; % last line has the same info in every collumn
            message = message.data;   % access matrix;
            fid = fopen(strcat(path,'eph/',date,'ephemerides',sprintf('%2d',id)),'a');
            fprintf(fid,'%d %d 0 %d %60.60f %60.60f 0 %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f 0 %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f %60.60f\r\n',...
                        id, ...
                        message(ephidx('WN'),id)    , message(ephidx('URA'),id),...
                        message(ephidx('Health'),id), message(ephidx('IODC'),id),...
                        message(ephidx('TGD'),id)   , message(ephidx('TOC'),id),...
                        message(ephidx('AF2'),id)   , message(ephidx('AF1'),id),...
                        message(ephidx('AF0'),id)   , message(ephidx('IODE'),id),... %written 2 times!
                        message(ephidx('IODE'),id)  , message(ephidx('TOE'),id),... 
                        message(ephidx('M0'),id)    , message(ephidx('ECC'),id),...
                        message(ephidx('SQRA'),id)  , message(ephidx('DN'),id),...
                        message(ephidx('Omega0'),id), message(ephidx('I0'),id),...
                        message(ephidx('Omega'),id) , message(ephidx('Omegadot'),id),... 
                        message(ephidx('IDOT'),id)  , message(ephidx('CRC'),id),...
                        message(ephidx('CRS'),id)   , message(ephidx('CUC'),id),...
                        message(ephidx('CUS'),id)   , message(ephidx('CIC'),id),...
                        message(ephidx('CIS'),id)   , message(ephidx('TOW'),id));
            fclose(fid);

        %Saves ranges
        elseif strcmpi(message.msgID,'RPC') || strcmpi(message.msgID,'MCA') 
            message = message.ranges;
            if isstruct(message) && length(message.SATLIST) >= 4
                for id = message.SATLIST;
%                     measures = message.PRL1(id) && message.PRL2(id) && message.CPL1(id) && message.CPL2(id);
    %                quality = ~message.WARNINGL1(id) && ~message.WARNINGL2(id);
%                     if measures %&& quality
                        fid = fopen(strcat(path,'mes/',date,'pseudoranges',sprintf('%02d',id)),'a');
                        fprintf(fid,'%60.60f\t%60.60f\t%60.60f\t%60.60f\t%d\t%60.60f\t%60.60f\r\n',...
                                   message.PRL1(id), message.CPL1(id),...
                                   message.PRL2(id), message.CPL2(id),...
                                   message.TOW,...
                                   message.WARNINGL1(id), message.WARNINGL2(id));
                        fclose(fid);
%                     end
                end
            end

        %Saves ranges and doppler (L1)
        elseif strcmpi(message.msgID,'DPC')
            message = message.ranges;
            if isstruct(message) && length(message.SATLIST) >= 4
                for id = message.SATLIST;
%                     measures = message.PRL1(id) && message.PRL2(id) && message.CPL1(id) && message.CPL2(id);
    %                 quality  = ~message.WARNINGL1(id) && ~message.WARNINGL2(id) && message.HEALTH(id);
%                     if measures %&& quality
                        fid = fopen(strcat(path,'mes/',date,'pseudoranges',sprintf('%02d',id)),'a');
                        fprintf(fid,'%60.60f\t%60.60f\t%60.60f\t%60.60f\t%d\t%60.60f\t%60.60f\t%60.60f\t%60.60f\t%60.60f\r\n',...
                                   message.PRL1(id), message.CPL1(id),...
                                   message.PRL2(id), message.CPL2(id),...
                                   message.TOW,...
                                   message.WARNINGL1(id),message.WARNINGL2(id),...
                                   message.DOL1(id), message.DOL2(id),...
                                   message.SNRL1(id));
                        fclose(fid);
%                     end
                end
            end

        %Saves all measures made by receiver
        elseif strcmpi(message.msgID,'MPC')
            if isstruct(message.ranges) && message.ranges.LEFT == 0 
               message = message.ranges;
               satlist = message.SATLIST(message.SATLIST > 0); %retrieves the satellites identifiers
               satlist = satlist(satlist <= 32);
               if length(satlist)>= 4    
                   for id  = satlist % Save measurements only if theres data for every kind
%                        measures = message.PRL1(id) && message.PRL2(id) && message.CPL1(id) && message.CPL2(id);
%                        measures = measures ||( message.PRCA(id) && message.CPCA(id) && message.PRL2(id) && message.CPL2(id));
    %                    quality  = message.QUALITYL1(id) == 24 && message.QUALITYL2(id) == 24;
%                        if measures %&& quality
                           fid = fopen(strcat(path,'mes/',date,'pseudoranges',sprintf('%02d',id)),'a');
                           fprintf(fid,['%60.60f\t%60.60f\t%60.60f\t%60.60f\t',...
                                        '%d\t',...
                                        '%60.60f\t%60.60f\t%60.60f\t%60.60f\t',...
                                        '%60.60f\t%60.60f\t%60.60f\t%60.60f\t',...
                                        '%60.60f\t%60.60f\t%60.60f\t%60.60f\t',...
                                        '%60.60f\t%60.60f\t%60.60f\t%60.60f\t',...
                                        '%60.60f\r\n'],...
                                       message.PRL1(id), message.CPL1(id),...
                                       message.PRL2(id), message.CPL2(id),...
                                       message.TOW,... %5
                                       message.WARNINGL1(id),message.WARNINGL2(id),...
                                       message.DOL1(id), message.DOL2(id),...
                                       message.SNRL1(id), message.SNRL2(id),... %11
                                       message.QUALITYL1(id), message.QUALITYL2(id),...
                                       message.BFL1(id), message.BFL2(id),... %15
                                       message.PRCA(id), message.CPCA(id),...
                                       message.SNRCA(id), message.DOCA(id),...
                                       message.WARNINGCA(id), message.QUALITYCA(id),...
                                       message.BFCA(id));                                   
                           fclose(fid);
%                        end
                   end
               end
            end
        elseif strcmpi(message.msgID,'ION')
            if isstruct(message.iono)
               message = message.iono;   
               fid = fopen(strcat(path,'ion/ionosphere.txt'),'a');
               fprintf(fid,'%60.60f\t%60.60f\t%60.60f\t%60.60f\t%60.60f\t%60.60f\t%60.60f\t%60.60f\r\n',...
                           message.alpha(1), message.alpha(2),...
                           message.alpha(3), message.alpha(4),...
                           message.beta(1), message.beta(2),...
                           message.beta(3), message.beta(4));
               fclose(fid);
            end
        else
            warning('ASHTECH:store',['Ooooops! failed to save data for ' sprintf('%s',message.msgID)]);
        end
    end

end

