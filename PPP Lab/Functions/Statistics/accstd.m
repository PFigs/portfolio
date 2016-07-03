function sdev = accstd( Xi, Xsum, Xsquare, N)
%CUMSTD computes the equivalent accumulated standard deviation
%
%   INPUT
%     Xi      - The current value/sample
%     Xsquare - The accumulate square sum ( x1^2 + x2^2 + ... + xN-1^2) 
%     Xsum    - The accumulate sum (x1+x2+...+xN-1)
%     N       - Number of samples
%
%   OUTPUT
%     STD     - Standard deviation (equal to MATLAB's std)    
%
% REFERENCE: http://www.westgard.com/lesson34.htm

    % Error proof
    valid   = (N > 1);
    Xi      = Xi(valid);
    Xsquare = Xsquare(valid);
    Xsum    = Xsum(valid);
    N       = N(valid);

    if any(valid)
        sdev(valid) = sqrt(abs(N.*(Xsquare+Xi.^2) - (Xsum+Xi).^2)./(N.*(N-1))); %This improves accuracy
    end
    sdev(~valid) = 0;     

    %SANITY CHECK
    if ~isreal(sdev)
       error('PPPLAB:STATISTICS:ACCSTD','Got an imaginary number. Nice work champ!'); 
    end
    
end