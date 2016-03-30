% adding path to ctFIRE
addpath('C:\Users\S.S. Mehta\Desktop\Github_UWLOCI\curvelets\ctFIRE');
clc;close all;clear all;
[filename,pathname,filterindex]=uigetfile({'*.png';'*.tiff';'*.jpg';'*.jpeg'},'Select image');
filename2=fullfile(pathname,filename);
numSlices=getSliceNumber(filename2);
display(numSlices);

% filling z ,x and other non critical data
    for k = 1:numSlices
       %temp = double(imread(['C:\Users\Sanika\Desktop\Rosette Images\Two Rosette\Two Rosettes 40X-1024pix-Z-stack(1.75um step) #1_z00' num2str(k) '_c002.png']));
        filename2=fullfile(pathname,filename);
        filename2=filename2(1:end-10);
      filename2=[filename2 num2str(k) '_c002.png'];
       temp=double(imread(filename2));
       temp = medfilt2(temp,[3,3]);
       minOld=min(temp(:));
       temp = temp-min(temp(:));
       z(:,:,k) = temp/(max(temp(:))-minOld);% should be max-previous min -- error . resolve after 24th Nov meeting
    end
    % z has the normalized image
    x = sum(z,3);
    x = x/max(x(:));
    % compressing the stack to one image and normalizing it

    temp = mean(z,3);
    temp = temp/max(temp(:));
    hist_eq = hist(temp(:)/max(temp(:)),50);
    z(:,:,numSlices+1) = temp;
    [r c]=size(z);
mask=zeros(r);mask_temp=zeros(r);

%classifier 1 - voting
areaMin=4000;areaMax=2e5;distribution=0;threshold=0.6;
base=0.4;step=0.1;
mask=classifierVoting(numSlices,z,hist_eq,areaMin,areaMax,distribution,threshold,base,step);

%taking backups
 mask_backup=mask;im_new=temp;%temp stores the mean value of pixels along all the stacks

mask=smoothClassifierVotingMask(mask);

mask=removeSmallAreas(mask,areaMin,areaMax);
figure;imagesc(mask);title('mask after removing small areas');
saveImages(pathname,filename,temp,mask);

%fibrous_rossette_present=FibrousRossetteCheck_v4(mask,pathname,filename);