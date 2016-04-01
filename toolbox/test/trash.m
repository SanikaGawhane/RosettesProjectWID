%trash script
%if(xc-x(i)<=0 & yc-y(i)>=0)%%%the comparing points are wrong. Correct these and then proceed
%                angle2(i)=theta;%quad=1;
%            elseif(xc-x(i)>0 & yc-y(i)>=0)
%                angle2(i)=pi+theta;%quad=2;
%            elseif(xc-x(i)>=0&yc-y(i)<0)
%                angle2(i)=theta+2*pi;%quad=4;
%            elseif(xc<0&yc<0)
%                angle2(i)=pi+theta;%quad=3;
%            end
%            if(angle2(i)>2*pi),angle2(i)=angle2(i)-2*pi;
%            end
           