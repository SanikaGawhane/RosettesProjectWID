function [tangentAngle] = angle1(boundary)
%%%boundary has the boundary points for mask
bsize=size(boundary);
for i=1:bsize(1)-1
    if (i==1)
    elseif (i==bsize(1))
    else
        x=boundary(i+1,1)-boundary(i,1);
        y=boundary(i+1,2)-boundary(i,2);
        tangentAngle=atan(y/x);
    end
end
end