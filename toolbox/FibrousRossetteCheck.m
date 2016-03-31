function[fiberBoundaryAngle]=FibrousRossetteCheck(mask,pathname,filename)
    [s1Image,s2Image]=size(mask);answer=0;%default
    % boundary contains two columns of x and y coordinates of all bnd points
    B=bwboundaries(mask);
    for k2 = 1:length(B),boundary(:,:,k2) = B{k2};end
    
    %need to smooth the boundary
    figure;imagesc(mask);hold on;
    for k2 = 1:length(B)
        plot(boundary(:,2,k2), boundary(:,1,k2), 'y', 'LineWidth', 2);%boundary need not be dilated now because we are using plot function now
        boundaryTemp=boundary(:,:,k2);
        [A,c]=MinVolEllipse(boundary',0.1);
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
            figure;imagesc(mask);hold on;plot(ellipse_boundary(:,2),ellipse_boundary(:,1));

        % Step 2 
            imgPath=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
            figure;imshow(imread(imgPath));hold on;plot(ellipse_boundary(:,2),ellipse_boundary(:,1));
            %ideally should run ctFIRE here- but will do manually now-done
            %reading matdata
            matdata=importdata(fullfile(pathname,'ctFIREout',['ctFIREout_',filename(1:end-5),'mean.mat']));
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
                color1=[1,1,0];
                %checking if the fiber passes through the boundary
                FLAG=0;%1 if on boundary
                for n=1:sizeEllipseBoundaryPoints
                   for m=1:numPointsInFiber
                        x_cord(m)=matdata.data.Xa(point_indices(m),1);
                        y_cord(m)=matdata.data.Xa(point_indices(m),2);
                        if(ellipse_boundary(n,2)==x_cord(m)&&ellipse_boundary(n,1)==y_cord(m))
                            ellipse_point1x=ellipse_boundary(n-1,2);ellipse_point1y=ellipse_boundary(n-1,1);
                           ellipse_point2x=ellipse_boundary(n+1,2);ellipse_point2y=ellipse_boundary(n+1,1);
                            
                           if(m==1)
                            fiber_point1x=x_cord(m);fiber_point1y=y_cord(m);
                           else
                            fiber_point1x=x_cord(m-1);fiber_point1y=y_cord(m-1);
                           end
                           if(m==numPointsInFiber)
                            fiber_point2x=x_cord(m);fiber_point2y=y_cord(m);
                           else
                               fiber_point2x=x_cord(m+1);fiber_point2y=y_cord(m+1);
                           end
                           

                           v1=[ellipse_point1y-ellipse_point2y;ellipse_point1x-ellipse_point2x];
                           v2=[fiber_point1y-fiber_point2y;fiber_point1x-fiber_point2x];
                           fiberBoundaryAngle(count)=180/pi*acos(dot(v1/norm(v1),v2/norm(v2)));
                           count=count+1;
                           fiber_indices(k,2)=1; 
                           FLAG=1;break;
                        end
                   end 
                   if(FLAG==1),break;end
                end
                if(fiber_indices(k,2)==1)
                    plot(x_cord,y_cord,'LineStyle','-','color',color1,'linewidth',0.005);hold on;
                end
            end
            
             title(['Average angle is=' num2str(mean(fiberBoundaryAngle))]);
            
    end    
   

end