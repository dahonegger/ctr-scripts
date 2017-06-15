% function to plot in plan view using pcolor the R-theta maps
% Currently hard coded to plot the time exposure. Pass the structure to get
%all the relevant data.
%
%function []=PlotPlanView(this,framebyframe)
%
% Pass framebyframe=-1 to make a movie, otherwise ask for a given frame
% number
%
% Patricio Catalan, May 2008.
function []=PlotPlanView(this,framebyframe)

%% first, retrieve some parameters
Heading=this.results.heading;
%% Convert to polar and cartesian
r=this.Rg; %ground range
%average Azimuths, in radians, in Matlab space but with Y axis horizontal
tht=(90-Heading-this.Azi)*pi/180; 

%[R,T]=meshgrid(r,tht(:,1));
[R,T]=meshgrid(r,tht(:,1)+3*pi/4);%David tweak
[X,Y]=pol2cart(T',R');

%% now plot

figure

if nargin==2
    if framebyframe==-1       
    for jj=1:this.header.rotations
        a=double(squeeze(this.data(:,:,jj)));
        pcolor(Y+this.results.YOrigin,X+this.results.XOrigin,a);shading interp;axis equal tight;set(gca,'XDir','reverse');caxis([0 255]);drawnow;
    end
    else
        a=double(squeeze(this.data(:,:,framebyframe)));
        pcolor(Y+this.results.YOrigin,X+this.results.XOrigin,a);shading interp;axis equal tight;set(gca,'XDir','reverse');caxis([0 255]);drawnow;
    end
else
    a=double(this.timex);
   % polar(pi,1500);hold on
    pcolor(Y+this.results.YOrigin,X+this.results.XOrigin,a);shading interp;axis equal tight;set(gca,'XDir','reverse');caxis([0 255]);drawnow;
    title(['Heading ',num2str(Heading)]);
end

%plot the pier
%hold on;plot(516*ones(size([31:591.3])),[31:591.3],'g','linewidth',2)
