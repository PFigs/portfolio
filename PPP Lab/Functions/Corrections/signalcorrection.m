function dr = signalcorrection(userxyz,satxyz)

    if size(satxyz,1)~=size(userxyz)
        userxyz  = repmat(userxyz,size(satxyz,1),1);
    end

    c       = gpsparams('c');
    miu     = gpsparams('miu');
    
    vec   = satxyz - userxyz;
    rs    = sqrt(sum(vec.^2,2));
    r     = sqrt(sum(userxyz.^2,2));
    s     = sqrt(sum(satxyz.^2,2));
    
    dr      = 2*miu/c^2*log((s+r+rs)./(s+r-rs));

end