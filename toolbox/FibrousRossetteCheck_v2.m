function[fiberBoundaryAngle]=FibrousRossetteCheck_v2(mask,pathname,filename)
    [s1Image,s2Image]=size(mask);answer=0;%default
    % boundary contains two columns of x and y coordinates of all bnd points
    B=bwboundaries(mask);
    for k2 = 1:length(B),
        kip = B{k2};
        boundaryCell{k2}=kip;
    end
    
    %need to smooth the boundary
    figure;imagesc(mask);hold on;
    imgPath=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
    figure;imshow(imread(imgPath));hold on;
    matdata=importdata(fullfile(pathname,'ctFIREout',['ctFIREout_',filename(1:end-5),'mean.mat']));
    for k2 = 1:length(B)
        boundary=B{k2};
        plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);%boundary need not be dilated now because we are using plot function now
        boundaryTemp=boundary;
        [A,c]=MinVolEllipse(boundaryTemp',0.1);
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
                    if(ellipse_mask(x_cord(m-1),y_cord(m-1))*ellipse_mask(x_cord(m+1),y_cord(m+1))==0&&(ellipse_mask(x_cord(m+1),y_cord(m+1))==1||ellipse_mask(x_cord(m+1),y_cord(m+1))==1))
                        fiber_indices(k,2)=1;break;
                    end
               end 
                if(fiber_indices(k,2)==1)
                    plot(y_cord,x_cord,'LineStyle','-','color',color1,'linewidth',0.005);%hold on;
                end
            end
             title(['Average angle is=' num2str(mean(fiberBoundaryAngle))]);
    end    
   

end