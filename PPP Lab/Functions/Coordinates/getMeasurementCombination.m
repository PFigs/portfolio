function [code,phase,extra] = getMeasurementCombination(mode,ranges)

    lbdf1   = gpsparams('lbdf1');
    lbdf2   = gpsparams('lbdf2');
    gama    = gpsparams('gama');   

    if strcmpi('graphic',mode)
        code  = 0.5.*(ranges.PRL1+ranges.PRL1);
        extra = 0.5.*(ranges.PRL2+ranges.PRL2);
        phase =(lbdf2.*ranges.CPL2 - gama.*lbdf1.*ranges.CPL1)./(1-gama);
    elseif strcmpi('iono',mode)
        code  = (ranges.PRL2 - gama.*ranges.PRL1)./(1-gama);
        phase = (lbdf2.*ranges.CPL2 - gama.*lbdf1.*ranges.CPL1)./(1-gama);
    else

    end

end



%     phase   = (lbdf2*sAlgo.ranges.CPL2 - gama*lbdf1*sAlgo.ranges.CPL1)./(1-gama);
%     combL1  = 0.5.*(sAlgo.ranges.PRL1 + sAlgo.ranges.CPL1);
%     combL2  = 0.5.*(sAlgo.ranges.PRL2 + sAlgo.ranges.CPL2);
%     % Create combinations
%     if n == 1
%         smrangesL1(:,n) = combL1 + phase;
%         smrangesL2(:,n) = combL2 + phase;
%     else
%         smrangesL1(:,n) = 1/2.*combL1 + (1-1/2).*(sAlgo.smrangesL1(:,n-1)...
%                       + phase - sAlgo.phase(:,n-1));
%         
%         smrangesL2(:,n) = 1/2.*combL2 + (1-1/2).*(sAlgo.smrangesL2(:,n-1)...
%                       + phase - sAlgo.phase(:,n-1));                  
%     end
%     
%     sAlgo.smrangesL1(:,n) = smrangesL1(:,n);
%     sAlgo.smrangesL2(:,n) = smrangesL2(:,n);
%     sAlgo.phase(:,n)      = phase;
%     sAlgo.stdL1(sats,4) = sAlgo.stdL1(4) + 1;
%     sAlgo.stdL1(sats,1) = accstd(combL1, sAlgo.stdL1(sats,2), ...
%                      sAlgo.stdL1(sats,3), sAlgo.stdL1(sats,4));
%     sAlgo.stdL1(sats,2) = sAlgo.stdL1(2) + combL1;
%     sAlgo.stdL1(sats,3) = sAlgo.stdL1(3) + combL1.^2;
%    
%     sAlgo.stdL2(sats,4) = sAlgo.stdL2(4) + 1;
%     sAlgo.stdL2(sats,1) = accstd(combL2, sAlgo.stdL2(sats,2), ...
%                      sAlgo.stdL2(sats,3), sAlgo.stdL2(sats,4));
%     sAlgo.stdL2(sats,2) = sAlgo.stdL2(2) + combL2;
%     sAlgo.stdL2(sats,3) = sAlgo.stdL2(3) + combL2.^2;
%     
%  
    