function holderOut = stackData( dataIn, holderIn)
    dataVect = reshape(dataIn, [], 1);
    if isempty(holderIn)
        holderOut = dataVect;
    else
        numIn = length(dataVect);
        numHold = size(holderIn,1);
        if numIn > numHold
            numNew = numIn - numHold;
            newRows = repmat(holderIn(end,:), numNew, 1);
            holderIn = [holderIn; newRows];
        elseif numHold > numIn
            numNew = numHold - numIn;
            dataVect = [dataVect; ones(numNew,1)*dataVect(end)];
        end
        holderOut = [holderIn, dataVect];
    end
end
        