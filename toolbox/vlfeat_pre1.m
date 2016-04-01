clc
close all
clear all

tic
no_of_imgs = 1;
no_of_slices = 9;
num_iter = 20;
delta_t = 1/7;
kappa = 300;
option = 1;
thr=40;
avg_angle=[];

results_file = 'results_04/01.xlsx';
col = {'Filename','Num_of_Ros_present','Num_of_ros_detected','Circularity','Avg_angle','MSE'};
first_cell = 'A1';
xlswrite(results_file,col,1,first_cell);

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
    
for k = 1:no_of_slices
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
temp=x;
% compressing the stack to one image and normalizing it
hist_eq = hist(temp(:)/max(temp(:)),50);
z(:,:,no_of_slices+1) = temp;

[r_z c_z]=size(z);
mask = zeros(r_z);flag=0;
Mvv=zeros(r_z);
for k = 1:no_of_slices
   z1 = histeq(z(:,:,k),hist_eq)*255;%histogram matching
   z5 = anisodiff2D(z1, num_iter, delta_t, kappa, option);%perona malik pre filtering
   
   % Area specified as RegionArea/ImageArea
   [r,f] = vl_mser(uint8(z5),'MinArea',0.004,'MaxArea',0.02);
   f = vl_ertr(f);
   vl_plotframe(f);
   M = zeros(size(z5));
   for y=r'
       s = vl_erfill(uint8(z5),y);
       M(s)=M(s)+1;
       %figure;imagesc(M);colorbar;%for testing
   end
   %make the pixel values to 1 here
   for i1=1:r_z
       for j1=1:r_z
           if M(i1,j1)>0 %if rosette region detected
               if (k>2) && (k<6) %if middle slices %%%%BUG in voting - pixel values getting higher than expected due to multiple additions (max value - 28)
                   M(i1,j1) = 2; %force pixel value to 2
               else
                   M(i1,j1)=1;
               end
           end
       end
   end
mask = mask+M;
figure;imagesc(mask);colorbar;%for testing
end
close all;

figure;subplot(221);imshow(x);title('Mean Image');%%fig1

for i=1:r_z
    for j=1:r_z
        if mask(i,j)<6   %if detected less than 6 times, eliminate that region 
           mask(i,j)=0;  %and force its pixel value as zero
        end
    end
end

%figure;%%2
subplot(222);imshow(mask);title('Detected Regions after voting');

se=strel('disk',5);
 for i=1:5
    mask=imdilate(mask,se);
 end
 for i=1:5
    mask=imerode(mask,se);%pause(0.1);
 end
mask=imfill(mask,'holes');
subplot(223);imshow(mask);
mask = bwareaopen(mask, 8000);title('Removing small components');%binarizes mask2
mask = im2double(mask);

% imgPath_maskName=fullfile(pathname,[filename(1:end-5) 'mask.tif']);
% imwrite(mask,imgPath_maskName);
% 
% imgPath_meanName=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
% imwrite(x,imgPath_meanName);

%avgangle= movement2(imgPath_maskName,imgPath_meanName);
%avg_angle=[avg_angle avgangle];

avg_angle= huggingBoundary(mask,x);
cc = bwconncomp(mask);
stats = regionprops(cc, 'Area','MajorAxisLength','MinorAxisLength');
sizeStats = size(stats);
circularity=[];
for s=1:sizeStats(1)
    circularity1(s)=stats(s).MajorAxisLength/stats(s).MinorAxisLength;
    circularity=[circularity circularity1(s)];
end
idx = find([stats.Area] >=8000);
BW2 = ismember(labelmatrix(cc), idx);
%figure; imshow (BW2);
ros(num_i) = cc.NumObjects

%%%%calculate error%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
actual_ros(num_i) = str2num(filename(1));
err_in_det(num_i) = abs(actual_ros(num_i) - ros(num_i));
sq_err(num_i) = err_in_det(num_i).*err_in_det(num_i);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Write data into excel file%%%%%%%%%%%%%%%%%%%%%%%%
str_angle=mat2str(avg_angle);
str_circ=mat2str(circularity);
results ={filename,str2num(filename(1)),ros(num_i),str_circ,str_angle,sq_err(num_i)};
xlswrite(results_file,results,1,['A' num2str(num_i+1)]);

end

%%%Calculate MSE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mse=sum(sq_err)/no_of_imgs;
% rmse=sqrt(mse);
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%