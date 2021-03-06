function[avg_angle]=huggingBondary(mask,image)
%     image=imread('image.tif');
%     mask=imread('mask.tif');
    mask=logical(mask);
    
    boxSize=15;%the boundary gets bigger on one side by 15/2 i.e 7 pixels
    se=strel('square',boxSize);
    dilatedMask=imdilate(mask,se);
    
    boundaryRegion=dilatedMask-mask;
    
    centerBoundaryRegion = bwmorph(boundaryRegion,'thin',Inf);
    smallerBoxSize=floor(boxSize/2);
    
    cc=bwconncomp(uint8(centerBoundaryRegion));
    centroidRos=regionprops(mask,'centroid');
    [s1,s2]=size(mask);
    for k=1:cc.NumObjects
       index=cc.PixelIdxList{1,k};%Index in raster scan order
       xc(k)=centroidRos(k).Centroid(1);
       yc(k)=centroidRos(k).Centroid(2);
       y=floor(index/s1);
       x=index-y*s1;
       centerBoundaryRegion=double(centerBoundaryRegion);
       f1=figure;imagesc(centerBoundaryRegion);colorbar;
       for i=1:size(y,1)-1%because no i+1 point for the last point
           centerBoundaryRegion(x(i),y(i))=centerBoundaryRegion(x(i),y(i))+2;
           subImage=image(x(i)-smallerBoxSize:x(i)+smallerBoxSize,y(i)-smallerBoxSize:y(i)+smallerBoxSize);
           angle1(i)=directionality(subImage); 
           %calculating tangent angle wrt boundary
           x1(i)=x(i+1)-x(i);
           y1(i)=y(i)-y(i+1);%matlab way of indexing is different
           theta = (atan(y1(i)/x1(i)))*180/pi;
           angle2(i)=theta+90;           
       end
       avg_angle(k)=avgangle(angle1,angle2);
       hold on;text(xc(k),yc(k),num2str(avg_angle(k)));
       display(avg_angle(k));
    end
    figure(f1);imagesc(centerBoundaryRegion);colorbar;
    
    figure;
    subplot(1,3,1);imshow(mask);
    subplot(1,3,2);imshow(dilatedMask);
    subplot(1,3,3);imshow(centerBoundaryRegion);
    
    figure;imagesc(double(mask)+double(dilatedMask)+double(centerBoundaryRegion));colorbar;
end