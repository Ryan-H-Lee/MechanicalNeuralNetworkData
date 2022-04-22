function cMax = getCLimit(coordDeformed, conMatrix, lResting, elongationMax, forceIn)
coordLengths = coordDeformed(conMatrix(:,1),:,:)-coordDeformed(conMatrix(:,2),:,:);
linkLengths = sqrt(sum(coordLengths.^2,2));
elongation = (linkLengths - lResting);
maxE = max(abs(elongation), [], 'all');
cMax = forceIn*elongationMax/maxE;
end