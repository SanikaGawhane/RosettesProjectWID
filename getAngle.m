    function[angle]=getAngle(point1,point2,ellipse_boundary)
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
               return; 
           end
          % pause(0.1);
       end
        
    end