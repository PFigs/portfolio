function sAlgo = slipdetector( sEpoch, sAlgo, TOW, DOY, WD )

%     sEpoch.slipfig1
%     sEpoch.slipfig2


    %TODO
    % Accum std and dont use cycle slip data
    % Correct data
    % Clean this

    c    = gpsparams('C');
    f1   = gpsparams('f1');
    f2   = gpsparams('f2');
    lbdi = gpsparams('lbdif');
    
    % Initializations
    % IONO FREE RANGE COMBINATIONS
    a = (1575.42^2)/(1575.42^2-1227.60^2);
    b = (1227.60^2)/(1575.42^2-1227.60^2);

    nSat    = sAlgo.nSat;
    sg      = 2*0.02;
    
    
    if sEpoch.iEpoch == 100
        sAlgo.ranges.CPL1 = sAlgo.ranges.CPL1(1) + 0.1;
%         sAlgo.ranges.CPL2 = sAlgo.ranges.CPL2(1) + 0.1;
    end
    
    % LG combination
    cpiono  = c/f1*sAlgo.ranges.CPL1 - c/f2*sAlgo.ranges.CPL2;
    sAlgo.cscomb(:,sEpoch.iEpoch) = cpiono; % save it
    

    % Are we able to test this epoch for a cycle slip?
    if sEpoch.iEpoch > 2
       diff = sAlgo.scnext(1)-cpiono(1);
       if diff > 3*std(sAlgo.cscomb(1,1:sEpoch.iEpoch)) || diff < -3*std(sAlgo.cscomb(1,1:sEpoch.iEpoch))
           fprintf('cycle slip at %d\n',sEpoch.iEpoch);
       end
       hold on;
       plot(sEpoch.slipfig2,sEpoch.iEpoch,diff(1));
       plot(sEpoch.slipfig2,sEpoch.iEpoch,3*std(sAlgo.cscomb(1,1:sEpoch.iEpoch)),'g');
       drawnow;
    end

    
    % Compute the next value by fitting a quadratic curve
    if sEpoch.iEpoch == 1
        sAlgo.scnext=cpiono;
    elseif sEpoch.iEpoch < 2
        for each=1:nSat
            [p,S,mu]             = polyfit(1:sEpoch.iEpoch,sAlgo.cscomb(each,1:sEpoch.iEpoch),1);
            sAlgo.scnext(each,1) = polyval(p,sEpoch.iEpoch,S,mu);
        end
    else
       for each=1:nSat
           try
           [p,S,mu]             = polyfit(sEpoch.iEpoch-9:sEpoch.iEpoch,sAlgo.cscomb(each,1:sEpoch.iEpoch),1);
           catch
               [p,S,mu]         = polyfit(1:sEpoch.iEpoch,sAlgo.cscomb(each,1:sEpoch.iEpoch),1);
           end
            
            sAlgo.scnext(each,1) = polyval(p,sEpoch.iEpoch,S,mu);
       end 
    end
    
    
    
    plot(sEpoch.slipfig1,sEpoch.iEpoch,cpiono(1,1),'b','MarkerSize',10);
    plot(sEpoch.slipfig1,sEpoch.iEpoch,sAlgo.scnext(1,1),'r','MarkerSize',10);
    plot(sEpoch.slipfig1,sEpoch.iEpoch,sAlgo.scnext(1,1)+3*std(sAlgo.cscomb(1,1:sEpoch.iEpoch)),'g','MarkerSize',10);
    plot(sEpoch.slipfig1,sEpoch.iEpoch,sAlgo.scnext(1,1)-3*std(sAlgo.cscomb(1,1:sEpoch.iEpoch)),'g','MarkerSize',10);
end



%     sats = [];
%     for k = 1:32
%        if any(sEpoch.ranges.CPL1(:,k) ~= 0)
%            sats = [sats; k];
%        end
%     end
%     
% %     sEpoch.ranges.CPL1 = c/f1 * sEpoch.ranges.CPL1; %meter conversion
% %     sEpoch.ranges.CPL2 = c/f2 * sEpoch.ranges.CPL2; %meter conversion
%     
%     
%     %  this is only for one epoch
%     phdiff   = sEpoch.ranges.CPL1(:,sats)-sEpoch.ranges.CPL2(:,sats);
% 
% %     widelane = phdiff - (f1*sEpoch.ranges.CPL1(:,sats) + f2*sEpoch.ranges.CPL2(:,sats))./((f1+f2)*(c/(f1-f2)));
%     
%     for each = 1:max(size(sats))
%         figure
%         plot(phdiff(:,each));
%     end