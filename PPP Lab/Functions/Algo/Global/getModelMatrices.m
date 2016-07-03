function [X,P,Q]    = getModelMatrices(sAlgo,nSat,sats,amb,nParams)
    
    P                              = zeros(nParams+nSat,nParams+nSat);
    Q                              = zeros(nParams+nSat,nParams+nSat);
    X                              = zeros(nParams+nSat,1);
    
    % Estimate
    X(1:4,1)                       = sAlgo.estimate{1};
    X(nParams+1:end,1)             = amb;
    P(1:nParams,1:nParams)         = sAlgo.covariance{1};
    P(nParams+1:end,nParams+1:end) = sAlgo.covariance{2}(sats,sats);
    Q(1:nParams,1:nParams)         = sAlgo.noise{1};
    Q(nParams+1:end,nParams+1:end) = sAlgo.noise{2}(sats,sats);
end
