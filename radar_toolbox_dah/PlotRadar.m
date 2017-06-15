function h = PlotRadar(Cube,frame,Heading)


% Heading=Cube.results.heading;
% Heading = 135;
r=Cube.Rg;

% Subtract heading and convert Azimuth (degrees) to theta (radians)
tht = (Cube.Azi+Heading) * pi/180;

[R,T]=meshgrid(r,tht(:,1));
[X,Y]=pol2cart(T',R');

a = double(Cube.data(:,:,frame));
h = pcolor(Y+Cube.results.YOrigin,X+Cube.results.XOrigin,a);
shading interp;
% set(gca,'XDir','reverse');
caxis([0 255]);


end