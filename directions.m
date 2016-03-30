function[diffAnglemain]=directions(iName,mName)
    %iname is the image name ,mname is the maskname
    oimage=iName;
    %if(size(image,3)>1),image=rgb2gray(image);end
    mask=mName;
    %if(size(mask,3)>1),mask=rgb2gray(mask);end
    lim = size(oimage);
    Boundary=bwboundaries(mask);%first is y 2nd is x
    sizeBoundary=size(Boundary);
    diffAnglemain=zeros(sizeBoundary(1),1);    
    for  i=1:sizeBoundary(1)
        %mask=toLogical(mask,100);
        s=regionprops(mask,'centroid');
        centroids=cat(1,s.Centroid);
        xcenter=floor(centroids(1));ycenter=floor(centroids(2));
        boxSize=10;
        %diffAngle(i)=0;%stores the abs differe of theta1 and theta2
        [rb cb]=size(Boundary{i,1});
        diffAngle=0;
        for k=1:rb
           a=distCal(xcenter,ycenter,Boundary{i,1}(k,2),Boundary{i,1}(k,1));
           b=1.5*boxSize;
           %thetat2 - angle of box center theta1 - direction in box
           x=Boundary{i,1}(k,2);y=Boundary{i,1}(k,1);
           theta2=atan(y/x);
           if(x<xcenter)
               theta2=theta2+pi;
           end
           xs=floor(xcenter+(a+b)*cos(theta2));
           ys=floor(ycenter+(a+b)*sin(theta2));
           if((xs-boxSize/2>0) && (ys-boxSize/2>0) && (xs+boxSize/2<lim(1)) && (ys+boxSize/2<lim(1)))
               subimage=oimage(xs-boxSize/2:xs+boxSize/2,ys-boxSize/2:ys+boxSize/2);
           end
           
           [Gmag, Gdir] = imgradient(subimage,'prewitt');
           [ri ci]=size(subimage);
           num_pix=ri*ci;
           sumi=0;
           Gdir1=zeros(ri,ci);
           for ij=1:num_pix
               if (Gdir(ij)>=0)
                   if(x<=xcenter)
                       Gdir1(ij)=Gdir(ij)+90;
                   else if (x>=xcenter && y<=ycenter)
                       Gdir1(ij)=450 - Gdir(ij);
                   else %if (x>=xcenter && y<=ycenter)   
                       Gdir1(ij)=Gdir(ij)-90;
                       end
                   end
               sumi=sumi+Gdir1(ij);
               end
           theta1=sumi/num_pix;
           %%%%%%%%%%%%%%%%%%
           diffAngle=diffAngle+abs(theta1-theta2);
           end
        diffAnglemain(i)=diffAngle/size(Boundary{i,1},1);                
    end
    end   
end

function[dist]=distCal(x1,y1,x2,y2)
    dist=sqrt((x1-x2)^2+(y1-y2)^2);
end

function[output]=toLogical(mask,threshold)
    [s1,s2]=size(mask);
    output(1:s1,1:s2)=logical(0);
    for i=1:s1
        for j=1:s2
            if(mask(i,j)>threshold),output(i,j)=logical(1);end
        end
    end
end