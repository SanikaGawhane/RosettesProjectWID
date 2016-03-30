%s = imread('E:\300um Circles 1024pix-2.4pixeldwell\extracted images\two\two1\2 Rosettes 1_t003_c002.png');
%s = phantom(512) + randn(512);

clc
close all
clear all

no_of_stacks = 9;
num_iter = 20;
delta_t = 1/7;
kappa = 300;
option = 1;
thr = 40;
[filename,pathname,filterindex]=uigetfile({'*.png';'*.tiff';'*.jpg';'*.jpeg'},'Select image');

for k = 1:no_of_stacks
    filename2=fullfile(pathname,filename);
    filename2=filename2(1:end-10);
    filename2=[filename2 num2str(k) '_c002.png'];
    temp=double(imread(filename2));
    
    temp = medfilt2(temp,[3,3]);
    temp = temp-min(temp(:));
   z(:,:,k) = temp/max(temp(:));
end
% z has the normalized image
x = sum(z,3);
x = x/max(x(:));

% compressing the stack to one image and normalizing it
temp = mean(x,3);
temp = temp/max(temp(:));
hist_eq = hist(temp(:)/max(temp(:)),50);
z(:,:,8) = temp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%red img
for k_r = 1:9
    filename2_r=fullfile(pathname,filename);
    filename2_r=filename2_r(1:end-10);
    filename2_r=[filename2_r num2str(k) '_c003.png'];
    temp_r=double(imread(filename2_r));
    
    temp_r = medfilt2(temp_r,[3,3]);
    temp_r = temp_r-min(temp_r(:));
   z_r(:,:,k_r) = temp_r/max(temp_r(:));
end
% z has the normalized image
x_r = sum(z_r,3);
x_r = x_r/max(x_r(:));

% compressing the stack to one image and normalizing it
temp_r = mean(x_r,3);
temp_r = temp_r/max(temp_r(:));
hist_eq_r = hist(temp_r(:)/max(temp_r(:)),50);
z_r(:,:,8) = temp_r;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
[r_z c_z]=size(z);
mask=zeros(r_z);mask_temp=zeros(r_z);

new_M = zeros(r_z);flag=0;
g3 = zeros(size(x));
g4 = zeros(size(x));
%gray2bin
[r_g c_g] = size(x);
for k = 1:no_of_stacks
   z1 = histeq(z(:,:,k),hist_eq)*255;
   ad = anisodiff2D(z1,num_iter,delta_t,kappa,option);
   for i=1:r_g
    for j=1:c_g
        if ad(i,j)>=thr;
            g3(i,j) = 1;
        else
            g3(i,j) = 0;
        end
    end
end
temp = bwareaopen(g3, 6700);
g4 = temp + g4;
end
for i=1:r_g
    for j=1:c_g
        if g4(i,j)<5   %if detected less than 7 times, eliminate that region 
           g4(i,j)=0;  %and force its pixel value as zero
        end
    end
end
g4 = bwareaopen(g4, 6700);
figure;subplot(121);imshow(g4);

se=strel('disk',5);
for i=1:4
    g4=imdilate(g4,se);
 end
 for i=1:4
    g4=imerode(g4,se);pause(0.1);
 end
g4=imfill(g4,'holes');
subplot(122);imshow(g4);title('Erosion+Dilation');
g5 = bwareaopen(g4, 6700);
imgPath_mask=fullfile(pathname,[filename(1:end-5) 'mask.tif']);
imwrite(g5,imgPath_mask);

imgPath_mean=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
imwrite(x,imgPath_mean);

avgangle= movement2(imgPath_mask,imgPath_mean);

cc = bwconncomp(g5);
stats = regionprops(cc, 'Area');
idx = find([stats.Area] > 6700);
BW2 = ismember(labelmatrix(cc), idx);
%figure; imshow (BW2);
ros = cc.NumObjects

%directionality test
direc = directions(x,g4);

        
% imgPath=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
%     imwrite(x,imgPath);
%     imshow(imread(imgPath));title('Input to Fiber setection process');hold on;