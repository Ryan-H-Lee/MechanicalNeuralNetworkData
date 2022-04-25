[fileList,pathList] = uigetfile(  'MultiSelect','on');
if ~iscell(fileList)
    fileList = {fileList}
end
%Ask the user what number of IOs to start with
startIO = 1;
% startIO = 8;% input("How many inputs are in the first column of data")
%%
type = 1;
%Step through the files
 load([pathList,'\',fileList{1}])
holdCell = cell(size(dataCell));
for fileNum = 1:length(fileList)
    %open the data saved to the file
    load([pathList,'\',fileList{fileNum}]);
    %Loop through each
    for nIO = startIO:size(dataCell,1)
        for nLayers = 1:size(dataCell,2)
            for type = 1:size(dataCell,3)
                for cases = 1:size(dataCell,4)
                    for trial = 1:size(dataCell,5)
                        %extract data from the file
                        thisCell = dataCell{nIO,nLayers,type,cases,trial};
                        %Add bins if this is new type of data
                        if sum(size(holdCell) < [nIO,nLayers,type,cases,trial])
                            holdCell{nIO,nLayers,type,cases,trial} =[];
                        end
                        %if there is data Store it
                        if ~isempty(thisCell)
                            lastFullIndex = find(squeeze(~cellfun(@isempty,holdCell(nIO, nLayers, type, cases, :))),1,'last');
                            %If there is no data in this "condition" then
                            %fill the first cell otherwise place it behind
                            %the last filled data point
                            if isempty(lastFullIndex)
                                lastFullIndex = 0;
                            end
                            %Place data behind last trial
                            holdCell{nIO, nLayers, type, cases, lastFullIndex + 1} =...
                            thisCell;
                        end
                    end
                end
            end
        end
    end
end
%%
% [graphCell, zHeight] = multiGraphFunctionBest(holdCell)