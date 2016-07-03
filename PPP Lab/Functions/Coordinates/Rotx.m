function [ res ] = Rotx( alpha )
%ROTX Makes a rotation regarding x
%   Pedro Silva, Instituto Superior Tecnico, November 2011

    res = [ 1      0          0;
            0 cos(alpha) -sin(alpha); 
            0 sin(alpha) cos(alpha)];
   
end

