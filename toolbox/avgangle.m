function [avg_angle] = avgangle(angle1,angle2)
s1=size(angle1,2);
sum=0;count=0;
for i=1:s1
    if(angle1(1,i)~=0)
        temp=min(abs(angle1(1,i)-angle2(1,i)),180-abs(angle1(1,i)-angle2(1,i)));
       sum=sum+temp;
       count=count+1;
    end
end
avg_angle = sum/count;
%if isnan(avg_angle)
end
