function [ res ] = Rotz( gama )
%ROTZ Makes a rotation regarding z
%   Pedro Silva, Instituto Superior Tecnico, November 2011

    res = [ cos(gama) -sin(gama)  0 ;
            sin(gama)  cos(gama)  0 ; 
                0          0      1];

end

