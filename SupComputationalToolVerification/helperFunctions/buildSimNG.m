% clear all
NinputANDoutput = 2;
Nlayers         = 2;
Ncases          = 2;
seed            = 1;
caseType        = 1;
latticeType     = 1;%1='triangular', 2='square'
latticeMenu     = [1];

L1              =.1524;%90.17; %0.12;            %Length of beams
L2              =L1*cosd(60);     %X-component of beam under 60 degrees / 1/3 pi rad
L3              =L1*cosd(30);     %Y-component of beam under 60 degrees / 1/3 pi rad
minStiffness    = -2e3;
maxStiffness    = 4e3;

maxForce        = 1; %N
Elongation_max  = 2.5e-3;

Ncolorstep      =20;
Plot_exaggerate =60;
Plot.initial    =true; %show initial Plot
Plot.init_wF    =false; 
Plot.firstload  =false;%show plot of displacement with starting stiffness
Plot.end        =true;%show plot at end of optimization
displayStatus   =false;
Plot_cmap       =true;

bounds          =0; %Set bounds
gridMenu = {'triangle', 'square'};

try
    gpuDevice;
    hasGPU = true;
catch
    hasGPU = false;
end
%%

DOI = 3;
Ncoord = NinputANDoutput+Nlayers+2*NinputANDoutput*Nlayers;
[Ncoord, coord_initial, connectivity, bound,inputNodes,outputNodes] = triangleLatticeFunction...
               (NinputANDoutput,Nlayers,DOI,L1);
Nbeams = size(connectivity,1);
Lend=zeros(Ncases*Nbeams,1);

 % INPUT & OUTPUT
Outputline = outputNodes;
dx = Elongation_max;

rng(seed)
switch caseType
   case 1
      [Target, ~, forces, ~, graphArrows, xyForces] = ...
       pushShearSinWaveFunction(inputNodes, outputNodes, Ncases, Nlayers, Ncoord, Elongation_max/3, DOI, coord_initial,maxForce);
   case 2
           [Target, forces, graphArrows, xyForces] =...
               randomCaseFunction(inputNodes, outputNodes, Ncases,coord_initial,Elongation_max/3, maxForce,threshold);      
               firstRun = false;
   otherwise
       caseType = input('Invalid Type. Please enter "sinWaves" or "random"');
end
%% FEM section
k=1;
Nnodes=size(coord_initial,1);
Nbeams=length(connectivity(:,1));
%delta=zeros(1+Nloops,Nbeams);
DOF=DOI*Nnodes; %Total number of system DOF
F=zeros(DOF,Ncases);
Error=zeros(3,1); %Error xyz
abserror=zeros(NinputANDoutput*Ncases,1); %normalized error for each output and case
%This sets the initial eror for each case
for i=1:Ncases
    abserror((i-1)*NinputANDoutput+(1:NinputANDoutput))=sqrt(sum((coord_initial(Outputline(1:NinputANDoutput),[1 2],1)-Target(1:NinputANDoutput,[1 2],i)).^2,2));
end
%Error(1) holds the average of the mean square error before
%optimization
Error(1)=sum(abserror.^2)/(NinputANDoutput*2);
% Make Force Vector
for i=1:size(forces,1)
    for j=1:Ncases
        %Holds the 
        startIndex = (forces(i,1)-1)*DOI +1; %index from 1
        endIndex   =  startIndex + (DOI - 1); %To correct for index from 1
        F( startIndex:endIndex, j)=forces(i, 2:DOI+1, j); 
    end
end
Nfixed=length(bound);
prescribedDof=zeros(Nfixed,DOI);
for i=1:Nfixed
    prescribedDof(i,:)=(bound(i)-1)*DOI+1:(bound(i)-1)*DOI+DOI;
end
%X=coord_initial(:,1);Y=coord_initial(:,2);Z=coord_initial(:,3);
Final=setdiff(transpose(1:DOF),prescribedDof);
DOFFinal=length(Final);

 %% Never changing FEM values
pos1=coord_initial(connectivity(:,1),:,1); %xyz pos of link startPt
pos2=coord_initial(connectivity(:,2),:,1); %xyz pos of link endPt
Degrees_per_element=[DOI*connectivity(:,1)-2 DOI*connectivity(:,1)-1 DOI*connectivity(:,1) DOI*connectivity(:,2)-2 DOI*connectivity(:,2)-1 DOI*connectivity(:,2)] ;
RX = (pos2(:,1)-pos1(:,1))/L1;
RYX = (pos2(:,2)-pos1(:,2))/L1;
RZX = (pos2(:,3)-pos1(:,3))/L1;
D = sqrt(RX.*RX + RYX.*RYX);
RXy = -RYX./D;
RY = RX./D;
RZY = zeros(Nbeams,1);
RXz = -RX.*RZX./D;
RYz = -RYX.*RZX./D;
RZ = D;
mat2=zeros(3,3,Nbeams);
R12=zeros(12,12,Nbeams);
for i=1:Nbeams
    mat2(:,:,i) = [RX(i) RYX(i) RZX(i) ;RXy(i) RY(i) RZY(i) ;RXz(i) RYz(i) RZ(i)];
    R12(:,:,i) = [mat2(:,:,i) zeros(3,9); zeros(3) mat2(:,:,i) zeros(3,6);
        zeros(3,6) mat2(:,:,i) zeros(3);zeros(3,9) mat2(:,:,i)];
end
Relevant_R=[1 2 6 7 8 12];%Pulls off values that participate
R6=R12(Relevant_R, Relevant_R,:);
RT6=permute(R6,[2 1 3]);         %Rotation Matrix 3D
DOFnodes=setdiff(1:Nnodes,bound);
k_base=zeros(6,6,Nbeams);
for i=1:Nbeams
    [k_base(:,:,i),~]=K_element;    %Stiffness matrix?
end
[~,Kaxial]=K_element;
outputLinks = [2, 3, 6, 4, 20, 19, 21, 17];
%Transfer the old globals into sysPar and 
makeColorMap
saveGlobalsIntoStructs
eFun = @(x) ERROR_NG(x, sysPar);
dandeFun = @(x) DEFandERROR_NG(x, sysPar);
femFun = @(x) FEM_NG(x, sysPar);
