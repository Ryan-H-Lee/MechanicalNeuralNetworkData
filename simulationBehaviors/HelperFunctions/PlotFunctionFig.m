function PlotFunctionFig(FigNumber,Title,coord,Stiffness,target,xforces,yforces,sinsign,c)
global L1 L2 L3 NinputANDoutput connectivity Nlayers mymap2 Ncolorstep DOI Kaxial dx coord_initial Plot_exaggerate Outputline Plot_cmap maxStiffness minStiffness
Nbeams = length(Stiffness);
% Nlayers = size(xforces,1);
if nargin <9
    c = 1;
end
beamThickness = 8.5;
groundThickness =18;
ballSize = 12;
ballOutline = 1.5;
starSize = 20;
starThickness = 3;
sinThickness = 6;
    
set(0, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
figname=sprintf(['C:/Users/Erwin/stack/07_ReseachInternship/Matlab Neural Network/figures/' 'IO%d_' 'Layer%d_' 'plot%d_' char(Title)], NinputANDoutput, Nlayers, FigNumber);
%figname=sprintf(['IO%d_' 'Layer%d_' 'plot%d_' char(Title)], NinputANDoutput, Nlayers, FigNumber);

figure(FigNumber)
%axis equal
dview=NinputANDoutput*L3+L2;
axis([Nlayers*L1/2-dview Nlayers*L1/2+dview NinputANDoutput*L3-dview NinputANDoutput*L3+dview]);
hold on
xlabel('meter')
ylabel('meter')
%zlabel('z [m]')
%title(Title)
%Plot Fixed Support
plot([0 L1*Nlayers],[0 0],'k','Linewidth',groundThickness)
plot([0 L1*Nlayers],[L3*2*NinputANDoutput L3*2*NinputANDoutput],'k','Linewidth',groundThickness)
%Plot Beams, WORKS FOR PLANAR ONLY
k = 3;
T = [zeros(1,k), 1:(k-2),(k-1)*ones(1,k)];

if size(Stiffness,1)~=0
    Stiffness_max=max(abs(2.3e3));
end

%Calculate place of coordinates when exaggerated
coord=(coord-coord_initial)*Plot_exaggerate*c+coord_initial;

for i=1:Nbeams
    L=sqrt((coord(connectivity(i,2),1)-coord(connectivity(i,1),1))^2+(coord(connectivity(i,2),2)-coord(connectivity(i,1),2))^2);%length of beams
    OV=coord(connectivity(i,2),1)-coord(connectivity(i,1),1); %dx of beam
    AN=coord(connectivity(i,2),2)-coord(connectivity(i,1),2); %dy of beam
    base_angle=pi/2-atan(OV/AN); 
    if AN>=0
        theta1=   base_angle+coord(connectivity(i,1),DOI);
        theta2=pi+base_angle+coord(connectivity(i,2),DOI);
    else
        theta1=pi+base_angle+coord(connectivity(i,1),DOI);
        theta2=   base_angle+coord(connectivity(i,2),DOI);
    end
    d = L/4;
    xy1 = [coord(connectivity(i,1),1) coord(connectivity(i,1),2)];
    p1  = [coord(connectivity(i,1),1) coord(connectivity(i,1),2)] + d*[cos(theta1), sin(theta1)];
    p2  = [coord(connectivity(i,2),1) coord(connectivity(i,2),2)] + d*[cos(theta2), sin(theta2)];
    xy2 = [coord(connectivity(i,2),1) coord(connectivity(i,2),2)];
    P=[xy1', p1', p2', xy2'];
    [M, ~] = bspline_deboor(k, T, P);
    % Plot the intermediate points:
    %     plot(p1(1), p1(2), 'bo');
    %     plot(p2(1), p2(2), 'bo');
    % Plot the curved beams:
    if size(Stiffness,1)~=0
        usecolor=round(((Stiffness(i) - minStiffness)/(maxStiffness - minStiffness)*(Ncolorstep)),0) + 1;
        if usecolor==0
            usecolor=1;  %THIS SHOULD BE EASIER
        end
        if usecolor > Ncolorstep
            usecolor = Ncolorstep;
        end
    else
        usecolor=Ncolorstep+1;
    end
    
    %Plot lines
    plot(M(1,:), M(2,:),'LineWidth',beamThickness,'color',mymap2(usecolor,:))
    
    %Plot dots on end and start of each beam (Could be faster if looped in i=1:Nnodes)
    plot(xy1(1), xy1(2), 'ko','MarkerSize',ballSize,'MarkerFaceColor',[1 1 1], 'LineWidth', ballOutline);
    plot(xy2(1), xy2(2), 'ko','MarkerSize',ballSize,'MarkerFaceColor',[1 1 1], 'LineWidth', ballOutline);
end
if Plot_cmap
    colormap(mymap2)
    h_color = colorbar;
    h_color_label = get(h_color,'Label');
    set(h_color_label,'String','Axial Stiffness N/mm')
    if sum(Stiffness)==Nbeams
        caxis([-Kaxial Kaxial])
    else
        caxis([-Kaxial*max(abs(Stiffness)) Kaxial*max(abs(Stiffness))])
    end
end
%clabel('Stiffness N/m');
Color2=[0 0 0];
%Plot Sin wave
if sinsign~=0
    sin_segments=500;
    t=transpose(0:2*pi/sin_segments:2*pi);
    sinY=NinputANDoutput*L3*t/pi;
    sinX=Plot_exaggerate*c.*sinsign.*dx.*sin(t)/2+Nlayers.*L1;
    plot(sinX,sinY,'color',Color2,'LineWidth',sinThickness)
end

%Plot Targets
if size(target,1)~=0
    %for i=1:NinputANDoutput
    target=(target-coord_initial(Outputline,[1 2]))*Plot_exaggerate*c+coord_initial(Outputline,[1 2]);
    plot(target(:,1),target(:,2),'*','color',Color2, 'MarkerSize',10,'LineWidth',2);
    
    % end
end

% Plot Force
if size(xforces,1)~=0
    for j=1:length(xforces(:,1))
        i=xforces(j,2);
        sig=sign(xforces(j,3));
        plot([coord(i,1) coord(i,1)-0.50*sig*L1],[coord(i,2) coord(i,2)]            ,'color',Color2,'Linewidth',2)
        plot([coord(i,1) coord(i,1)-0.25*sig*L1],[coord(i,2) coord(i,2)+0.25*sig*L1],'color',Color2,'Linewidth',2)
        plot([coord(i,1) coord(i,1)-0.25*sig*L1],[coord(i,2) coord(i,2)-0.25*sig*L1],'color',Color2,'Linewidth',2)
    end
end
if size(yforces,1)~=0
    for j=1:length(yforces(:,1))
        i=yforces(j,2);
        sig=sign(yforces(j,3));
        plot([coord(i,1) coord(i,1)]            ,[coord(i,2) coord(i,2)-0.50*sig*L1],'color',Color2,'Linewidth',2)
        plot([coord(i,1) coord(i,1)-0.25*sig*L1],[coord(i,2) coord(i,2)-0.25*sig*L1],'color',Color2,'Linewidth',2)
        plot([coord(i,1) coord(i,1)+0.25*sig*L1],[coord(i,2) coord(i,2)-0.25*sig*L1],'color',Color2,'Linewidth',2)
    end
end
axis equal
axis off
%Save images:
%export_fig(figname,'-png','-transparent') %-nocrop , ,'-pdf'
end