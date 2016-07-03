% TESTLLATOECEF script serves as a debug tool for the fuction xyztolla.

%   INPUT : xyz = [4910384.3, -821478.6, 3973549.6];
%   OUTPUT: lla = [38.7819058,-9.4972995,123.419578];

%   INPUT : xyz = [-775858.6194, -4903039.9874, 3991748.6190];
%   OUTPUT: lla = [38.9919444404708, -98.9919444415693, 201.25296203699];

%   INPUT : xyz = [775858.6194, 4903039.9874, 3991748.6190];
%   OUTPUT: lla = [38.9919444404708, 81.0080555584307, 201.25296203699];     

%   INPUT : xyz = [6910384.3, -321478.6, 2973549.6];
%   OUTPUT: lla = [23.3782065130189, -2.66354165117237, 1155066.86228785];

% Pedro Silva, Instituto Superior Técnico, November 2011

clc
clear
disp('LLA - ECEF CONVERSION TESTING SCRIPT');

% OPERATION MODE
mode = 'deg';

% % EVALUATION POINTS IN DEGREES: ALWAYS NEEDED FOR MATLAB
lla = [
        38.7819058, - 9.4972995 , 123.419578;
        38.9919444, -98.9919444 , 201.252962;
        38.9919444,  81.0080555 , 201.252962;
        23.3782065, - 2.6635416, 1155066.862287
       ];

% MATLAB SOLUTION
dbg = lla2ecef(lla);

% USER SOLUTION
tic
if strcmp(mode,'rad')
    lla = [rad(lla(:,1)),rad(lla(:,2)),lla(:,3)];
    xyz = llatoecef(lla,mode); 
else
    xyz = llatoecef(lla);   % DEFAULT SOLUTION
end
toc

disp('ECEF SOLUTION');
disp(xyz);
disp('COMPARISON WITH MATLAB SOLUTION');
disp(dbg-xyz)




