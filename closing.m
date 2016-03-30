function [imout]=closing(image,mask,num_ops)
    % morphological image processing operation - closing
    %input - image- image to be closed
    % mask - mask used for closing
    % num_ops- number of time dilation is done before the same number of
    % erosion operation is done. default value of number is 1
    if(nargin==2),num_ops=1;end
    imout=image;
    figure;
    subplot(121);imagesc(image);
    se=strel('disk',5);
    
    %removing fibrous things
    subops=2;
    for i=1:subops
         imout=imerode(imout,se);
        subplot(122);imagesc(imout);
        %pause(1);
    end
    for i=1:subops
         imout=imdilate(imout,se);
        subplot(122);imagesc(imout);
%         pause(1);
    end
    
    
    for i=1:num_ops
        imout=imdilate(imout,se);
        subplot(122);imagesc(imout);
%         pause(1);
    end
       
    for i=1:num_ops
        imout=imerode(imout,se);
        subplot(122);imagesc(imout);
%        pause(1);
    end
    
end