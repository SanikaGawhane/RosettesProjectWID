function[angle2]=directionality(im)
[rg,cg]=size(im);
cnt=0;
gdir=zeros(rg,cg);
Sum2=0;absSum=0;
[Gx ,Gy]=imgradientxy(im);
for i=1:rg
    for j=1:cg
        angle2=atan(Gy(i,j)/Gx(i,j));
        if(~isnan(angle2))
           Sum2=Sum2+angle2;
           absSum=absSum+abs(angle2);
           cnt=cnt+1;
        end
    end
    %display(i);
end
angle2=0;
if(cnt~=0)
    angle2=90-sign(Sum2)*absSum/cnt*180/pi;
end
%display(angle2);
end