function movieRadar(Cube,fname,lims,nmean,clims,frames,framerate)

if ~exist('frames','var')
    frames = 1:Cube.header.rotations;
elseif isempty(frames)
    frames = 1:Cube.header.rotations;
end
if ~exist('framerate','var')
    framerate = 0;
elseif isempty(framerate)
    framerate = 0;
end


if ~exist('lims','var')
    lims = 'image';
elseif isempty(lims)
    lims = 'image';
end
if ~exist('clims','var')
    lims = 'auto';
elseif isempty(clims)
    lims = 'auto';
end

fig = figure;
set(fig,'DoubleBuffer','on');
mov = avifile(['C:\Data\2010MURI\Movies\',fname],'compression','none');

Cube.data = double(Cube.data);

for i = frames(1:end-nmean+1)
%     Cube2 = Cube;
%     Cube2.data = [];
    if nmean > 1
        Cube.data(:,:,i) = nanmean(Cube.data(:,:,i:i+nmean-1),3);
    end
%     Cube2.data = nanmean(Cube.data(:,:,i:i+nmean),3);
    
    pcolorRadar(Cube,1,i,lims);
    
    if nmean == 1
        title({'Return Intensity',sprintf('%s EST',...
                datestr(epoch2Matlab(Cube.time(1,i))-datenum([0 0 0 5 0 0])))})
    else
        title({sprintf('%.2g s Moving Intensity Mean',...
            Cube.results.RunLength/Cube.header.rotations*nmean),...
            sprintf('%s EST',...
            datestr(epoch2Matlab(Cube.time(1,i))-datenum([0 0 0 5 0 0])))})
    end
%     title(sprintf('Return Intensity, %.1f s',(i-1)*60/Cube.results.TrueRPM))
    xlabel('[m]')
    ylabel('[m]')
    axis(lims)
    caxis(clims)
    set(gcf,'position',[200 100 800 600])
    drawnow
    
    mov = addframe(mov,getframe(fig));
        
end

mov = close(mov);
% 
% map = jet;
% mpgwrite(M,map,fname,[1 2 1 1 10 8 10 25])
    
%    
% if isfield(Cube,'Azi')
%     Heading = Cube.results.heading;
%     r = Cube.Rg;
% %   Subtract heading and convert Azimuth (degrees) to theta (radians). The 90
% %   degree shift is because pol2cart wants to define North along +x-axis
%     tht = (90-Heading-Cube.Azi) * pi/180;
%     [R,T]=meshgrid(r,tht(:,1));
%     [X,Y]=pol2cart(T',R');
%     Xdata = X+Cube.results.XOrigin;
%     Ydata = Y+Cube.results.YOrigin;
% else
%     Xdata = Cube.xdom;
%     Ydata = Cube.ydom;
% end
% 
% if ~exist('domain','var')
%     disp('domain not included')
%     domain = [min(min(Xdata)) max(max(Xdata)) min(min(Ydata)) max(max(Ydata))];
% elseif isempty(domain)
%     disp('domain left empty')
%     domain = [min(min(Xdata)) max(max(Xdata)) min(min(Ydata)) max(max(Ydata))];
% end

% 
% for i = frames
%     signal = double(squeeze(Cube.data(:,:,i)));
%     h = pcolor(Xdata/1000,Ydata/1000,signal);
%     shading interp;axis equal;
%     axis(lims)
%     title(sprintf('Return Intensity, %.1f s',(i-1)*60/Cube.results.TrueRPM))
%     xlabel('[m]')
%     ylabel('[m]')
%     set(gcf,'position',[200 200 800 600])
%     drawnow
%     
%     M(:,i) = getframe(gcf);
%         
% end
% 
% map = jet;
% mpgwrite(M,map,fname)