 function[distance]=distanceFromLine(x1,x2,y1,y2,x0,y0)
       num=(y2-y1)*x0-(x2-x1)*y0+x2*y1-y2*x1;
       den=sqrt((y2-y1)^2+(x2-x1)^2);
       distance=num/den;
    end