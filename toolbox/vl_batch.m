clc
close all
clear all

tic
%[filename,pathname,filterindex]=uigetfile({'*.png';'*.tiff';'*.jpg';'*.jpeg'},'Select image');
total_error=0;
main_folder = uigetdir
for k=1:5
    for i=1:9
        filename2=[main_folder '/two' num2str(k) '/2 Rosettes '];
        filename2=[filename2 num2str(k) '_t00' num2str(i) '_c002.png'];
        temp=double(imread(filename2));
    
        temp = medfilt2(temp,[3,3]);
        temp = temp-min(temp(:));
        z(:,:,k) = temp/max(temp(:));
    end

% for k = 1:9
%     filename2=fullfile(pathname,filename);
%     filename2=filename2(1:end-10);
%     filename2=[filename2 num2str(k) '_c002.png'];
%     temp=double(imread(filename2));
%     
%     temp = medfilt2(temp,[3,3]);
%     temp = temp-min(temp(:));
%    z(:,:,k) = temp/max(temp(:));
% end
% z has the normalized image
x = sum(z,3);
x = x/max(x(:));

% compressing the stack to one image and normalizing it
temp = mean(x,3);
temp = temp/max(temp(:));
hist_eq = hist(temp(:)/max(temp(:)),50);
z(:,:,9) = temp;

[r_z c_z]=size(z);
mask=zeros(r_z);mask_temp=zeros(r_z);

new_M = zeros(r_z);flag=0;
for j = 1:9
   z1 = histeq(z(:,:,j),hist_eq)*255;
   z5 = conv2(z1,fspecial('gaussian',[20,20],1),'same');
   % Area specified as RegionArea/ImageArea
   [r,f] = vl_mser(uint8(z5),'MinArea',0.004,'MaxArea',0.02);%,'BrightOnDark',1);
   f = vl_ertr(f);
   vl_plotframe(f);

   M = zeros(size(z5));
   for y=r'
       s = vl_erfill(uint8(z5),y);
       if (j>2) && (j<6) 
       M(s) = M(s) + 2;
       else
       M(s) = M(s) + 1;
       end
   end
  
new_M = new_M+M;
figure;%%1
clf; imagesc(z5); hold on; axis equal off; colormap gray;title('Original Image stack');
[c,h]=contour(M,(0:max(M(:))));
set(h,'color','y','linewidth',1) ;
end
close all;

figure;imshow(new_M);title('Detected Regions');%%2

[r_M c_M] = size(new_M);
for i=1:r_M
    for j=1:c_M
        if new_M(i,j)<6   %if detected less than 7 times, eliminate that region 
           new_M(i,j)=logical(0);  %and force its pixel value as zero
        end
    end
end

figure;%%3
imshow(new_M);title('Detected Regions after voting');

 se=strel('disk',5);
 new_M=logical(new_M);mask2=new_M;
 figure;%%4
 for i=1:4
    mask2=imdilate(mask2,se);imshow(mask2);title('Erosion+Dilation');pause(0.1);
 end
 for(i=1:4)
    mask2=imerode(mask2,se);pause(0.1);
 end

mask2=imfill(mask2,'holes');

cc = bwconncomp(mask2);
stats = regionprops(cc, 'Area');
idx = find([stats.Area] > 1150);
BW2 = ismember(labelmatrix(cc), idx);
figure; imshow (BW2);
ros_temp = cc.NumObjects

%calculate mse
error_in_count = (abs(2-ros_temp))^2;
total_error = total_error+error_in_count;

mask=new_M;figure;imshow(mask);title('Input to fibre detection');%%5

% %ctFIRE;
% 
% [s1Image,s2Image]=size(new_M);%default
%     % boundary contains two columns of x and y coordinates of all bnd points
%     B=bwboundaries(mask);
%     mask2=mask;
%     for k2 = 1:length(B),
%         kip = B{k2};
%         boundaryCell{k2}=kip;
%     end
    
%     imgPath=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
%     imwrite(x,imgPath);
%     imshow(imread(imgPath));title('Input to Fiber detection process');hold on;
    
end
mse_total = sqrt(total_error/k);
avg_ros_cnt = 2 - mse_total;
toc