function [ avg_angle] = movement2( maskName,imageName)
    % read mask and image
    % find the boundary
    % move around the boundary and plot the angles    
    [mask,image]=readImages(maskName,imageName);
    
    %make changes here
    
    maskForBox=mask;
    boxSize=15;
    se=strel('square',boxSize);
    maskForBox=imdilate(maskForBox,se);%pause(0.1);
    boxBoundary=bwboundaries(maskForBox);
    sizeBoxBoundary=size(boxBoundary,1);
    %till here

%     boundaryCollection=bwboundaries(mask);
%     boundarySize=size(boundaryCollection,1);
    %sub blocks
    figure;%subplot(224);
    imagesc(image);title('Box moving around');hold on;
    %centroid calculation
    Ibw = im2bw(mask);
    Ilabel = bwlabel(Ibw);
    stat = regionprops(Ilabel,'centroid');
    imagesc(image); hold on
    for k = 1:length(boxBoundary)
        boundary = boxBoundary{k};
        hold on;plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
    end
    
    if (boundarySize==0)
        avg_angle=0;
    else
        for k=1:boundarySize
            boundary=boxBoundary{k,1};
            boundaryPoints=boxBoundary{k,1};%boundary of dilated mask
            
            xc(k)=stat(k).Centroid(1);
            yc(k)=stat(k).Centroid(2);
            
            for i=1:(size(boundary,1)-1)
                if(mod(i,20)==0)
                    hold on;imagesc(mask);pause(0.001);%%trace boundary
                end
                x=boundary(i,2)-xc(k);
                y=boundary(i,1)-yc(k);
                %angle_centre=atan(y/x);%we do not need it anymore
                %text(floor(boundary(i,2)),floor(boundary(i,1)),'*','Color',[0,1,0]);
                %atan(y/x);
                x1=boundary(i+1,1)-boundary(i,1);%calculating tangent angle wrt boundary
                y1=boundary(i+1,2)-boundary(i,2);
                theta=atan(y1/x1);
                quad=1;
                if(x>=0&&y>=0)
                    anglee(i,k)=theta; quad=1;
                    angle_centr(i,k)=angle_centre;
                elseif(x<0&&y>=0)
                    anglee(i,k)=pi+theta;quad=2;
                    angle_centr(i,k)=pi+angle_centre;
                elseif(x>=0&&y<0)
                    anglee(i,k)=theta+2*pi;quad=4;
                    angle_centr(i,k)=2*pi+angle_centre;
                elseif(x<0&&y<0)
                    anglee(i,k)=pi+theta;quad=3;
                    angle_centr(i,k)=pi+angle_centre;
                end
                if(anglee(i,k)>2*pi),anglee(i,k)=anglee(i,k)-2*pi;end
                %fprintf('%f\n',angle(i));
                
                %Got angles now finding the subimage
%                 radius=sqrt(x^2+y^2);
%                 finalRadius=radius+ratio*boxSize;

                xBox=boundary(i,1);
                
                
                xBox=floor(xc(k)+finalRadius*cos(angle_centr(i,k)));
                yBox=floor(yc(k)+finalRadius*sin(angle_centr(i,k)));
                text(xBox,yBox,'*','Color',[1,0,0]);pause(0.0001);
                %fprintf('%f %d\n',anglee(i,k),quad);
                croppedImage=image(yBox-boxSize:yBox+boxSize,xBox-boxSize:xBox+boxSize);
                hold on;imshow(croppedImage);colormap(gray); %%%to trace the boundary
                mask(yBox-boxSize:yBox+boxSize,xBox-boxSize:xBox+boxSize)=10;
                angle2(i,k)=directionality(croppedImage);
            end
            anglee=anglee*180/pi;
            avg_angle(k)=avgangle(anglee(:,k),angle2(:,k));
            hold on;text(xc(k),yc(k),num2str(avg_angle(k)));
            display(avg_angle(k));
        end
    end
end

function[mask,image]=readImages(maskName,imageName)
    %reads the mask and image speified by names and returns a double array
    mask=imread(maskName);image=imread(imageName);
    if(size(mask)~=size(image))
        display('mismatch of mask and image');
    end
    if(size(mask,3)==3),mask=rgb2gray(mask);end
    if(size(image,3)==3),image=rgb2gray(image);end
    mask=double(mask);image=double(image);
end
