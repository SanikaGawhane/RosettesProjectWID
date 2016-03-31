function[]=saveImages(pathname,filename,temp,mask)
    savePath=fullfile(pathname,[filename(1:end-5) 'mean.tif']);
    imwrite(uint8(255*temp),savePath);

    savePath=fullfile(pathname,[filename(1:end-5) 'mask.tif']);
    imwrite(mask,savePath);

    savePath=fullfile(pathname,[filename(1:end-5) 'filtered_image.tif']);
    filtered_image=double(mask).*temp;
    imwrite(filtered_image,savePath);
end