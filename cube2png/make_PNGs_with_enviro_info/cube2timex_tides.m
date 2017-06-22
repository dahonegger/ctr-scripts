function cube2timex(cubeFile,timexFile)

% Originally 'cube2timex.m' by David Honegger 
% Updated by Alex Simpson to show tide, wind, discharge data 

% User options: leave empty [] for Matlab auto-sets
colorAxLimits           = [0 220]; %WILL WANT TO UPDATE FOR BAD DATA PERIODS (~May 28-30)
axisLimits              = [-6 6 -6 6]; % Full, In kilometers
% axisLimits              = [-3 3 -3 1]; % Zoom, In kilometers
plottingDecimation      = [5 1]; % For faster plotting, make this [2 1] or higher

% User overrides: leave empty [] otherwise
userHeading             = [];                      % Use this heading instead of results.heading
userOriginXY            = [0 0];                    % Use this origin for meter-unit scale
userOriginLonLat        = [-72.343472 41.271747];   % Use these lat-lon origin coords

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load radar data
% load(cubeFile,'Azi','Rg','results','data','timeInt')
load(cubeFile,'Azi','Rg','results','timex','timeInt') % 6/16/17 with new process scheme, 'timex' available
% [a, MSGID] = lastwarn();warning('off', MSGID);
if ~exist('timex','var') || isempty(timex)
    load(cubeFile,'data')
    timex = double(nanmean(data,3));
else
end
    
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

% Convert to world coordinates
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = xdom + x0;
ydom = ydom + y0;

% Compute timex
% timex = nanmean(data,3); %6/16/17 no longer need to do 

nowTime = epoch2Matlab(nanmean(timeInt(:))); % UTC
if nowTime < datenum(2017,05,26,20,0,0)
    colorAxLimits = [10 125]; % for before uniform brighness increase
elseif nowTime >= datenum(2017,05,26,20,0,0) && nowTime < datenum(2017,05,29,20,0,0)
    colorAxLimits = [25 190];
elseif nowTime >= datenum(2017,05,29,20,0,0) && nowTime < datenum(2017,05,31,0,0,0)
    return
else
end

% Load tidal data
[yCurrent.RB dnCurrent.RB] = railroadBridgeCurrent; % Railroad Bridge 
[nowIndex.RB nowIndex.RB] = min(abs(dnCurrent.RB - nowTime));
dirEbb.RB = 198; %deg True
dirFlood.RB = 0; %deg True
latCurrent.RB = 41.3167; %N
lonCurrent.RB = 72.3462; %W

[yCurrent.SMR dnCurrent.SMR] = sixMileReefCurrent; % Six Mile Reef 
[nowIndex.SMR nowIndex.SMR] = min(abs(dnCurrent.SMR - nowTime));
dirEbb.SMR = 40; %deg True
dirFlood.SMR = 235; %deg True
latCurrent.SMR = 41.1805; %N
lonCurrent.SMR = 72.4483; %W

[yCurrent.CP dnCurrent.CP] = cornfieldPointCurrent; % Cornfield Point 
[nowIndex.CP nowIndex.CP] = min(abs(dnCurrent.CP - nowTime));
dirEbb.CP = 94; %deg True
dirFlood.CP= 256; %deg True
latCurrent.CP = 41.215; %N
lonCurrent.CP = 72.3733; %W

% Elevation (no longer using...)
% [yElev.SB dnElev.SB] = railroadBridgeElevation; % Saybrook Points (UTC)

% Load mooring data
moor = load('casts_deploy_lisbuoys_065781_20170519_1302.mat');
[moorN moorE] = lltoUTM(moor.latcast, moor.loncast);
[radN radE] = lltoUTM(userOriginLonLat(2), userOriginLonLat(1));
moorX = moorE - radE;
moorY = moorN - radN; 
% moor2 = load('nav_ctriv_deploy_may2017.mat'); %the other file... 
   
% Load wind data from wind station file
% [dnWind,magWind,dirWind] = loadWindStation('SABC3.csv', nowTime); 
[dnWind,magWind,dirWind] = loadWindNDBC('MetData_NDBC44039.txt', nowTime);

% Load discharge data from USGS file
[dnDischarge,rawDischarge,trDischarge] = loadDischargeUSGS(fullfile('E:\','SupportData','Discharge','CTdischarge_Site01193050.txt'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup
fig = figure('visible','off');
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12.8 7.2];
fig.Units = 'pixels';
fig.Position = [0 0 1280 720];
axRad = axes('position',[-0.1081    0.1167    0.7750    0.8150]);
axTide = axes('position',[0.5419    0.7269    0.4200    0.2053],'fontsize',8);
axWind = axes('position',[0.6696    0.4000    0.1544    0.2547],'fontsize',8);
axDischarge = axes('position',[0.5452    0.1358    0.4169    0.2011],'fontsize',8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RADAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axRad)
di = plottingDecimation(1);
dj = plottingDecimation(2);
pcolor(xdom(1:di:end,1:dj:end)/1e3,ydom(1:di:end,1:dj:end)/1e3,...
    timex(1:di:end,1:dj:end));
hold on
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
axRad.XTick = axRad.XTick(1):0.5:axRad.XTick(end);
axRad.YTick = axRad.YTick(1):0.5:axRad.YTick(end);
xlabel('[km]','fontsize',14,'interpreter','latex')
ylabel('[km]','fontsize',14,'interpreter','latex')
axRad.TickLabelInterpreter = 'latex';
runLength = timeInt(end,end)-timeInt(1,1);
titleLine1 = sprintf('\\makebox[4in][c]{Lynde Point X-band Radar: %2.1f min Exposure}',runLength/60);
titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(epoch2Matlab(nanmean(timeInt(:))),'yyyy-mmm-dd HH:MM:SS'),datestr(epoch2Matlab(nanmean(timeInt(:)))-4/24,'HH:MM:SS'));
% titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(nowTime+4/24,'yyyy-mmm-dd HH:MM:SS'),datestr(nowTime,'HH:MM:SS'));
title({titleLine1,titleLine2},...
'fontsize',14,'interpreter','latex');
%add mooring plots
plot(moorX/1000,moorY/1000,'^c','linewidth',1.5,'markersize',8.5,'MarkerFaceColor','none') 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TIDE DIRECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axRad); hold on;
arScale = 1.8;
arRef1 = 0.5.*arScale; %0.5 m/s reference length
arRef2 = 0.15.*arScale; % side bar width on reference 
arW = .5; arH = 2;
% CP and RB base coordinates (km)
arX.RB = 2.15; arY.RB = 3.4;
arX.CP = arX.RB; arY.CP = arY.RB;


% make background
theta = linspace(0,2*pi,200); 
[circle1X, circle1Y] = pol2cart(theta,arRef1); % .5 m/s
[circle2X, circle2Y] = pol2cart(theta,arRef1.*2); % 1 m/s
% [circle3x, circle3Y] = pol2cart(theta,arRef1.*3); % 1.5 m/s
circle1 = fill(circle1X+arX.RB,circle1Y+arY.RB,'white');
alpha(circle1,0.85)
circle2 = fill(circle2X+arX.RB,circle2Y+arY.RB,'white');
alpha(circle2,0.75)
% circle3 = fill(circle3x+arX.RB,circle3Y+arY.RB,'white');
% alpha(circle3,0.5)
refText1 = text(arX.RB+arRef1./2.5,arY.RB+arRef1./2.5,'0.5');
set(refText1,'rotation',-45,'interpreter','latex','horizontalalignment','center','verticalalignment','bottom')
refText2 = text(arX.RB+arRef1,arY.RB+arRef1,'1 m/s');
set(refText2,'rotation',-45,'interpreter','latex','horizontalalignment','center','verticalalignment','bottom')
% refText3 = text(arX.RB+1.78.*arRef1,arY.RB+1.78.*arRef1,'1.5');
% set(refText3,'rotation',-45,'interpreter','latex','horizontalalignment','center','verticalalignment','bottom')

% make CP scale bars
plot([arX.CP-arRef1 arX.CP+arRef1],[arY.CP arY.CP],'-k','linewidth',1)
% plot([arX.CP-arRef1 arX.CP-arRef1],[arY.CP+arRef2 arY.CP-arRef2],'-k','linewidth',1)
% plot([arX.CP+arRef1 arX.CP+arRef1],[arY.CP+arRef2 arY.CP-arRef2],'-k','linewidth',1)

% make RB scale bar
plot([arX.RB arX.RB],[arY.RB-arRef1 arY.RB+arRef1],'-k','linewidth',1)
% plot([arX.RB-arRef2 arX.RB+arRef2],[arY.RB+arRef1 arY.RB+arRef1],'-k','linewidth',1)
% plot([arX.RB-arRef2 arX.RB+arRef2],[arY.RB-arRef1 arY.RB-arRef1],'-k','linewidth',1)

% direction current in sound (Cornfield Point "CP") - GREEN
arLength.CP = yCurrent.CP(nowIndex.CP).*arScale;
scaleWidth.CP = min(abs(yCurrent.CP(nowIndex.CP)),0.5).*17;
scaleLength.CP = min(abs(yCurrent.CP(nowIndex.CP)),0.5).*40;
scaleBaseangle.CP = min(abs(yCurrent.CP(nowIndex.CP)),0.5).*90;
scaleTipangle.CP = min(abs(yCurrent.CP(nowIndex.CP)),0.5).*50;

ar1w = arrow([arX.CP arY.CP],[arX.CP-arLength.CP arY.CP],'width',...
    scaleWidth.CP,'length',scaleLength.CP,'baseangle',scaleBaseangle.CP,...
    'tipangle',scaleTipangle.CP,'facecolor','white','edgecolor','black');

ar1 = arrow([arX.CP arY.CP],[arX.CP-arLength.CP arY.CP],'width',...
    scaleWidth.CP,'length',scaleLength.CP,'baseangle',scaleBaseangle.CP,...
    'tipangle',scaleTipangle.CP,'facecolor','green','edgecolor','black');

alpha(ar1,0.3)


% direction current in river (railroad bridge "RB") - BLUE
arLength.RB = arScale.*yCurrent.RB(nowIndex.RB);
scaleWidth.RB = min(abs(yCurrent.RB(nowIndex.RB)),0.5).*15;
scaleLength.RB = min(abs(yCurrent.RB(nowIndex.RB)),0.5).*40;
scaleBaseangle.RB = min(abs(yCurrent.RB(nowIndex.RB)),0.5).*90;
scaleTipangle.RB = min(abs(yCurrent.RB(nowIndex.RB)),0.5).*50;

ar2 = arrow([arX.RB arY.RB],[arX.RB arY.RB+arLength.RB],'width',...
    scaleWidth.RB,'length',scaleLength.RB,'baseangle',scaleBaseangle.RB,...
    'tipangle',scaleTipangle.RB,'facecolor','blue','edgecolor','black');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TIDE SIGNAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axTide)
cla(axTide)
hold(axTide,'on')
h1=plot([nowTime-2 nowTime+2],[0 0],'-','color',[.75 .75 .75]);
h2=plot([nowTime nowTime],[-10 10],'-','color',[.5 .5 .5],'linewidth',2);
xlim([nowTime-1 nowTime+1])
set(axTide,'xtick',fix([nowTime-1:nowTime+1]))
set(axTide,'xticklabel','')
datetick('x','mmm-dd','keeplimits','keepticks')    
hy1 = ylabel('Current [m/s]','fontsize',11,'interpreter','latex');
tmp1 = get(hy1,'position');
set(hy1,'position',[tmp1(1)+1/50 tmp1(2:3)])
ylim([-1.82 1.82])
title([datestr(nowTime,'HH:MM:SS'),' UTC'],'fontsize',14,'interpreter','latex')
axTide.TickLabelInterpreter = 'latex';
    
% velocity current in sound (Cornfield Point "CP")
    h3=area(dnCurrent.CP,yCurrent.CP,'facecolor','green');
    alpha(0.25)
    
% velocity current in river (railroad bridge "RB")
    h4=area(dnCurrent.RB,yCurrent.RB,'facecolor','blue');
    
legTide = legend([h3 h4],{'Sound','River'});
set(legTide,'position',[0.4469 0.8786 0.0539 0.0418])
box on

% yyaxis right %elevation
%     plot(dnElev.SB,yElev.SB-(2.925-2.368),'-k','linewidth',1) % converting from MLLW (2.368m) to MSL (2.925) ref to NAVD
%     hy2 = ylabel('Elevation [m]','fontsize',11,'interpreter','latex');
%     tmp2 = get(hy2,'position');
%     set(hy2,'position',[tmp2(1)-1/90 tmp2(2:3)])
%     set(gca,'ycolor','black')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WIND %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axWind);
cla(axWind)
% Create Circle
th = 0:0.01:3*pi;
xcircle = cos(th);
ycircle = sin(th);
plot(axWind,xcircle,ycircle,'-k','linewidth',1.25);hold on
% plot(axWind,.75*xcircle,.75*ycircle,'-','color',[.5 .5 .5],'linewidth',1.25)
axis image;axis([-1.05 1.05 -1.05 1.05])
[uWind vWind] = pol2cart((90-dirWind)*pi/180, 1); 
arrow([uWind vWind],[0 0],'baseangle',45,'width',magWind,'tipangle',25,'facecolor','red','edgecolor','red');
[uText vText] = pol2cart((90-180-dirWind)*pi/180,0.28); %position text off tip of arrow
text(uText,vText,[num2str(round(magWind,1)),' m/s'],'horizontalalignment','center','interpreter','latex')
set(axWind,'xtick',[],'ytick',[],'xcolor','w','ycolor','w')
title('Wind','fontsize',14,'interpreter','latex')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISCHARGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axDischarge)
cla(axDischarge)
hold(axDischarge,'on')
% plot(dnDischarge,rawDischarge,'-k','linewidth',2) % plots raw discharge
plot(dnDischarge(~isnan(rawDischarge)),rawDischarge(~isnan(rawDischarge)),'-b','linewidth',1)
plot(dnDischarge(~isnan(trDischarge)),trDischarge(~isnan(trDischarge)),'-k','linewidth',2)
plot([nowTime nowTime],[min(rawDischarge)-3000 max(rawDischarge)+3000],'-','color',[.5 .5 .5],'linewidth',2);
xlim([nowTime-4 nowTime+4])
ylim([min(rawDischarge)-3000 max(rawDischarge)+3000])
set(axDischarge,'xtick',fix([nowTime-4:nowTime+4]))
datetick('x','mmm-dd','keeplimits','keepticks')    
hy1 = ylabel('Discharge [m$^3$/s]','fontsize',11,'interpreter','latex');
% tmp1 = get(hy1,'position');
% set(hy1,'position',[tmp1(1)+1/50 tmp1(2:3)])
disLeg = legend('Raw','Tidally Filtered','orientation','horizontal');
set(disLeg,'position',[0.8310    0.3063    0.1267    0.0240])
box on
title('Discharge','fontsize',14,'interpreter','latex')
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE & CLOSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print(fig,'-dpng','-r100',timexFile)
close(fig)
