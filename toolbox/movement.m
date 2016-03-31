function [avg_angle] = movement( maskName,imageName)
    % read mask and image
    % find the boundary
    % move around the boundary and plot the angles    
    [mask,image1]=readImages(maskName,imageName);
    boundaryCollection=bwboundaries(mask);boundarySize=size(boundaryCollection,1);
    boxSize=10;%sub blocks are 20*20 boxes
    ratio=sqrt(2);%box center is radius+ratio*boxSize away from center of the mask center
    figure;imagesc(mask);hold on;
    for k=1:boundarySize
        boundary=boundaryCollection{k,1};
        [xc,yc]=findCenter(mask);% x is in 2nd column and y is in 1st column
        for i=1:size(boundary,1)
            if(mod(i,25)==0)
                imagesc(mask);pause(0.1);
            end
            x=boundary(i,2)-xc;
            y=boundary(i,1)-yc;
%             text(floor(boundary(i,2)),floor(boundary(i,1)),'*','Color',[0,1,0]);
            theta=atan(abs(y)/abs(x));%what if we take absolute value and then adjust in the quadrants
            quad=1;
            %angle w.r.t. center
            if(x>=0&&y>=0)
               angle1(i,k)=theta; quad=1;%4
               %angle1(i,k)=-1*theta;
            elseif(x<0&&y>=0)
                angle1(i,k)=pi+theta;quad=2;%3
                %angle1(i,k)=-1*(pi-theta);
            elseif(x>=0&&y<0)
                angle1(i,k)=theta+2*pi;quad=4;%1
                %angle1(i,k)=theta;
            elseif(x<0&&y<0)
                angle1(i,k)=pi+theta;quad=3;%2
                %angle1(i,k)=pi-theta;
            end
            if(angle1(i,k)>2*pi)
                angle1(i,k)=angle1(i,k)-2*pi;
            end
%             fprintf('%f\n',angle(i));

            %Got angles now finding the subimage
            radius=sqrt(x^2+y^2);
            finalRadius=radius+ratio*boxSize;
            xBox=floor(xc+finalRadius*cos(angle1(i,k)));
            yBox=floor(yc+finalRadius*sin(angle1(i,k)));
%             text(xBox,yBox,'*','Color',[1,0,0]);
            %fprintf('%f %d\n',angle1(i),quad);
            croppedImage=image1(yBox-boxSize:yBox+boxSize,xBox-boxSize:xBox+boxSize);
            mask(yBox-boxSize:yBox+boxSize,xBox-boxSize:xBox+boxSize)=255;
            angle1(i,k)=angle1(i,k)*180/pi;
            if angle1(i,k)>180
                angle1(i,k)=mod(angle1(i,k),180);
            end
            angle2(i,k)=directionality(croppedImage);
            %diffr(i,k)=180 - ((angle1(i,k)+angle2(i,k)))
        end
    end
avg_angle=avgangle(angle1, angle2);    
end

function[angle2]=directionality(im)
[rg,cg]=size(im);
cnt=0;
gdir=zeros(rg,cg);
Sum2=0;absSum=0;angle21=0;
[Gx ,Gy]=imgradientxy(im);
for i=1:rg
    for j=1:cg
        angle21=atan(Gy(i,j)/Gx(i,j));
        if(~isnan(angle21))
           Sum2=Sum2+angle21;
           absSum=absSum+abs(angle21);
           cnt=cnt+1;
        end
    end
    %display(i);
end
angle2=0;
if(cnt~=0)
    angle2=90-(sign(Sum2)*absSum/cnt*180/pi);
end
end

function[mask,image2]=readImages(maskName,imageName)
    %reads the mask and iamge speified by names and returns a double array
    mask=imread(maskName);image2=imread(imageName);
    if(size(mask)~=size(image2))
        display('mismatch of mask and image');
    end
    if(size(mask,3)==3),mask=rgb2gray(mask);end
    if(size(image2,3)==3),image2=rgb2gray(image2);end
    mask=double(mask);image2=double(image2);
end

%can be substituted with regionprops
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