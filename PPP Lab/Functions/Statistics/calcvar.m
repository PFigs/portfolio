function var = calcvar(value,mean,var,k)
%CALCVAR computes the filtered variance
    
    valid   = (k > 0);
    if any(valid)
        value = value(valid);
        k     = k(valid);
        mean  = mean(valid);
        var(valid)  = (k-1)./k.*var(valid) + 1./k.*((value-mean).^2);
    end
    var(~valid) = 0;
end

