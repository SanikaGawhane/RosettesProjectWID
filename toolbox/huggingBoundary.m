function[avg_angle]=huggingBoundary(mask,image)
%     image=imread('image.tif');
%     mask=imread('mask.tif');
    mask=logical(mask);
    
    boxSize=20;%the boundary gets bigger on one side by 15/2 i.e 7 pixels
    se=strel('square',boxSize);
    dilatedMask=imdilate(mask,se);
    
    boundaryRegion=dilatedMask-mask;
    
    centerBoundaryRegion = bwmorph(boundaryRegion,'thin',Inf);
    smallerBoxSize=floor(boxSize/2);
    
    cc=bwconncomp(uint8(centerBoundaryRegion));
    centroidRos=regionprops(mask,'centroid');
    [s1,s2]=size(mask);
    figure;imagesc(image);colormap(gray);hold on;
    for k=1:cc.NumObjects
       index=cc.PixelIdxList{1,k};%Index in raster scan order
       xc(k)=centroidRos(k).Centroid(1);
       yc(k)=centroidRos(k).Centroid(2);
       x=floor(index/s1);
       y=index-x*s1;
       centerBoundaryRegion=double(centerBoundaryRegion);
       for i=1:size(y,1)-1%because no i+1 point for the last point
           %if(mod(i,20)==0)
           hold on;text(x(i),y(i),'*','Color',[1,0,0]);%pause(0.0001);%imagesc(image);colormap(gray);pause(0.001);%%trace boundary
           %end
           centerBoundaryRegion(x(i),y(i))=centerBoundaryRegion(x(i),y(i))+2;
           subImage=image(x(i)-smallerBoxSize:x(i)+smallerBoxSize,y(i)-smallerBoxSize:y(i)+smallerBoxSize);
           %hold on;
           angle1(i)=directionality(subImage);
           %calculating tangent angle wrt boundary
           x1(i)=x(i+1)-x(i);
           y1(i)=y(i)-y(i+1);%matlab way of indexing is different
           theta = (atan(y1(i)/x1(i)))*180/pi;
           if theta>80
               angle2(i)=theta-90;
           else
               angle2(i)=theta+90;
           end
       end
       avg_angle(k)=avgangle(angle1,angle2);
       hold on;text(xc(k),yc(k),num2str(avg_angle(k)));
       display(avg_angle(k));
    end
    figure;imagesc(centerBoundaryRegion);colorbar;
    
%     figure;
%     subplot(1,3,1);imshow(mask);
%     subplot(1,3,2);imshow(dilatedMask);
%     subplot(1,3,3);imshow(centerBoundaryRegion);
    
    figure;imagesc(double(mask)+double(dilatedMask)+double(centerBoundaryRegion));colorbar;
end