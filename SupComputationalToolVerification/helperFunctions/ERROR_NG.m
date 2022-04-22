function error=ERROR_NG(x, sysPar)
% global Target Outputline NinputANDoutput connectivity Ncases coord_deformed coord_initial Elongation_max L1 F useGPU
% global Nbeams DOFnodes   DOFFinal k_base R6 RT6 DOF DOI Degrees_per_element Final
% persistent useGPU lastSize
% 
% %Check to see if you used the GPU 
% if lastSize ~= sysPar.Nbeams
%     
%     
% end

% if sysPar.hasGPU  
%     sysPar.coord_deformed=FEM_NG(x,  sysPar);
% else
   coord_deformed=FEM_NG(x, sysPar);
% end

%Calculate the scale factor of the force for optimal displacement
xa= coord_deformed(sysPar.Outputline,1:2,:) - repmat(sysPar.coord_initial(sysPar.Outputline,1:2), 1,1, sysPar.Ncases);
xt = (sysPar.Target - sysPar.coord_initial(sysPar.Outputline,1:2));
vectLength = numel(xt);
xar = zeros([vectLength,1]);
atr = zeros([vectLength,1]);
xar = reshape(xa,[vectLength,1]);
xtr = reshape(xt,[vectLength,1]);
c = sum(xar'*xtr)/sum(xar.^2);
cMax = getCLimit(coord_deformed,sysPar.connectivity, sysPar.L1, sysPar.Elongation_max, 1);
if abs(c) > cMax
    c = sign(c)*cMax;
end
   
if ~sysPar.forceScaling 
    c = 1;
end
abserror=zeros(sysPar.NinputANDoutput*sysPar.Ncases,1);

for i=1:sysPar.Ncases  
    abserror((i-1)*sysPar.NinputANDoutput+(1:sysPar.NinputANDoutput))=...
        ((sum((xa(:,:,i)*1000*c-1000*xt(:,:,i)).^2,2))); 
end
error=sum(abserror)/(sysPar.NinputANDoutput*sysPar.Ncases);
% error = sum((c*xa*1000-xt*1000).^2)/vectLength;
end