function [rowList, colList, zMatrix] = removeInf(input)
[ii, jj] = find(~isinf(input)|isnan(input));
colList = unique(jj);
rowList = unique(ii);
zMatrix = input(rowList,colList);
end