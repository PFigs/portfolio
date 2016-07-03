function values = npolyfit( N, D, Y, PolyDeg, Sample )
%NPOLYFIT wrapper to run polyfit N times
%
%   INPUT
%     N - Number of inputs (times polyfit will run)
%     D - Number of samples
%     Y - Data to fit
%     P - Degree of the polynomial
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012

    values = zeros(N,1);
    for K = 1:N
        samples  = Y(K, ~isnan(Y(K,:)));
        nsamples = length(samples);
        if nsamples > 2
            [P,S,MU]  = polyfit(1:D(K),samples,PolyDeg); 
            values(K) = polyval(P,Sample(K),S,MU);
        elseif nsamples == 2
            [P,S,MU]  = polyfit(1:D(K),samples,1); 
            values(K) = polyval(P,Sample(K),S,MU);
        else
            values(K) = samples;
        end
    end
    

end