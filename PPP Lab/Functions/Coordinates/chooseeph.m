function [ sEpoch ] = chooseeph( sEpoch )
%CHOOSEEOH outputs the best ephemerides to use
%   The ephemerides is chosen with respect to the polynomial distance
%   TOW-TOC
%
%   Note that a user applying current navigation data will 
%   normally be working with negative values of (t-toc) and (t-toe) 
%   in evaluating the expansions.


    % Try with the closest    
    tnow  = sEpoch.ephtime;
    next  = tnow + 1;
    maxed = next > size(sEpoch.alleph,1);
    if all(maxed)
        return;
    else
        for s=1:userparams('MAXSAT')
            if maxed(s), continue; end;
            tonow  = abs(sEpoch.TOW-sEpoch.alleph{tnow(s)}(15,:)); 
            tonext = abs(sEpoch.TOW-sEpoch.alleph{next(s)}(15,:));
            if tonext < tonow;
                sEpoch.eph.data(:,s) = sEpoch.alleph{tnow(s)}(1:31,s);
                sEpoch.ephtime = next(s);
            end
        end
    end

end

%     table    = sEpoch.TOW-sEpoch.alleph{now}(15,:);
%     notvalid = table > 0 & table ~= sEpoch.TOW;
%     if any(notvalid)
%         now=now+1;
%         if now > size(sEpoch.alleph,1), return; end;
%         notvalid = notvalid & sEpoch.alleph{now}(1,:)~=0;
%         sEpoch.eph.data(:,notvalid) = sEpoch.alleph{now}(1:31,notvalid);
%         sEpoch.ephtime = now;
%     end


    
% tnow  = sEpoch.ephtime;
% next = tnow + 1;
% if next > size(sEpoch.alleph,1)
% return;
% else
% tonow  = abs(sEpoch.TOW-sEpoch.alleph{tnow}(15,:));
% tonext = abs(sEpoch.TOW-sEpoch.alleph{next}(15,:));
% 
% better = tonext < tonow;
% if any(better)
%     sEpoch.eph.data(:,better) = sEpoch.alleph{tnow}(1:31,better);
%     sEpoch.ephtime = next;
% end
% end