function gifRadar(Cube,fname,lims,nmean,clims,framerate,frames)


if ~exist('framerate','var') || isempty(framerate)
    framerate = 1;
end

if ~exist('frames','var') || isempty(frames)
    frames = 1:framerate:Cube.header.rotations;
else
    frames = frames(1):framerate:frames(end);
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
Cube.data = double(Cube.data);
j = 1;
for i = frames(1:end-nmean+1)
%     Cube2 = Cube;
%     Cube2.data = [];

    if nmean > 1
        Cube.data(:,:,i) = nanmean(Cube.data(:,:,i:i+nmean-1),3);
    end
%     Cube2.data = nanmean(Cube.data(:,:,i:i+nmean),3);
    
    pcolorRadar(Cube,1,i,lims);
    
    if nmean == 1
        timeNum = epoch2Matlab(Cube.time(1,i))-datenum([0 0 0 5 0 0]);
        title({'Return Intensity',sprintf('%s EST',datestr(timeNum))})
    else
        timeNum(1) = epoch2Matlab(Cube.time(1,i))-datenum([0 0 0 5 0 0]);
        timeNum(2) = epoch2Matlab(Cube.time(1,i+nmean-1))-datenum([0 0 0 5 0 0]);
        title({sprintf('%.3g s Moving Intensity Mean',...
            Cube.results.RunLength/Cube.header.rotations*nmean),...
            sprintf('%s EST',datestr(mean(timeNum)))})
    end
    
    xlabel('[m]')
    ylabel('[m]')
    axis(lims)
    caxis(clims)
    set(gcf,'position',[200 100 800 600])
    drawnow
    
    f = getframe(fig);
    
    if j == 1
        [im,map] = rgb2ind(f.cdata,256,'dither');
        im(1,1,1,length(frames)) = 0;
    else
        im(:,:,1,j) = rgb2ind(f.cdata,map,'nodither');
    end
    
end

imwrite(im,map,[fname '.gif'],'DelayTime',0,'LoopCount',inf)
