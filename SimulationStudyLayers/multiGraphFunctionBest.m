% dataCell{NinputANDoutput, Nlayers, latticeType, Ncases, trial}
% checkType = which lattice types to look at?
function [graphCells, zHeight] = multiGraphFunctionBest(dataCell,checkType,layerArray,caseArray)
validOnly = false;
invalidFags = [-2,-1];
maxIO = size(dataCell,1);
maxLayers = size(dataCell,2);
maxTypes = size(dataCell,3);
maxCases = size(dataCell,4);
maxTrials = size(dataCell,5);
if nargin < 3
    layerArray = 1:maxLayers;
end
 if nargin < 2 %if no type then check all of them
     checkType = [1:maxTypes];
 end
 if nargin < 4 %if the layers used isn't specified check all of them
     caseArray = 1:maxCases;
 end
graphCells = cell(maxIO, maxTypes);
plotData = zeros(maxCases*maxLayers, 3);
zHeight = inf(maxCases,maxLayers,length(checkType));
dHeight = zHeight;
%unpack data into arrays in plotData
    for nIO = 1:maxIO
        for type = checkType
            cnt = 1;
            for nLayers = layerArray
                for nCases = caseArray
                    bestEVal = inf;
                    bestDVal = inf;
                    for trial = 1:maxTrials
                        if size(dataCell,3) >= type
                            caseCell = dataCell{nIO,nLayers,type,nCases,trial};               
                            if ~isempty(caseCell)
                                [grid, target, forces, bentGrid, x, eVal, outputNodes, exitFlag, optOut]...
                                    = caseCell{1:9};     
                                dVal = sqrt(eVal*nCases*nIO)/(nCases*nIO);
                                if exitFlag ~= -2 || ~validOnly
                                    if eVal < bestEVal

                                        bestEVal = eVal;
                                    end
                                    if dVal < bestDVal
                                        bestDVal = dVal;
                                    end
                                end
                            end%end isempty
                        end
                    end %TRIAL sweep

                    plotData(cnt,1:3) = [nCases, nLayers bestEVal];
                    zHeight(nCases,nLayers,type) = bestEVal;
                    dHeight(nCases,nLayers,type) = bestDVal;
                    cnt = cnt + 1;
                end %CASE sweep
            end %LAYER sweep
            graphCells{nIO,type} = plotData;

            for i = 1:maxLayers
                index = find(zHeight(:,i) ~=inf);
                if ~isempty(index)
                fNum = nIO*10^4 + type + 1*100;
                figure(fNum);
                clf
                legendText = ' layers';
                hold on
                caseList = 1:maxCases;
                plot(caseList(index),zHeight(index,i),'-o');
                xlabel('Number of behaviors')
                ylabel('Mean squared error') 

%                 plot(caseList(index),dHeight(index,i),'-o');
%                 xlabel('Number of behaviors')
%                 ylabel('Mean distance (mm)') 
                end
            end
            for i = 1:maxCases
                index = find(zHeight(i,:) ~=inf);
                if ~isempty(index)
                    layerList = 1:maxLayers;
                end
            end

            [ii, jj] = find(~isinf(zHeight));
            if ~isempty(ii)
                layerVect = unique(jj);
                caseVect = unique(ii);
                zHeightSlim = zHeight(caseVect,layerVect);
                dHeightSlim = dHeight(caseVect,layerVect);
                fNum = nIO*10^4 + type + 2*100;
                figure(fNum)
                hold on
                if length(layerVect) ==1
                    plot(caseVect, zHeightSlim)
                elseif length(caseVect) == 1
                    plot(layerVect, zHeightSlim)
                else
                    surf(layerVect,caseVect,zHeightSlim);
                    ylabel('Number of behaviors')
                    xlabel('Number of layers')
                    zlabel('Mean squared error')
                    xlim([min(layerVect),max(layerVect)]);
                    ylim([min(caseVect),max(caseVect)]);
                    view(45,45)
                end
            end
           
        end %type sweep
    end %IO sweep

end %FUNCTION END