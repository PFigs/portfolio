function sAlgo = realslipdetector( sEpoch, sAlgo, TOW, DOY, WD )

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
    
    
    if sEpoch.iEpoch == 150
        sAlgo.ranges.CPL1 = sAlgo.ranges.CPL1(1) + 0.1;
        sAlgo.ranges.CPL1 = sAlgo.ranges.CPL1(1) + 0.1;
    end
    
    % LG combination
    mwcomb  = sAlgo.ranges.CPL1 - sAlgo.ranges.CPL2 - ...
              (f1-f2)/(f1+f2)*(sAlgo.ranges.PRL1/(c/f1) + ...
              sAlgo.ranges.PRL2/(c/f2));
          
    sAlgo.mwcomb(:,sEpoch.iEpoch) = mwcomb; % save it
    
    Ndelta  = sAlgo.ndelta + 1/sEpoch.iEpoch.*(sAlgo.mwcomb(:,sEpoch.iEpoch)-sAlgo.ndelta);
    biasvar = sAlgo.biasvar + 1/sEpoch.iEpoch.*( (sAlgo.mwcomb(:,sEpoch.iEpoch)-sAlgo.ndelta).^2 - sAlgo.biasvar);            
    sAlgo.ndelta  = mwcomb;
    sAlgo.biasvar = biasvar;

    % NDELTA AND BIASVAR can be used to test the undifferenced range as
    % well, providing a two step mechanism

    % Are we able to test this epoch for a cycle slip?
    if sEpoch.iEpoch > 3
        diff = sAlgo.scnext(1)-mwcomb(1);
        if diff > 3*std(sAlgo.mwcomb(1,1:sEpoch.iEpoch-1)) || diff < -3*std(sAlgo.mwcomb(1,1:sEpoch.iEpoch-1))
            fprintf('cycle slip at %d\n',sEpoch.iEpoch);
                
            % Corrects with mean, but needs to be improved
            sAlgo.mwcomb(1,sEpoch.iEpoch) =  mean( sAlgo.mwcomb(1,sEpoch.iEpoch-1));
        else
            sAlgo.mwstd = std([sAlgo.mwstd, sAlgo.mwcomb(1,sEpoch.iEpoch)]);
        end
        hold on;
        plot(sEpoch.slipfig2,sEpoch.iEpoch,diff(1));
        plot(sEpoch.slipfig2,sEpoch.iEpoch,3*std(sAlgo.mwcomb(1,1:sEpoch.iEpoch-1)),'g');
        plot(sEpoch.slipfig2,sEpoch.iEpoch,-3*std(sAlgo.mwcomb(1,1:sEpoch.iEpoch-1)),'g');
        drawnow;
    else
         sAlgo.mwstd = std(sAlgo.mwcomb(1,1:sEpoch.iEpoch));
    end
    
%     % Compute the next value by fitting a quadratic curve
    if sEpoch.iEpoch == 1
        sAlgo.scnext=mwcomb;
    elseif sEpoch.iEpoch < 2
        for each=1:nSat
            [p,S,mu]             = polyfit(1:sEpoch.iEpoch,sAlgo.mwcomb(each,1:sEpoch.iEpoch),1);
            sAlgo.scnext(each,1) = polyval(p,sEpoch.iEpoch,S,mu);
        end
    else
       for each=1:nSat
           try
           [p,S,mu]             = polyfit(sEpoch.iEpoch-9:sEpoch.iEpoch,sAlgo.mwcomb(each,1:sEpoch.iEpoch),10);
           catch
               [p,S,mu]         = polyfit(1:sEpoch.iEpoch,sAlgo.mwcomb(each,1:sEpoch.iEpoch),2);
           end
            
            sAlgo.scnext(each,1) = polyval(p,sEpoch.iEpoch,S,mu);
       end 
    end
    
    
    
    plot(sEpoch.slipfig1,sEpoch.iEpoch,mwcomb(1,1),'b','MarkerSize',10);
    plot(sEpoch.slipfig1,sEpoch.iEpoch,sAlgo.scnext(1,1),'r','MarkerSize',10);
    plot(sEpoch.slipfig1,sEpoch.iEpoch,sAlgo.scnext(1,1)+3*std(sAlgo.mwcomb(1,1:sEpoch.iEpoch-1)),'g','MarkerSize',10);
    plot(sEpoch.slipfig1,sEpoch.iEpoch,sAlgo.scnext(1,1)-3*std(sAlgo.mwcomb(1,1:sEpoch.iEpoch-1)),'g','MarkerSize',10);

    
end