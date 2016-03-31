% adding path to ctFIRE
%addpath('C:\Users\S.S. Mehta\Desktop\Github_UWLOCI\curvelets\ctFIRE');
clc
close all
clear all
[filename,pathname,filterindex]=uigetfile({'*.png';'*.tiff';'*.jpg';'*.jpeg'},'Select image');


for k = 1:7
   %temp = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\Two Rosette\Two Rosettes 40X-1024pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
    filename2=fullfile(pathname,filename);
    filename2=filename2(1:end-10);
  filename2=[filename2 num2str(k) '_c002.png'];
   temp=double(imread(filename2));
   temp = medfilt2(temp,[3,3]);
   temp = temp-min(temp(:));
   z(:,:,k) = temp/max(temp(:));% should be max-previous min -- error . resolve after 24th Nov meeting
end
% z has the normalized image
x = sum(z,3);
x = x/max(x(:));
% compressing the stack to one image and normalizing it

temp = mean(z,3);
temp = temp/max(temp(:));
hist_eq = hist(temp(:)/max(temp(:)),50);
z(:,:,8) = temp;
[r c]=size(z);
mask=zeros(r);mask_temp=zeros(r);new_M = zeros(size(z5));
for k = 1:7
   z1 = histeq(z(:,:,k),hist_eq)*255;
   z5 = conv2(z1,fspecial('gaussian',[20,20],1),'same');
   % Area specified as RegionArea/ImageArea
   [r,f] = vl_mser(uint8(z5),'MinArea',0.005,'MaxArea',0.01,'BrightOnDark',1);
   f = vl_ertr(f);
   vl_plotframe(f);

   M = zeros(size(z5)); 
   for y=r'
       s = vl_erfill(uint8(z5),y);
       if (k>2) && (k<6) 
       M(s) = M(s) + 2;
       else
       M(s) = M(s) + 1;
        end
   end
  
new_M = new_M+M;
figure;
clf; imagesc(z5); hold on; axis equal off; colormap gray;
[c,h]=contour(M,(0:max(M(:))));
set(h,'color','y','linewidth',1) ;
end

figure(9)
imshow(new_M);

[r_M c_M] = size(new_M);
for i=1:r_M
    for j=1:c_M
        if new_M(i,j)<4   %if detected less than 7 times, eliminate that region 
           new_M(i,j)=0;  %and force its pixel value as zero
        end
    end
end

%Final detected region(s)
 im_new=~new_M;
 im_new=~im_new;
 
 figure
 imshow(im_new);
 mask_backup=im_new;axis image;colormap gray;title('Detected Region(s)');

im_new=temp;%temp stores the mean value of pixels along all the stacks
[r_im c_im]=size(im_new);
linkaxes

%converting mask to binary values for processing
mask=mask_backup>=6;
mask2=mask_backup>=7;
    % filling the mask
closing_mask(1:7,1:7)=logical(1);
mask=closing(mask,closing_mask,6);
figure;imagesc(mask);hold on;

%plotting the boundaries and saving images- starts
B=bwboundaries(mask);
for k2 = 1:length(B)
     boundary = B{k2};
     plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);%boundary need not be dilated now because we are using plot function now
end
%saving the mean image and the mask . image as a uint8 and mask as a
%logical image
savePath=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
imwrite(uint8(255*temp),savePath);

savePath=fullfile(pathname,[filename(1:end-5) 'mask.tif']);
imwrite(mask,savePath);

savePath=fullfile(pathname,[filename(1:end-5) 'filtered_image.tif']);
filtered_image=double(mask).*temp;
imwrite(filtered_image,savePath);
%plotting the boundaries and saving images- ends
%ctFIRE;

%sending mask and boundary to a function for classifying rossettes with
%fibres sticking out of it
fibrous_rossette_present=FibrousRossetteCheck(mask,pathname,filename);