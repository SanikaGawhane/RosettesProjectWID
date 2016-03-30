
%savePath=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
%imwrite(uint8(255*temp),savePath);
s1=1024;s2=1024;
image=zeros(s1,s2);
blank=image;
xc=112;yc=512;r=100;
for i=1:s1
    for j=1:s2
        if((i-xc)^2+(j-yc)^2<=r*r)
           image(i,j)=1; 
        end
    end
end
B=bwboundaries(image);
B1=B{1};
figure;imagesc(image);colormap gray;hold on;
color1=[1,1,0];
plot(B1(:,2),B1(:,1),'LineStyle','-','color',color1,'linewidth',0.005);

x1=512;y1=512;x2=712;y2=512;

image2=zeros(size(image));


