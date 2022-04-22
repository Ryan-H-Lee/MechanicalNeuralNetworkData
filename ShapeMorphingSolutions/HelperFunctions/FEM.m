function coorddeformed=FEM(x)
global Nbeams DOFnodes   DOFFinal F k_base R6 RT6 coord_initial DOF DOI Degrees_per_element Final
Ncoord = size(coord_initial,1);
K=(zeros(DOF));
k=(zeros(2*DOI,2*DOI,Nbeams));
Ncases = size(F,2);
for e=1:Nbeams
    %scale the stiffnes accoding to x
    k(:,:,e)=k_base(:,:,e)*diag([x(e) 1 1 x(e) 1 1]); % USE mtimesx?
    %Combine stiffness matrix for solving
    K(Degrees_per_element(e,:),Degrees_per_element(e,:))=K(Degrees_per_element(e,:),Degrees_per_element(e,:))+RT6(:,:,e)*k(:,:,e)*R6(:,:,e);
end
Kinv=K(Final,Final)^-1; %invert the stiffness Matrix
U=(zeros(DOFFinal,Ncases));
U2=(zeros(Ncoord,DOI,Ncases)); %Translation only interesting
coorddeformed=zeros(Ncoord,DOI,Ncases);
for j=1:Ncases
    U(:,j)=Kinv*F(Final,j);
    i2=1;
    for i=DOFnodes %loop through the nodes that are not fixed
        U2(i,:,j)=transpose(U(DOI*(i2-1)+1:DOI*(i2-1)+DOI,j));
        i2=i2+1;
    end
    coorddeformed(:,:,j)=coord_initial+U2(:,:,j);
end
end
