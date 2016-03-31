function[fiberBoundaryAngle]=FibrousRossetteCheck_v3(mask,pathname,filename)
    [s1Image,s2Image]=size(mask);answer=0;%default
    % boundary contains two columns of x and y coordinates of all bnd points
    B=bwboundaries(mask);
   
    %need to smooth the boundary
    figure;imagesc(mask);hold on;
    imgPath=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
    figure;imshow(imread(imgPath));hold on;
    matdata=importdata(fullfile(pathname,'ctFIREout',['ctFIREout_',filename(1:end-5),'mean.mat']));
    
    tolerance=0.1;
    for k2 = 1:length(B)
        boundary=B{k2};
        plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);%boundary need not be dilated now because we are using plot function now
        boundaryTemp=boundary;
        [A,c]=MinVolEllipse(boundaryTemp',tolerance);
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
                    if(ellipse_mask(x_cord(m-1),y_cord(m-1))*ellipse_mask(x_cord(m+1),y_cord(m+1))==0&&(ellipse_mask(x_cord(m+1),y_cord(m+1))==1||ellipse_mask(x_cord(m+1),y_cord(m+1))==1))
                        fiber_indices(k,2)=1;
                        fiberBoundaryAngle(count)=findFiberBoundaryAngle(ellipse_boundary,x_cord,y_cord,m);% use m to get x_cord(m-1),x_cord(m+1) and ximmilarly y_cord at m-1 and m+1
                        break;
                    end
                end 
                color2=[0,1,0];
                if(fiber_indices(k,2)==1)
                    plot(y_cord,x_cord,'LineStyle','-','color',color1,'linewidth',0.005);%hold on;
                    %text(x_cord(s1),y_cord(s1),num2str(i),'HorizontalAlignment','center','color',color1);
                    text(y_cord(end),x_cord(end),num2str(k),'color',color2);
                   fiberBoundaryAngle(count)=findFiberBoundaryAngle(ellipse_boundary,x_cord,y_cord,m);% use m to get x_cord(m-1),x_cord(m+1) and ximmilarly y_cord at m-1 and m+1
                    count=count+1;
                end
            end
             title(['Average angle is=' num2str(mean(fiberBoundaryAngle))]);
    end    
   
    function[angle]=findFiberBoundaryAngle(ellipse_boundary,x_cord,y_cord,m)
      x1=x_cord(1);y1=y_cord(1);
      x2=x_cord(end);y2=y_cord(end);
      
      for n=1:size(ellipse_boundary,1)
         x0=ellipse_boundary(n,1);
         y0=ellipse_boundary(n,2);
         dist=distanceFromLine(x1,x2,y1,y2,x0,y0);
         fprintf('dist=%f\n',dist);
         text(y0,x0,'a','color',[1,1,1]);
         pause(0.1);
      end
    end

    function[distance]=distanceFromLine(x1,x2,y1,y2,x0,y0)
       text(y1,x1,'point1','color',[1,1,0]);
       text(y2,x2,'point2','color',[1,1,0]);
       text(y0,x0,'a','color',[1,0,0]);
        num=(y2-y1)*x0-(x2-x1)*y0+x2*y2-y2*x1;
       den=sqrt((y2-y1)^2+(x2-x1)^2);
       distance=num/den;
    end
end