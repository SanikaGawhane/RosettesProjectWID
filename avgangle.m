function [avg_angle] = avgangle(angle1,angle2)
s1=size(angle1,1);
sum=0;count=0;
for i=1:s1
    if(angle2(i,1)~=0)
        temp=min(abs(angle1(i,1)-angle2(i,1)),180-abs(angle1(i,1)-angle2(i,1)));
       sum=sum+temp;
%        sprintf('%f %f\n',angle1(i,1),angle(i,2));
%         display(angle1(i,1));
%         display(angle2(i,1));
%         display(temp);
count=count+1;
    end
end
avg_angle = sum/count;

end
