function [ res ] = Roty( beta )
%ROTY Makes a rotation regarding y
%   Pedro Silva, Instituto Superior Tecnico, November 2011

    res = [ cos(beta)   0   sin(beta) ;
            0           1       0     ; 
            -sin(beta)  0   cos(beta)];

end

