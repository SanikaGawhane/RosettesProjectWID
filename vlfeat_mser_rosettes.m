% adding path to ctFIRE
%addpath('C:\Users\SanikaGawhane\Desktop\UWLOCI\curvelets\ctFIRE');

clc
close all
clear all

[filename,pathname,filterindex]=uigetfile({'*.png';'*.tiff';'*.jpg';'*.jpeg'},'Select image');


for k = 1:7
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

[r_z c_z]=size(z);
mask=zeros(r_z);mask_temp=zeros(r_z);

new_M = zeros(r_z);
for k = 1:7
   z1 = histeq(z(:,:,k),hist_eq)*255;
   z5 = conv2(z1,fspecial('gaussian',[20,20],1),'same');
   % Area specified as RegionArea/ImageArea
   [r,f] = vl_mser(uint8(z5),'MinArea',0.006,'MaxArea',0.015,'BrightOnDark',1);
   f = vl_ertr(f);
   vl_plotframe(f);

   M = zeros(size(z5)) ;
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
% imshow(new_M);title('Detected Regions');
[r_M c_M] = size(new_M);
for i=1:r_M
    for j=1:c_M
        if new_M(i,j)<4   %if detected less than 7 times, eliminate that region 
           new_M(i,j)=logical(0);  %and force its pixel value as zero
        end
    end
end

figure;
% imshow(new_M);title('Detected Regions after voting');

 se=strel('disk',5);
 new_M=logical(new_M);mask2=new_M;
 for i=1:4
    mask2=imdilate(mask2,se);imshow(mask2);title('snfl');pause(0.1);
 end
 for(i=1:4)
    mask2=imerode(mask2,se);pause(0.1);
 end
 
 
 
 %mask2=imfill(mask2);figure;imshow(mask2);title('filled holes');
 
 %Final detected region(s)
%  im_new=~new_M;
%  im_new=~im_new;
%  
%  figure
%  imshow(im_new);

 mask=new_M;figure;imshow(mask);title('Input to fiber check');
[s1Image,s2Image]=size(new_M);%default
    % boundary contains two columns of x and y coordinates of all bnd points
    B=bwboundaries(mask2);
    %mask2=mask;
    for k2 = 1:length(B),
        kip = B{k2};
        boundaryCell{k2}=kip;
    end
    
    %need to smooth the boundary
    figure;imagesc(mask);hold on;colormap gray;
    imgPath=fullfile(pathname,[filename(1:end-5),'mean.tif']);
    figure;imshow(imread(imgPath));hold on;
    imwrite(mask2,imgPath);
    % close all %% to close all initial figures
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %run CtFIRE here
    matdata=importdata(fullfile(pathname,'ctFIREout',['ctFIREout_',filename(1:end-5),'mean.mat']));
%     matdata=importdata('D:\UWM\WID\RossettesProject\One Rosette\ctFIREout\ctFIREout_One Rosette 40X-1024pix-Z-stack(1.75um step) #1_z001_c00mean.mat');
    for k2 = 1:length(B)
        boundary=B{k2};
        plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);%boundary need not be dilated now because we are using plot function now
        boundaryTemp=boundary;
        Tolerance=0.1;
        [A,c]=MinVolEllipse(boundaryTemp',Tolerance);
        ellipse_mask(1:s1Image,1:s2Image)=0;
        for i=1:s1Image
            for j=1:s2Image
                vector=[i;j];
                cond1=((vector-c)'*A*(vector-c));
                if(cond1<=1)
                   ellipse_mask(i,j)=1; 
                end
            end
        end
        %ellipse mask contains the minimum enclosing the mask points
        
        % Step 1 find the ellipse boundary
        % find the fibers of the image
        % find the fibers which are intersecting
        % find the angle of each fiber with the boundary
        
        % Step 1
            ellipse_boundary=bwboundaries(ellipse_mask);ellipse_boundary=ellipse_boundary{1};
            % plotting the enclosing ellipse
            %figure;imagesc(mask);hold on;plot(ellipse_boundary(:,2),ellipse_boundary(:,1));

        % Step 2 
            
            plot(ellipse_boundary(:,2),ellipse_boundary(:,1));
            %ideally should run ctFIRE here- but will do manually now-done
            %reading matdata
            
            sizeFibers=size(matdata.data.Fa,2);
            fiber_indices(1:sizeFibers,1:3)=0;
            sizeEllipseBoundaryPoints=size(ellipse_boundary,1);
            fiberBoundaryAngle=[];
            count=1;
            
            for k=1:sizeFibers
                fiber_indices(k,1)=k; fiber_indices(k,2)=0; 
                point_indices=matdata.data.Fa(1,k).v;
                numPointsInFiber=size(point_indices,2);
                x_cord=[];y_cord=[];
                for m=1:numPointsInFiber
                    x_cord(m)=matdata.data.Xa(point_indices(m),1);
                    y_cord(m)=matdata.data.Xa(point_indices(m),2);
                end
                color1=[1,0,0];
                %checking if the fiber passes through the boundary
                FLAG=0;%1 if on boundary

               for m=2:numPointsInFiber-1
                    if(ellipse_mask(x_cord(m-1),y_cord(m-1))*ellipse_mask(x_cord(m+1),y_cord(m+1))==0&&(ellipse_mask(x_cord(m+1),y_cord(m+1))==1||ellipse_mask(x_cord(m-1),y_cord(m-1))==1))
                        point1=[x_cord(1),y_cord(1)];
                        point2=[x_cord(end),y_cord(end)];
                        %using first and last point of the fiber to
                        %calculate angle
                        
                        angle=0;
                        for n=2:size(ellipse_boundary,1)-1
                           x1=point1(1);y1=point1(2);
                           x2=point2(1);y2=point2(2);
                %            text(y1,x1,'point1','color',[1,1,1]);
                %            text(y2,x2,'point2','color',[1,1,1]);

                           xe1=ellipse_boundary(n-1,1);ye1=ellipse_boundary(n-1,2);
                           xe2=ellipse_boundary(n+1,1);ye2=ellipse_boundary(n+1,2);

                           dist1=distanceFromLine(x1,x2,y1,y2,xe1,ye1);
                           dist2=distanceFromLine(x1,x2,y1,y2,xe2,ye2);
                %            text(ellipse_boundary(n,2),ellipse_boundary(n,1),num2str(sign(dist1*dist2)),'color',[1,1,1]);
                %            fprintf('%f\n',sign(dist1*dist2));
                           if(sign(dist1*dist2)==-1)
                              v1=[y1-y2;x1-x2];
                              v2=[ye1-ye2;xe1-xe2];
                              angle=180/pi*acos(dot(v1/norm(v1),v2/norm(v2)));
                %               display(angle);
                               break; 
                           end
                          % pause(0.1);
                       end
        
                        fiberBoundaryAngle(count)=angle;
                        count=count+1;
                        fiber_indices(k,2)=1;break;
                    end
               end 
                if(fiber_indices(k,2)==1)
                    plot(y_cord,x_cord,'LineStyle','-','color',color1,'linewidth',0.005);%hold on;
                end
            end
            outVar{k2}=fiberBoundaryAngle;%cotains all angles  
            title(['Average angle is=' num2str(mean(fiberBoundaryAngle))]);
            text(mean(ellipse_boundary(:,2)),mean(ellipse_boundary(:,1)),[num2str(mean(fiberBoundaryAngle)) ' ' num2str(size(fiberBoundaryAngle))],'color',[1 0 0]);
            
            % got the results for angles and number of fibers
            % based on angles and number of fibers we remove the areas
            
            numThreshold=15;
            angleMinThreshold=75;
            angleMaxThreshold=100;
            meanAngle=mean(fiberBoundaryAngle);
           if(size(fiberBoundaryAngle)<numThreshold|meanAngle<angleMinThreshold|meanAngle>angleMaxThreshold)
               negativeMask=~roipoly(mask,boundary(:,2),boundary(:,1));
                mask2=mask2&negativeMask;
           end
           se=strel('disk',5);
           mask2=imerode(mask2,se);%imshow(mask2);
           mask2=imdilate(mask2,se);
            
    
end    
figure;imagesc(mask2);colormap gray;title('classifier2 output');
figure;imagesc(mask);colormap gray;title('classifier2 input');

    
   
%     function[angle]=getAngle(point1,point2,ellipse_boundary)
%        angle=0;
%         for n=2:size(ellipse_boundary,1)-1
%            x1=point1(1);y1=point1(2);
%            x2=point2(1);y2=point2(2);
% %            text(y1,x1,'point1','color',[1,1,1]);
% %            text(y2,x2,'point2','color',[1,1,1]);
%            
%            xe1=ellipse_boundary(n-1,1);ye1=ellipse_boundary(n-1,2);
%            xe2=ellipse_boundary(n+1,1);ye2=ellipse_boundary(n+1,2);
%            
%            dist1=distanceFromLine(x1,x2,y1,y2,xe1,ye1);
%            dist2=distanceFromLine(x1,x2,y1,y2,xe2,ye2);
% %            text(ellipse_boundary(n,2),ellipse_boundary(n,1),num2str(sign(dist1*dist2)),'color',[1,1,1]);
% %            fprintf('%f\n',sign(dist1*dist2));
%            if(sign(dist1*dist2)==-1)
%               v1=[y1-y2;x1-x2];
%               v2=[ye1-ye2;xe1-xe2];
%               angle=180/pi*acos(dot(v1/norm(v1),v2/norm(v2)));
% %               display(angle);
%                return; 
%            end
%           % pause(0.1);
%        end
%         
%     end

linkaxes
return