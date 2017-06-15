function cube2timexZoom(cubeFile,timexFile)

% User options: leave empty [] for Matlab auto-sets
colorAxLimits           = [10 125];
% axisLimits              = [-6 6 -6 6];
axisLimits              = [-3 3 -3 1]; % In kilometers
% radialFalloffHeading    = 90; % Heading to use for empirical range falloff
% falloffSmoothingScale   = 100; % Smoothing scale for empirical falloff so that fronts, etc., get averaged out
plottingDecimation      = [5 1]; % For faster plotting, make this [2 1] or higher

% User overrides: leave empty [] otherwise
userHeading             = 281;                      % Use this heading instead of results.heading
userOriginXY            = [0 0];                    % Use this origin for meter-unit scale
userOriginLonLat        = [-72.343472 41.271747];   % Use these lat-lon origin coords

% Implement user overrides
if ~isempty(userHeading)
    heading = userHeading;
else
    heading = results.heading;
end
if ~isempty(userOriginXY)
    x0 = userOriginXY(1);
    y0 = userOriginXY(2);
else
    x0 = results.XOrigin;
    y0 = results.YOrigin;
end
if ~isempty(userOriginLonLat)
    lon0 = userOriginLonLat(1);
    lat0 = userOriginLonLat(2);
else
    [lat0,lon0] = UTMtoll(results.YOrigin,results.XOrigin,str2double(results.UTMZone(1:2)));
end

% Load data
load(cubeFile,'Azi','Rg','results','data','timeInt')

% Convert to world coordinates
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = xdom + x0;
ydom = ydom + y0;

% Calculate geographic limits
% utmLL = [results.XOrigin
% [latLL,lonLL] = 

% Compute timex
timex = mean(data,3);
% darkest = min(data,[],3);
% darkestFalloff = min(darkest,[],2);
% 
% % Compute radial falloff correction
% if ~isempty(radialFalloffHeading)
% %     radialFalloffAzi = (90-radialFalloffHeading)*pi/180;
% %     dist2FalloffAzi = wrapToPi(TH(end,:)-radialFalloffAzi);
% %     iAzi = find(abs(dist2FalloffAzi)==min(abs(dist2FalloffAzi)));
% %     falloff = smooth(Rg,double(darkest(:,iAzi)),falloffSmoothingScale,'rloess'); % Divided by 3 because scale is in meters and each radial bin is 3 meters
%     falloff = smooth(Rg,double(darkestFalloff),falloffSmoothingScale,'rloess'); % Divided by 3 because scale is in meters and each radial bin is 3 meters
% 
%     timex = timex - repmat(falloff(:),1,size(timex,2));
% end

fig = figure('visible','off');
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12.8 7.2];
fig.Units = 'pixels';
fig.Position = [0 0 1280 720];

    ax = axes;
        di = plottingDecimation(1);
        dj = plottingDecimation(2);
        hp = pcolor(xdom(1:di:end,1:dj:end)/1e3,ydom(1:di:end,1:dj:end)/1e3,timex(1:di:end,1:dj:end));
            shading interp
            axis image
            colormap(hot)
            if ~isempty(axisLimits)
                axis(axisLimits)
            end
            if ~isempty(colorAxLimits)
                caxis(colorAxLimits)
            end
            
            grid on
            ax.XTick = ax.XTick(1):0.5:ax.XTick(end);
            ax.YTick = ax.YTick(1):0.5:ax.YTick(end);
                        
            xlabel('[km]','fontsize',14,'interpreter','latex')
            ylabel('[km]','fontsize',14,'interpreter','latex')
            ax.TickLabelInterpreter = 'latex';
            
            
            runLength = timeInt(end,end)-timeInt(1,1);
            titleLine1 = sprintf('\\makebox[4in][c]{Lynde Point X-band Radar: %2.1f min Exposure}',runLength/60);
            titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(epoch2Matlab(mean(timeInt(:))),'yyyy-mmm-dd HH:MM:SS'),datestr(epoch2Matlab(mean(timeInt(:)))-4/24,'HH:MM:SS'));
            
            title({titleLine1,titleLine2},...
                'fontsize',14,'interpreter','latex');
           
    
%     axLon = axes;
%         axLon.Position = ax.Position;
%         axLon.Color = 'none';
    

print(fig,'-dpng','-r100',timexFile)
close(fig)