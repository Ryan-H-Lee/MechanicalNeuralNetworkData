startcolor=[1 0 0];                     %High compression force
endcolor=[0 1 0];                    %High tension
midcolor=(startcolor+endcolor)/2;   %Low Force

mymap2=zeros(Ncolorstep*2,3);
d1=(midcolor-startcolor)/Ncolorstep;
d2=(endcolor-midcolor)/Ncolorstep;
for i=1:2*Ncolorstep+1
    if i==1
        mymap2(1,:)=startcolor;
    elseif i<Ncolorstep+1
        mymap2(i,:)=mymap2(i-1,:)+d1;
    elseif i==Ncolorstep+1
        mymap2(i,:)=midcolor;
    elseif i<2*Ncolorstep+1
        mymap2(i,:)=mymap2(i-1,:)+d2;
    elseif i==2*Ncolorstep+1
        mymap2(i,:)=endcolor;
    else
        warning('something went wrong in the colormap')
        return
    end
end
% Load file with error plot
totalfile= 'total2D.mat';
if exist(totalfile,'file') == 2
    load(totalfile,'Errorplot');
    done=sum(any(Errorplot,2));
    %Errsize=size(Errorplot(:,1));
else
    Errorplot=zeros(endI,2);
    done=0;
end