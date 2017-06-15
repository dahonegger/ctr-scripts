close all;clc;clear M
% [Cube]=ReadRawRadarBin(2601715,[0 0 0 0 0],0);
% [Cube]=ReadRawRadarBin(1120815,[0 0 0 0 0],0);
% function to plot in plan view using pcolor the R-theta maps
% Currently hard coded to plot the time exposure. Pass the structure to get
%all the relevant data.
%
%function []=PlotPlanView(Cube,framebyframe)
%
% Pass framebyframe=-1 to make a movie, otherwise ask for a given frame
% number
%
% Patricio Catalan, May 2008.

%% first, retrieve some parameters
Heading=Cube.results.heading;
%% Convert to polar and cartesian
r=Cube.Rg; %ground range
%average Azimuths, in radians, in Matlab space but with Y axis horizontal
tht=(90-Heading-Cube.Azi)*pi/180;

%[R,T]=meshgrid(r,tht(:,1));
rot=3*pi/4;%David tweak: rotates image
[R,T]=meshgrid(r,tht(:,1));
[X,Y]=pol2cart(T',R');

%% now plot & get frames for movie

% Define a zoom box
% za=[620.3    1585.2    0022.3    1152.7];
% za =  1.0e+003 *    [0.2996    1.2872   -1.3586   -0.5400];
% za =  1.0e+003 * [0.2481    1.2357    0.3681    1.1867];
% za =  1.0e+003 *[    0.0546    1.5283   -0.0119    1.4856];
% za =[  109.1974  983.3572  263.0698  987.7372];
za =  1.0e+003 *[    0.0546    0.9858    0.3278    1.1018];
% za='image';

h=figure;
set(h,'position',[100 100 400 500])

% maximize;
% rect=get(h,'Position');
% rect(1:2) = [0 0];
ts=[];
as=[];

k=1;
for i=1:1
for jj=1:Cube.header.rotations-1
    a=double(squeeze(Cube.data(:,:,jj)));
    
    s1=subplot(3,2,[1 2 3 4]);
    hold off
    pcolor(Y+Cube.results.YOrigin,X+Cube.results.XOrigin,a);shading interp;axis(za);set(gca,'XDir','reverse');caxis([0 255]);drawnow;
    hold on;plot(Y(300,225)+Cube.results.YOrigin,X(300,225)+Cube.results.XOrigin,'ok','markerfacecolor','w','markersize',10);set(gca,'XDir','reverse');
    plot(Y(300,225)+Cube.results.YOrigin,X(300,225)+Cube.results.XOrigin,'xk','markersize',10);set(gca,'XDir','reverse');
    xlabel('Dist. from Ant. [m]');ylabel('Dist from Ant. [m]');
    title('Return Intensity')
    s2=subplot(3,2,[5 6]);
    ts=[ts 1/.73*jj];
    as=[as a(300,225)];
    plot(ts,as,'.-k','linewidth',3);
    axis([0 90 0 300])
    hold on
    xlabel('Time [s]');ylabel('Return Intensity')
    
    M(:,k)=getframe(h);
    k=k+1;
end
end

%% Make the movie
% movie(M,1,5)
movie2avi(M,'radarzoom2.avi','fps',5,'compression','none')
