clc
close all
clear all

for k = 1:7
   %temp = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\Two Rosette\Two Rosettes 40X-1024pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
   temp = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\One Rosette\One Rosette 40X-1024pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
   temp = medfilt2(temp,[3,3]);
   temp = temp-min(temp(:));
   z(:,:,k) = temp/max(temp(:));
end
x = sum(z,3);
x = x/max(x(:));

temp = mean(z,3);
temp = temp/max(temp(:));
h = hist(temp(:)/max(temp(:)),50);
z(:,:,8) = temp;
[r c]=size(z);
im_new = zeros(r);
for k = 1:7
   z1 = histeq(z(:,:,k),h)*255;
   z5 = conv2(z1,fspecial('gaussian',[20,20],1),'same');
   regions = detectMSERFeatures(uint8(z5),'RegionAreaRange',[7000,1e5]);%to be generalized
   subplot(2,5,k);imagesc(z5);axis image;colormap gray;hold on;axis off;colorbar
   plot(regions,'showPixelList',true,'showEllipses',true);
   
   % Using regions.pixelList and creating a new image (im_new) of the detected pixels. For every region detected, the value of pixel is increased by 1 
   cnt = regions.Count;
   for i=1:cnt  %Number of rosettes
    a = regions.PixelList(i,1);
    [r c] = size(a);
    for j=1:r
        v=a(j,1);
        u=a(j,2);
        im_new(u,v)=im_new(u,v)+1; %Every region that is detected, the value of pixel is increased by 1 thus helping for voting procedure
    end
   end     
end

%New image before voting procedure with all detcted regions
subplot(258);hold off
imagesc((im_new));axis image;colormap gray;title('Detected Region(s)');
[r_im c_im]=size(im_new);
for i=1:r_im
    for j=1:c_im
        if im_new(i,j)<7   %if detected less than 7 times, eliminate that region 
           im_new(i,j)=0;  %and force its pixel value as zero
        end
    end
end

%Final detected region(s)
subplot(259);hold off
imagesc((im_new));axis image;colormap gray;title('Detected Region(s) after voting');

linkaxes
return