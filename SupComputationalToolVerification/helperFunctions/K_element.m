function [K_elem,axF]=K_element
%% Construct stiffness matrix 2D
% axial direction = x
% perpendicular = y
% Moment = rotz
rad=360/(2*pi);

% Force acting axial
Fx=1;                   % N
ux1=0.12777e-3;         % m 
%Erwin's Values
Fx=1;                   % N
ux1=0.12777e-3;         % m
k44=Fx/ux1;             % N/m
%My Values
k44 = 1;%1911.11339; %N/m

% Force acting perpendicular while rotation is fixed: utcross=0;
Fycross = .01;% N
uycross = 4.1704e-4;      % m
uycross = 2.3859e-3;      % m original 
%erwin's Values
Fycross=1;              % N
uycross=2.3859e-3;      % m
k55 = Fycross/uycross;    % N/m
%My New values
k55 = 237.1; %N/m

% Force acting perpendicular with rotation of tip allowed
Fy = .01;                   % N
uy2 = 1.61e-2;          % m original
ut2 = .0011535;         % rad
%Erwin's Values
Fy=1;                   % N
uy2=6.4834e-3;          % m
ut2=3.5578/rad;         % rad
k56 = (Fy-k55*uy2)/ut2;   % N/rad
%My New Value
k56 = 2.11; %N/rad

% Moment acting on end while perpendicular translation of tip is allowed 
M = .1;                    % N*m                
uy3 = 1.0952e-3;             % m
ut3 = 9.8725e-4;         % rad
%Erwin's Values 
M=1;                    % N*m                
uy3=68.168;             % m
ut3=59.179/rad;         % rad
k66 = (M-k56*uy3)/ut3;    % N*m/rad
%My New Value
k66 = 25.3; %N*m/rad

% Total stiffness matrix
K_elem=[ k44    0     0 -k44    0     0;
           0  k55   k56    0 -k55  k56;
           0  k56   k66    0 -k56 k66/2;
        -k44    0     0  k44    0     0;
           0 -k55  -k56    0  k55  -k56;
           0  k56 k66/2    0 -k56   k66;];
       
axF=k44;
end