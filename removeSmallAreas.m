% removeSmallAreas(mask,areaMin,areaMax);
function[maskResult]=removeSmallAreas(mask,areaMin,areaMax)
    B=bwboundaries(mask);
    figure;
    maskResult=logical(zeros(size(mask)));
    maskResultWrong=logical(zeros(size(mask)));
    for k2 = 1:length(B)
        area=0; 
        boundary = B{k2};
         BW=roipoly(mask,boundary(:,2),boundary(:,1));
         area=sum(double(BW(:)));
         if(area>areaMin&&area<areaMax)
            maskResult=maskResult|BW;
         end
         maskResultWrong=maskResultWrong|BW;
%          subplot(121);imagesc(maskResult);hold on;
%          subplot(122);imagesc(maskResultWrong);hold on;
%          title(num2str(area));
%          pause(1);
    end
end