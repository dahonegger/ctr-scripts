function movieBatchRadar(Cubes,fname,lims,nmean,clims,frames,framerate)

fig = figure;
set(fig,'DoubleBuffer','on');
mov = avifile(['C:\Data\2010MURI\Movies\',fname],'compression','none');

for j = 1:length(Cubes)

if ~exist('frames','var')
    frames = 1:Cubes(j).header.rotations;
elseif isempty(frames)
    frames = 1:Cubes(j).header.rotations;
end
if ~exist('framerate','var')
    framerate = 1;
elseif isempty(framerate)
    framerate = 1;
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

Cubes(j).data = double(Cubes(j).data);

k = 1;

for i = frames(1:end-nmean+1)
    
    if mod(k,framerate)==0
    
    if nmean > 1
        Cubes(j).data(:,:,i) = nanmean(Cubes(j).data(:,:,i:i+nmean-1),3);
    end
    
    pcolorRadar(Cubes(j),1,i,lims);
    
    if nmean == 1
        timeNum = epoch2Matlab(Cubes(j).time(1,i))-datenum([0 0 0 5 0 0]);
        title({'Return Intensity',sprintf('%s EST',datestr(timeNum))})
    else
        timeNum(1) = epoch2Matlab(Cubes(j).time(1,i))-datenum([0 0 0 5 0 0]);
        timeNum(2) = epoch2Matlab(Cubes(j).time(1,i+nmean-1))-datenum([0 0 0 5 0 0]);
        title({sprintf('%.3g s Moving Intensity Mean',...
            Cubes(j).results.RunLength/Cubes(j).header.rotations*nmean),...
            sprintf('%s EST',datestr(mean(timeNum)))})
    end
    xlabel('[m]')
    ylabel('[m]')
    axis(lims)
    caxis(clims)
    set(gcf,'position',[400 100 800 600])
    drawnow
    
    mov = addframe(mov,getframe(fig));
    end
    k = k+1;
end

end

mov = close(mov);