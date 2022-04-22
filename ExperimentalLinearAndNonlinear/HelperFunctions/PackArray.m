
function arryOut = PackArray(cellIn)
    currentSize = cell2mat(cellfun(@size, cellIn, 'UniformOutput', false));
    nBox = length(cellIn);
    temp = max(currentSize);
    maxLength = temp(1);
    maxDepth = temp(2);
    nAdd = maxLength - currentSize(:,1);

    arryOut = NaN( nBox, maxLength, maxDepth);

    for ind = 1:length(cellIn)
        tempArray = cellIn{ind};
        tempArray = [tempArray; repmat(tempArray(end,:),nAdd(ind),1)];
        arryOut(ind, :, 1:size(tempArray,2)) = tempArray;
    end
 end
 