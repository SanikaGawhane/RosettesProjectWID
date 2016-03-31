.function [ angle ,angle2] = movement3( maskName,imageName)
    % read mask and image
    % find the boundary
    % move around the boundary and plot the angles    
    [mask,image]=readImages(maskName,imageName);
    
    boundaryCollection=bwboundaries(mask);boundarySize=size(boundaryCollection,1);
    boxSize=10;%sub blocks are 20*20 boxes
    ratio=sqrt(2);%box center is radius+ratio*boxSize away from center of the mask center
    f1=figure;imagesc(mask);hold on;
    for k=1:boundarySize
        boundary=boundaryCollection{k,1};
        [xc,yc]=findCenter(mask);% x is in 2nd column and y is in 1st column
        for i=1:size(boundary,1)
            if(mod(i,25)==0)
                imagesc(mask);pause(0.1);
            end
            x=boundary(i,2)-xc;
            y=boundary(i,1)-yc;
%    /home/zeus/Downloads/sunRaysDirected3.png         text(floor(boundary(i,2)),floor(boundary(i,1)),'*','Color',[0,1,0]);
            theta=atan(y/x);
            quad=1;
            if(x>=0&&y>=0)
               angle(i,k)=theta; quad=1;
            elseif(x<0&&y>=0)
                angle(i,k)=pi+theta;quad=2;
            elseif(x>=0&&y<0)
                angle(i,k)=theta+2*pi;quad=4;
            elseif(x<0&&y<0)
                angle(i,k)=pi+theta;quad=3;
            end
            if(angle(i,k)>2*pi),angle(i,k)=angle(i,k)-2*pi;end
%             fprintf('%f\n',angle(i));

            %Got angles now finding the subimage
            radius=sqrt(x^2+y^2);
            finalRadius=radius+ratio*boxSize;
            xBox=floor(xc+finalRadius*cos(angle(i)));
            yBox=floor(yc+finalRadius*sin(angle(i)));
            text(xBox,yBox,'*','Color',[1,0,0]);pause(0.1);
            fprintf('%f %d\n',angle(i),quad);
            croppedImage=image(yBox-boxSize:yBox+boxSize,xBox-boxSize:xBox+boxSize);
            mask(yBox-boxSize:yBox+boxSize,xBox-boxSize:xBox+boxSize)=255;
            angle2(i,k)=findDirectionality(croppedImage);
        end
    end

end

function[theta]=findDirectionality(image)
%     options should be - surf, PCA etc
    theta=0;return;
    [s1,s2]=size(image);
    Ix=zeros(s1,s2);
    Iy=zeros(s1,s2);
    count=0;
    for i=2:s1
        for j=2:s2
            Ix(i,j)=image(i,j)-image(i-1,j);
            Iy(i,j)=image(i,j)-image(i,j-1);
            count=count+1;
        end
    end
    Ixavg=sum(Ix(:))/count;
    Iyavg=sum(Iy(:))/count;
    theta=atan(Iyavg/Ixavg);
end

function[mask,image]=readImages(maskName,imageName)
    %reads the mask and iamge speified by names and returns a double array
    mask=imread(maskName);image=imread(imageName);
    if(size(mask)~=size(image))
        display('mismatch of mask and image');
    end
    if(size(mask,3)==3),mask=rgb2gray(mask);end
    if(size(image,3)==3),image=rgb2gray(image);end
    mask=double(mask);image=double(image);
end

function[yc,xc]=findCenter(mask)
   [s1,s2]=size(mask);
   xc=0;yc=0;count=0;
   for i=1:s1
       for j=1:s2
            if(mask(i,j)==255),xc=xc+i;yc=yc+j;count=count+1;end
       end
   end
   xc=xc/count;yc=yc/count;
   xc=floor(xc);yc=floor(yc);
end