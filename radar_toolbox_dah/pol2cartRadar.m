function [Cube] = pol2cartRadar(Cube)

% This script adds Cube.xdom and Cube.ydom to the input Cube structure,
% assuming initial ReadBin processing was performed with Azimuthal
% Interpolation only. The cartesian domains correspond directly with the
% Cube.Rg and Cube.Azi locations and are therefore not evenly spaced.

Heading = Cube.results.heading;
r = Cube.Rg;
%   Subtract heading and convert Azimuth (degrees) to theta (radians). The 90
%   degree shift is because pol2cart wants to define North along +x-axis
tht = (90-Heading-Cube.Azi) * pi/180;
[R,T]=meshgrid(r,tht(:,1));
[X,Y]=pol2cart(T',R');
Xdata = X+Cube.results.XOrigin;
Ydata = Y+Cube.results.YOrigin;

Cube.xdom = Xdata;
Cube.ydom = Ydata;