function [coord_deformed,error, c]=DEFandERROR(x)
global Target Outputline coord_initial Elongation_max L1 F connectivity
nCases = size(Target,3);
nIO = size(Target,1);
coord_deformed=FEM(x);
abserror=zeros(nIO*nCases,1);
% for i=1:nCases  
%     abserror((i-1)*NinputANDoutput+(1:NinputANDoutput))=sqrt(sum((1000*coord_deformed(Outputline(1:NinputANDoutput),[1 2],i)-1000*Target(1:NinputANDoutput,[1 2],i)).^2,2)); 
% end
% error=sum(abserror.^2)/(NinputANDoutput*nCases);
xa=(coord_deformed(Outputline,1:2,:) - coord_initial(Outputline,1:2));
xt = (Target - coord_initial(Outputline,1:2));
vectLength = numel(xt);
xar = zeros([vectLength,1]);
atr = zeros([vectLength,1]);
xar = reshape(xa,[vectLength,1]);
xtr = reshape(xt,[vectLength,1]);
c = sum(xar'*xtr)/sum(xar.^2);
cMax = getCLimit(coord_deformed,connectivity, L1, Elongation_max, 1);
if abs(c) > cMax
    c = sign(c)*cMax;
end
abserror=zeros(nIO*nCases,1);

for i=1:nCases  
    abserror((i-1)*nIO+(1:nIO))=...
        ((sum((xa(:,:,i)*1000*c-1000*xt(:,:,i)).^2,2))); 
end
error=(sum(abserror))/(nIO*nCases);
%[Felement,~]=truss_stress(coord_deformed,x);
end