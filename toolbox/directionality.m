function[angle1]=directionality(im)
[rg,cg]=size(im);
cnt=0;
gdir=zeros(rg,cg);
Sum2=0;absSum=0;
[Gx ,Gy]=imgradientxy(im);
angle1=atan(Gy./Gx);
for i=1:rg
    for j=1:cg
        if(~isnan(angle1(i,j)))
           Sum2=Sum2+angle1(i,j);
           absSum=absSum+abs(angle1(i,j));
           cnt=cnt+1;
        end
    end
    %display(i);
end
angle1=0;
if(cnt~=0)
    angle1=90-sign(Sum2)*absSum/cnt*180/pi;
end
%display(angle2);
end