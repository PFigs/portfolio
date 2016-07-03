function [satid,satidx] = getreferencesat( satelv )
%GETREFERENCESAT Summary of this function goes here
%   Detailed explanation goes here

    persistent numvec
    
    if isempty(numvec)
        numvec = 1: userparams('MAXSAT');
    end
    
    satid = numvec(satelv == max(satelv));

    satidx = satelv == max(satelv);
    
end

