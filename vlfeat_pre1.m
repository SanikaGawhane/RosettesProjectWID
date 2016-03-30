clc
close all
clear all

tic
no_of_imgs = 1;
no_of_stacks = 9;
num_iter = 20;
delta_t = 1/7;
kappa = 300;
option = 1;
thr=40;
avg_angle=[];

% results_file = 'results_new_v4.xlsx';
% col = {'Filename','Num_of_Ros_present','Num_of_ros_detected','Circularity','Avg_angle','MSE'};
% first_cell = 'A1';
% xlswrite(results_file,col,1,first_cell);

% main_folder=uigetdir;
% subfolders=dir(main_folder);
% 
% for num_i=1:no_of_imgs
%     image_going_on = num_i
%     pathname=[main_folder '\' subfolders(num_i).name];
%     files_in_path = dir(pathname);
%     filename = files_in_path(5).name;

for num_i=1:no_of_imgs
    str_no_of_imgs=num2str(num_i);
    l_str = length(str_no_of_imgs);
    if (num_i==1)
        [filename,pathname,filterindex]=uigetfile({'*.png';'*.tiff';'*.jpg';'*.jpeg'},'Select image');
    elseif (num_i==2)
        pathname = [pathname(1:length(pathname)-(l_str+1)) num2str(num_i)];
        files_in_path = dir(pathname);
        filename = files_in_path(5).name;
    elseif (num_i>10)
        pathname = [pathname(1:length(pathname)-l_str) num2str(num_i)];
        files_in_path = dir(pathname);
        filename = files_in_path(5).name;    
    end
    
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
z(:,:,10) = temp;

[r_z c_z]=size(z);
mask=zeros(r_z);mask_temp=zeros(r_z);
mask2 = zeros(r_z);flag=0;
for k = 1:no_of_stacks
   z1 = histeq(z(:,:,k),hist_eq)*255;
   z5 = anisodiff2D(z1, num_iter, delta_t, kappa, option);
   
   % Area specified as RegionArea/ImageArea
   [r,f] = vl_mser(uint8(z5),'MinArea',0.004,'MaxArea',0.02);
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
  
mask2 = mask2+M;
% figure;%%1
% clf; imagesc(z5); hold on; axis equal off; colormap gray;title('Original Image stack');
% [c,h]=contour(M,(0:max(M(:))));
% set(h,'color','y','linewidth',1) ;
end
close all;

figure;subplot(221);imshow(x);title('Mean Image');%%fig1
%figure;subplot(142);imshow(new_M);title('Detected Regions');

[r_M c_M] = size(mask2);
for i=1:r_M
    for j=1:c_M
        if mask2(i,j)<6   %if detected less than 7 times, eliminate that region 
           mask2(i,j)=0;  %and force its pixel value as zero
        end
    end
end

%figure;%%2
subplot(222);imshow(mask2);title('Detected Regions after voting');
mask2 = bwareaopen(mask2, 6000);
mask2 = im2double(mask2);

 se=strel('disk',5);
 for i=1:4 %%can be changed
    mask2=imdilate(mask2,se);%title('Erosion+Dilation');pause(0.1);%%image output
 end
 for(i=1:4)
    mask2=imerode(mask2,se);%pause(0.1);
 end
mask2=imfill(mask2,'holes');
subplot(223);imshow(mask2);title('Removing small components');

imgPath_mask=fullfile(pathname,[filename(1:end-5) 'mask.tif']);
imwrite(mask2,imgPath_mask);

imgPath_mean=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
imwrite(x,imgPath_mean);

avgangle= movement2(imgPath_mask,imgPath_mean);
avg_angle=[avg_angle avgangle];

cc = bwconncomp(mask2);
stats = regionprops(cc, 'Area','MajorAxisLength','MinorAxisLength');
sizeStats = size(stats);
circularity=[];
for s=1:sizeStats(1)
    circularity1(s)=stats(s).MajorAxisLength/stats(s).MinorAxisLength;
    circularity=[circularity circularity1(s)];
end
idx = find([stats.Area] > 6000);
BW2 = ismember(labelmatrix(cc), idx);
%figure; imshow (BW2);
ros(num_i) = cc.NumObjects

%%%%calculate error%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
actual_ros(num_i) = str2num(filename(1));
err_in_det(num_i) = abs(actual_ros(num_i) - ros(num_i));
sq_err(num_i) = err_in_det(num_i).*err_in_det(num_i);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Write data into excel file%%%%%%%%%%%%%%%%%%%%%%%%
% str_angle=mat2str(avgangle);
% str_circ=mat2str(circularity);
% results ={filename,str2num(filename(1)),ros(num_i),str_circ,str_angle,sq_err(num_i)};
% xlswrite(results_file,results,1,['A' num2str(num_i+1)]);

end

%%%Calculate MSE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mse=sum(sq_err)/no_of_imgs;
% rmse=sqrt(mse);
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%