% Script: bwlabel_example.m
% Author: Peter Blossey, pblossey@u.washington.edu
% Purpose: Demonstrate use of bwlabel and regionprops in MATLAB
%          to count discrete patches or blobs and compute their
%          properties, e.g. their areas and centroids.
% Written: April 2008.

clear all; close all % clean up work space

% set up a bunch of gaussians, with differing half-widths, as the blobs.

[X,Y] = meshgrid([0:100],[0:100]); % define grid

N = 10; % number of gaussian humps

% define x and y locations of gaussian humps and their radii.
x0 = floor(100*rand(1,N));
y0 = floor(100*rand(1,N));
r0 = 1+floor(9*rand(1,N));

% define R matrix as sum of these gaussian humps.
R = zeros(size(X));
for n = 1:length(x0)
  R = R + exp(-( (X-x0(n)).^2 + (Y-y0(n)).^2 )/2/r0(n).^2);
end
% subtract away mean from R.
R = R - mean(mean(R));

% define zero as the threshold for identifying a blob.
TOL = 0.0;

% set up RL matrix which is one where R>TOL and zero elsewhere.
RL = zeros(size(R));
RL(find(R>TOL)) = 1;

% Call bwlabel -- this idenitifies and counts that blobs.
%   Note that the second argument indicates whether blobs are
%   considered contiguous if they share an edge (if the value is
%   four) or if they share either an edge or a corner (if the value
%   is eight).
RLL = bwlabel(RL,4);

% Use regionprops to compute the properties of the blobs.
stats = regionprops(RLL,'Area','Centroid');

% write out the list of blobs and their properties
for n = 1:length(stats)
  disp(sprintf('Blob number = %d, Area = %g, Centroid = (%g, %g)',...
               n,stats(n).Area,stats(n).Centroid))
end

% make a plot of the three matrices: R, RL and RLL.
figure(10); clf

subplot(221); pcolor(R); shading flat; colorbar; ...
    title('This is the matrix R');
subplot(222); pcolor(RL); shading flat; colorbar; ...
    title('This is the matrix RL');
subplot(223); pcolor(RLL); shading flat; colorbar; ...
    title('This is the matrix RLL');