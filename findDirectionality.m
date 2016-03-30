function[theta]=findDirectionality(image)
%   options should be - surf, PCA etc
    image = rgb2gray(image);figure;imagesc(image);
%   image = transpose(image);figure;imagesc(image);
    theta = 0;
    [Gmag, Gdir] = imgradient(image,'prewitt');
    figure;imagesc(Gdir);
    [ri ci]=size(image);
    num_pix=ri*ci;
    sumi=0;
    for gd=1:num_pix
        sumi = sumi+Gdir(gd);
    end
    theta = sumi/num_pix;
    theta = theta*180/pi;
    %     theta = directions();
end