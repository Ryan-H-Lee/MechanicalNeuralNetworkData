global Nlayers
%This function uses a data set from the layers vs behaviors  set and
%plots a few representative behaviors for illistruative purposes
addpath([pwd,'\HelperFunctions']); %Add plotting function to path
RunPlotFunction_InitialCondition; %Plot the basic geometry and add globals
connectivityIn = connectivity
addpath([pwd,'\HelperFunctions']); %Re add functions to path
%%
%Open the data set
uiload
%%
%Select a location on the set to plot data from
numCases = 10;
numLayers = 8;
outExaggerate = 250;
inExaggerate = .2;

thisCell = dataCell{8,8, 1, numCases, 1};
coord_initial = thisCell{1}
Target = thisCell{2}
forces = thisCell{3}
x = thisCell{5}
outputNodes = thisCell{7}
inputNodes = outputNodes - 8
Nbeams = length(x)

connectivity = connectivityIn
% ~~~~~~ Set arrow formatting ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clear form
form.Color = [1 0 0];
form.LineWidth = 4;
form.Marker = '.';
form.MarkerSize = 2;
%Pick the angles for the arrow barbs
AA = 25; 
% ~~~~~~~ Set formatting for target symbols ~~~~~~~~~~~~~~~~~~~~~~~
tf.Color = [1 0 0];
tf.LineStyle = 'none';
tf.LineWidth = 1.5;
tf.Marker = 'o'
tf.MarkerSize = 20;
targ = cell(2)
targ{1} = tf;
tf.Marker = '*'
targ{2} = tf;

%Plot each behavior
for behNum = 1:5
    figure(figNum + behNum);
    clf
    hold on
    mymap2 = repmat([0 0 1],100,1);
    
    %Calculate the magnitudes and angles of the forces
    pos = coord_initial(inputNodes, 1:2);
    df = forces(:,2:3,behNum);
    mag = sqrt(sum(df.^2,2))*inExaggerate;
    ang = squeeze(atan2(df(:,2), df(:,1)));


    %Calculate the magnitudes and directions of the Targets
    targPos = Target(:,:,behNum);
    deltaOut = coord_initial(outputNodes,1:2) - targPos;
    magOut = (sqrt(sum((deltaOut).^2,2)))*outExaggerate;
    angOut = (atan2( deltaOut(:,2), deltaOut(:,1)));
    %Calculate the Position of the target symbols;
    posTarg = coord_initial(outputNodes,1:2) + deltaOut*outExaggerate;
    dir = 1;

    %Plot the lattice
    Nlayers = 8;
    PlotFunctionFig(figNum + behNum, 'Initial Positions', coord_initial, ones(size(x))*4000/6,[],[],[],0)
    
    %Plot the force arrows
    inputArrow = plotArrow( pos,...
                            mag,...
                            ang,...
                            dir, form, AA);
    %Plot the arrows for the targets
    outputArrow = plotArrow( coord_initial(outputNodes,1:2),...
                                magOut,...
                                angOut,...
                                -dir, form, AA);
    %Plot the targets symbols for the targets
    targOut = plotStack(posTarg, targ, figNum +behNum)
%     ax = gca
%     ax.XLim = [-10,10];
%     ax.YLim = [-1, 10]
end
%
% 
% pos = [[1 2 3]',[1 1.5 2]'];
% tf.Color = [1 0 0];
% tf.LineStyle = 'none';
% tf.LineWidth = 1;
% tf.Marker = 'o'
% tf.MarkerSize = 10;
% form = cell{2}
% form{1} = tf;
% tf.Marker = '*'
% form{2} = tf;
% 
% targOut = plotStack(pos, form, 1)
% 
% tf.Marker = '.'
% plotArrow( [1, 1], 1, pi/6, 1, tf)
% plotArrow( [2, 1.5], 1, pi/6, 1, tf)
% mag = [1, 1.5, .5];
% ang = [10, 20, 30]*pi/180;
% dir = 1;
% clear form
% form.Color = [1 0 0];
% form.LineWidth = 5;
% form.Marker = '.';
% form.MarkerSize = 2;
% plotArrow( pos, mag, ang, dir, form)
% form.Color = [0 0 0];
% out = plotArrow( pos+[1,0], mag, ang, -dir, form,25)
% axis square
% axis equal

%% Plot function
% function fHandle = plotBehavior()
% % %Plot the lattice
% 
% PlotFunctionFig(figNum + 10, 'Initial Positions', coord_initial, ones(size(x))*4000/6,[],[],[],0)
%  
% % %Calculate the position to the targets
% % 
% % %Calculate the scaling on the arrows
% % 
% % end
% % 
% % function lHandle = plotLattice()
% % %Plot the 
% % end
% %
% end
 function aHandle = plotArrow(posIn, magIn, angIn, dir, form, aoff)

 numArrow = size(posIn,1);
 aHandle = cell(numArrow,1);
%set default values
 form = setDefaults(form);
%Arrow Ratio
ar = 0.5;
if nargin < 6
    aoff = 30;
end
shaft = zeros(0,2);
 for ind = 1:numArrow
     pos = posIn(ind,:);
     mag = magIn(ind);
     ang = angIn(ind);
     al =  ar*mean(magIn);
     %From the tip rotate by ang (in rad)
     rot = @(theta) [cos(theta), -sin(theta); sin(theta), cos(theta)];
     shaft(1,:) = pos;
     shaft(2,:) = (pos' + rot(ang)*[-mag*dir;0])';
     shaft(3,:) = shaft(1,:);
     if dir == 1
        endPt = shaft(1,:);
         phi = aoff*pi/180;
     else
        endPt = shaft(2,:);
         phi = pi-aoff*pi/180;
     end
    shaft(4:8,:) = [endPt;(endPt' + rot(ang - phi)*[-al*dir; 0])'; endPt; (endPt' + rot(ang + phi)*[-al*dir; 0])'; endPt];
     %Given a tip position 
     hold on
     aHandle{ind} = plot(shaft(:,1), shaft(:,2),...
         'Color',form.Color,...
         'LineWidth', form.LineWidth,...
         'Marker', form.Marker,...
         'MarkerSize', form.MarkerSize);
    %  plot(tip(:,1), tip(:,2))
 end
 end



function tHandle = plotStack(pos, form, figNum)
%Ensure iterable linestyle
if ~iscell(form)
    form = {form};
end

%Open required Figure
if nargin < 3
    figure;
else
    figure(figNum);
    hold on
end
%Set Default styles
form = setDefaults(form);

%Loope through and plot each data set
numStack = length(form);
for ind = 1:numStack
    %Exract values
    Color = form{ind}.Color;
    LineStyle = form{ind}.LineStyle;
    Marker = form{ind}.Marker;
    MarkerSize  = form{ind}.MarkerSize;
    LineWidth = form{ind}.LineWidth;
    %Plot data set
    hold on
    tHandle{ind} = plot(pos(:,1), pos(:,2), '*',...
        'Color', Color,...
        'MarkerSize', MarkerSize,...
        'LineStyle', LineStyle,...
        'LineWidth', LineWidth,...
        'Marker', Marker);
    hold on
end

end

function newCell = setDefaults(oldCell)
%Define Default Behavior
defaultColor = [0 0 0.3];
defaultStyle = '-';
defaultMarker = 'none';
defaultWidth = 0.5;
defaultMarkerSize = 2;
defaultCell = {defaultStyle, defaultMarker, defaultColor, defaultWidth, defaultMarkerSize};
fields = {'LineStyle','Marker','Color','LineWidth', 'MarkerSize'};  

%Set Default Behavior
%Handle single line case
if ~iscell(oldCell)
        thisStruct = oldCell;
        missingValues = find( ~isfield( thisStruct, fields));
        for ind = missingValues
            thisStruct.(fields{ind}) = defaultCell{ind};
        end
        newCell = thisStruct;
else
    newCell = cell(size(oldCell));
    numStack = length(oldCell);
    for lineNum = 1:numStack
        thisStruct = oldCell{lineNum};
        missingValues = find( ~isfield( thisStruct, fields));
        for ind = missingValues
            thisStruct.(fields{ind}) = defaultCell{ind};
        end
        newCell{lineNum} = thisStruct;
    end
end

end