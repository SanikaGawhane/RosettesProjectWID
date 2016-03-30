function[maskResult]=smoothClassifierVotingMask(mask)
    closingMaskSize=6;
    iterations=7;
    closing_mask(1:7,1:7)=logical(1);
    maskResult=closing(mask,closing_mask,6);
    %plotting the boundaries and saving images- starts
    figure;imagesc(maskResult);hold on;
    B=bwboundaries(maskResult);
    for k2 = 1:length(B)
         boundary = B{k2};
         plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);%boundary need not be dilated now because we are using plot function now
    end
    hold off;
end