function mean = calcmean(value,mean,k)
%CALCMEAN computes the filtered mean
    assert(all(k>0));
    assert(all(~isnan(k)))
    try
    mean = (k-1)./k.*mean + 1./k.*value; % From navipedia
    catch
        disp('oi')
    end
end


