%converting mask to binary values for processing
mask=mask_backup>=6;
    % filling the mask
closing_mask(1:7,1:7)=logical(1);
mask=closing(mask,closing_mask,6);
figure;imagesc(mask);hold on;

%plotting the boundaries and saving images- starts
B=bwboundaries(mask);
for k2 = 1:length(B)
     boundary = B{k2};
     plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);%boundary need not be dilated now because we are using plot function now
end