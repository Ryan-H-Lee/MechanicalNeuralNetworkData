function coorddeformed=FEM_NG(x, sysPar)

Ncoord = size(sysPar.coord_initial,1);
K=zeros(sysPar.DOF);
k=zeros(2*sysPar.DOI,2*sysPar.DOI,sysPar.Nbeams);
Ncases = size(sysPar.F,2);
Degrees_per_element =  sysPar.Degrees_per_element;
R6 = sysPar.R6;
RT6 = sysPar.RT6;
for e=1:sysPar.Nbeams
    %scale the stiffnes accoding to x
    k(:,:,e)=sysPar.k_base(:,:,e)*diag([x(e) 1 1 x(e) 1 1]); % USE mtimesx?
    %Combine stiffness matrix for solving
    K(Degrees_per_element(e,:),Degrees_per_element(e,:))= ...
        K(Degrees_per_element(e,:),Degrees_per_element(e,:))+ RT6(:,:,e)*k(:,:,e)*R6(:,:,e);
end
Kinv=K(sysPar.Final,sysPar.Final)^-1; %invert the stiffness Matrix
U=zeros(sysPar.DOFFinal,Ncases);
U2=zeros(Ncoord,sysPar.DOI,Ncases); %Translation only interesting
coorddeformed=zeros(Ncoord,sysPar.DOI,Ncases);
for j=1:Ncases
    U(:,j)=Kinv*sysPar.F(sysPar.Final,j);
    i2=1;
    for i=sysPar.DOFnodes %loop through the nodes that are not fixed
        U2(i,:,j)=transpose( U(sysPar.DOI*(i2-1)+1:sysPar.DOI*(i2-1)+sysPar.DOI,j) );
        i2=i2+1;
    end
    coorddeformed(:,:,j)=sysPar.coord_initial + U2(:,:,j);
end
end
