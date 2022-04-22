%this code takes a list of break points and break values and filles them in
%Step iter are the transition points indexed from 1
%yVals are the values at each transistion point
% numPts is the length of the final vector
function fullVector = fillStepVector( stepIter, yVals, numPts)
     if isempty(numPts)
         numPts = stepIter(end);
     end
%      if length(yVals) == 1
%          yVals(2) = yVals(1)
%      end
     
     stepIter = reshape(stepIter, [], 1);
     yVals(end + 1) = yVals(end);
     allInd = [0;stepIter; numPts];
     numEach = diff(allInd);
     fullVector = [];
     for seg = 1:length(numEach)
        %Always plot at least 1 point per segment
        segmentVals = ones(max(int64(numEach(seg)),1),1)*yVals(seg);
        fullVector = [fullVector; segmentVals];
     end
end
