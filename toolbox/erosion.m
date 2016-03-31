function[imout]=erosion(image,mask)
    mask=logical(mask);image=logical(image);
    % from here on it is assumed that the image and mask both are logical
    % arrays- only 1 or 0
    [s1Image,s2Image]=size(image);[s1Mask,s2Mask]=size(mask);
    imout=logical(zeros([s1Image,s2Image]));
    image=padarray(image,[floor(s1Mask/2) floor(s2Mask/2)]);
    for i=1+floor(s1Mask/2):s1Image+floor(s1Mask/2)
        for j=1+floor(s2Mask/2):s2Image+floor(s2Mask/2)
            sub_image=image(i-floor(s1Mask/2):i+floor(s1Mask/2),j-floor(s2Mask/2):j+floor(s2Mask/2));
            
            temp=sum(mask(:).*sub_image(:));temp=temp/(s1Mask*s2Mask);
            if(temp<1)
               imout(i,j)=logical(0); 
            elseif(temp==1)
                imout(i,j)=logical(1); 
            end
        end
    end
    imout=imout(1+floor(s1Mask/2):s1Image+floor(s1Mask/2),1+floor(s2Mask/2):s2Image+floor(s2Mask/2));
    display('done');
end
