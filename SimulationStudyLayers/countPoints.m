function [nPts, dataPts] = countPoints(dataCell, fetchValue)
if nargin < 2
    fetchValue = 6;
end
nPts = zeros(size(dataCell,1:4));
dataPts = inf(size(dataCell));
    for a = 1:size(dataCell,1)
        for b = 1:size(dataCell,2)
            for c = 1:size(dataCell,3)
                for d = 1:size(dataCell,4)
                    nPts(a,b,c,d) = sum( ~cellfun(@isempty, dataCell(a, b, c, d, :) ) );
                    for e = 1:size(dataCell,5)
                        if ~isempty(dataCell{a,b,c,d,e})
                            requestedValue = dataCell{a,b,c,d,e}{fetchValue};
                            dataPts(a,b,c,d,e) = requestedValue;
                    end
                end
            end
        end
    end
end