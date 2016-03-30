clear all
%One Rosette
for k = 1:7
   x(:,:,k) = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\One Rosette\One Rosette 40X-1024pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
end
x = sum(x,3);
x = x/max(x(:))*255;

%Two Rosettes
for k = 2:7
   y(:,:,k) = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\Two Rosette\Two Rosettes 40X-1024pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
end
y = sum(y,3);
y = y/max(y(:))*255;

figure(1);clf;
subplot(321);
imagesc(x);axis image;colormap gray; % Original image in grayscale

%Zero Rosettes
for k = 1:5
   z(:,:,k) = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\Zero Rosette\Zero Rosettes 40X-2048pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
end
z = sum(z,3);
z = z/max(z(:))*255;

z1 = conv2(x,fspecial('gaussian',[20,20],1),'same'); %Gaussian filter sigma=1 for one rosette images
z5 = conv2(y,fspecial('gaussian',[20,20],5),'same'); %Sigma=5; for two rosette images
z3 = conv2(z,fspecial('gaussian',[20,20],5),'same'); %zero rosette images

%one rosette
regions = detectMSERFeatures(uint8(z1),'RegionAreaRange',[20000,45000]); %one rosette
figure(1);
subplot(322);hold off
imagesc(z1);axis image; hold on
plot(regions, 'showPixelList', true, 'showEllipses', true);
sprintf('Total number of rosettes - %d',regions.Count)

%two rosettes
subplot(323);hold off
imagesc(y);axis image;colormap gray;
regions = detectMSERFeatures(uint8(z5),'RegionAreaRange',[7000,100000]);%two rosette
figure(1);
subplot(324);hold off
imagesc(z5);axis image; hold on
plot(regions, 'showPixelList', true, 'showEllipses', true);
sprintf('Total number of rosettes - %d',regions.Count)

%Zero rosettes
subplot(325);hold off
imagesc(z);axis image;colormap gray;
regions = detectMSERFeatures(uint8(z3),'RegionAreaRange',[100,150]);%zero rosette
figure(1);
subplot(326);hold off
imagesc(z3);axis image; hold on; 
plot(regions, 'showPixelList', true, 'showEllipses', true); 
sprintf('Total number of rosettes - %d',regions.Count)