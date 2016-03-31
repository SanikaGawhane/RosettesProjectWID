%im = imread('twenty.png');
%im = rgb2gray(im);
[Gx, Gy] = imgradientxy(im);
%[Gmag, Gdir] = imgradient(Gx, Gy);
[rg,cg]=size(im);
cnt=0;
gdir=zeros(rg,cg);
Sum2=0;absSum=0;
ang_matrix=0;
for i=1:rg
    for j=1:cg
        angle2=atan(Gy(i,j)/Gx(i,j));
        ang_matrix(i,j)=angle2*180/pi;
        if(~isnan(angle2))
           Sum2=Sum2+angle2;
           absSum=absSum+abs(angle2);
           cnt=cnt+1;
        end
    end
    display(i);
end
angle2=0;
if(cnt~=0)
    %angle2=90-sign(Sum2)*absSum/cnt*180/pi;
    angle2=90-absSum/cnt*180/pi;
end
display(angle2);
% gdir=gdir*180/pi;
% sum_gdir=sum(sum(gdir));
% theta = sum_gdir/cnt;
% % figure; imshowpair(Gmag, Gdir, 'montage'); axis off;
% % title('Gradient Magnitude, Gmag (left), and Gradient Direction, Gdir (right), using Sobel method')
% figure; imshowpair(Gx, Gy, 'montage'); axis off;
% title('Directional Gradients, Gx and Gy, using Sobel method')

