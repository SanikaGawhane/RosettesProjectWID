%distribution=getDistribution(offset,step)
function[distribution]=getDistribution(base,step,numSlices)
    distribution(1:numSlices)=0;
    for i=1:numSlices
       distribution(i)=base-step*abs(i-ceil(numSlices/2));
    end
    distribution=distribution/sum(distribution);
    if(min(distribution)<0),
        distribution=distribution+min(distribution);
        distribution=distribution/sum(distribution);
    end
    figure;plot(distribution);
end