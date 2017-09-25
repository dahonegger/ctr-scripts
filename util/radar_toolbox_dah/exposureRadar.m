function [h] = exposureRadar(Cube,axdiv);
   
if ~exist('axdiv','var')
    axdiv = 1;
elseif strcmp(axdiv,'km')
    axdiv = 1000;
elseif strcmp(axdiv,'m')
    axdiv = 1;
end

if isfield(Cube,'Azi')
    Heading = Cube.results.heading;
    r = Cube.Rg;
%   Subtract heading and convert Azimuth (degrees) to theta (radians). The 90
%   degree shift is because pol2cart wants to define North along +x-axis
    tht = (90-Heading-Cube.Azi) * pi/180;
    [R,T]=meshgrid(r,tht(:,1));
    [X,Y]=pol2cart(T',R');
    Xdata = X+Cube.results.XOrigin;
    Ydata = Y+Cube.results.YOrigin;
else
    Xdata = Cube.xdom;
    Ydata = Cube.ydom;
end

exposure = nanmean(double(squeeze(Cube.data)),3);
pcolor(Xdata/axdiv,Ydata/axdiv,exposure)
shading interp;axis equal
title(sprintf('Exposure: %s',Cube.header.file))