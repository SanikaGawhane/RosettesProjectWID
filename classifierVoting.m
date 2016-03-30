function[maskResult]=classifierVoting(numSlices,z,hist_eq,areaMin,areaMax,distribution,threshold,base,step)
%    Inputs
%    1 numSlices - number of slices to be analyzed
%    2 z - stack containing all slices and the last slice being mean. Total numSLices+1 slices
%      h - histogram 
%    3 Areamin- minimum pixel area
%    4 Areamax- max pixel area
%      threshold - pixels>threshold- lie in Rossette
%      base= base vlaue in distribution
%      step = step size in distribution
%   Output- mask - conatining regions with rossette

%initialisation
    [s1,s2,s3]=size(z);mask=zeros(s1,s2);mask_temp=zeros(s1,s2);
    %gives a distribution with total sum=1;
    if(size(distribution)~=numSlices),
        distribution=getDistribution(base,step,numSlices);
    else
       distribution=distribution/sum(distribution); 
    end
    
    for k = 1:numSlices
       % Histogram equalisation
            z1 = histeq(z(:,:,k),hist_eq)*255;
       % convolving with a gaussian filter
            z5 = conv2(z1,fspecial('gaussian',[20,20],1),'same');
       % detection MSER in each slice
%             regions = detectMSERFeatures(uint8(z5),'RegionAreaRange',[areaMin,areaMax]);%to be generalized
% 
%        for i=1:regions.Count  %Number of rosettes
%         a = regions.PixelList(i,1); [r c] = size(a);
%             for j=1:r
%                 v=a(j,1);
%                 u=a(j,2);
%                 mask_temp(u,v)=1;
%             end
%        end
new_M = zeros(size(z5));
for k = 1:7
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
 mask_backup=new_M;axis image;colormap gray;title('Detected Region(s)');

%im_new=temp;%temp stores the mean value of pixels along all the stacks
[r_im c_im]=size(im_new);
       mask=mask+distribution(k)*mask_temp;
    end
    maskResult=mask>threshold;
    figure;
    subplot(221);imagesc(mask);colorbar;colormap gray;
    subplot(222);imagesc(maskResult);colorbar;colormap gray;
    subplot(223);imagesc(z(:,:,numSlices+1));colormap gray;
    subplot(224);imagesc(maskResult.*z(:,:,numSlices+1));colormap gray;
end