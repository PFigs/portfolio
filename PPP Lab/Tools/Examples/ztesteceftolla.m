% TESTECEFTOLLA script serves as a debug tool for the fuction xyztolla.

%   INPUT : xyz = [4910384.3, -821478.6, 3973549.6];
%   OUTPUT: lla = [38.7819058,-9.4972995,123.419578];

%   INPUT : xyz = [-775858.6194, -4903039.9874, 3991748.6190];
%   OUTPUT: lla = [38.9919444404708, -98.9919444415693, 201.25296203699];

%   INPUT : xyz = [775858.6194, 4903039.9874, 3991748.6190];
%   OUTPUT: lla = [ 38.9919444404708, 81.0080555584307, 201.25296203699];     

%   INPUT : xyz = [6910384.3, -321478.6, 2973549.6];
%   OUTPUT: lla = [23.3782065130189, -2.66354165117237, 1155066.86228785];

% Pedro Silva, Instituto Superior Técnico, November 2011

clc
clear
disp('ECEF - LLA CONVERSION TESTING SCRIPT');

% OPERATION MODE
mode = 'deg';

% EVALUATION POINTS IN METERS
xyz = [
        4910384.3  , -821478.6    , 3973549.6;
       -775858.6194, -4903039.9874, 3991748.6190;
       775858.6194 , 4903039.9874 , 3991748.6190;
        6910384.3  , -321478.6    , 2973549.6;
       ];

% MATLAB SOLUTION
tic
dbg = ecef2lla(xyz);
toc
% USER SOLUTION

if strcmp(mode,'rad')
    lla = eceftolla(xyz,mode);  
    lla = [deg(lla(:,1)),deg(lla(:,2)),lla(:,3)];
else
    tic
    lla = eceftolla(xyz); %DEFAULT SOLUTION   
    toc
end


disp('LLA SOLUTION');
disp(lla);
disp('COMPARISON WITH MATLAB SOLUTION');
disp(dbg-lla)



