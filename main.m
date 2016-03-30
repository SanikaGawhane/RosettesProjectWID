clear all
[filename,pathname,filterindex]=uigetfile({'*.png';'*.tiff';'*.jpg';'*.jpeg'},'Select image');

for k = 2:7
%    temp = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\Two Rosette\Two Rosettes 40X-1024pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
   %temp = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\One Rosette\One Rosette 40X-1024pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
  filename2=fullfile(pathname,filename);
  filename2=filename2(1:end-10);
  filename2=[filename2 num2str(k) '_c002.png'];
   temp = double(imread(filename2));
   temp = medfilt2(temp,[3,3]);
   temp = temp-min(temp(:));
   z(:,:,k) = temp/max(temp(:));
end
x = sum(z,3);
x = x/max(x(:));


figure(1);clf;
z1 = conv2(x,fspecial('gaussian',[20,20],5),'same')*255;
regions = detectMSERFeatures(uint8(z1),'RegionAreaRange',[1e4,1e5]);
subplot(221);hold off
imagesc(z1);hold on; axis image;colormap gray;%colorbar
plot(regions, 'showPixelList', false, 'showEllipses', true);

subplot(222);hold off
imagesc(z1);axis image; hold on
plot(regions, 'showPixelList', true, 'showEllipses', false);


z5 = conv2(x,fspecial('gaussian',[20,20],5),'same')*255;
regions = detectMSERFeatures(uint8(z5),'RegionAreaRange',[1e4,1e5]);
subplot(223);hold off
imagesc(z5);axis image; hold on
plot(regions, 'showPixelList', false, 'showEllipses', true);

subplot(224);hold off
imagesc(z5);axis image; hold on
plot(regions, 'showPixelList', true, 'showEllipses', false);
 

%%
%figure(3);clf;
%figure(4);clf;
temp = mean(z,3);
temp = temp/max(temp(:));
h = hist(temp(:)/max(temp(:)),50);
z(:,:,8) = temp;
for k = 1:8
   z1 = histeq(z(:,:,k),h)*255;
   z5 = conv2(z1,fspecial('gaussian',[20,20],1),'same');
   regions = detectMSERFeatures(uint8(z5),'RegionAreaRange',[8000,19000]);
   figure(3);subplot(2,4,k);imagesc(z1);axis image;colormap gray;hold on;axis off;colorbar
   figure(4);subplot(2,4,k);imagesc(z1);axis image;colormap gray;hold on;axis off
   plot(regions,'showPixelList',true,'showEllipses',true);
end

linkaxes
return

