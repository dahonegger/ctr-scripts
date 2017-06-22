close all; clear all;



% add paths to CTR HUB Support Data and GitHub Repository
addpath(genpath('E:\SupportData')) %CTR HUB 
addpath(genpath('C:\Data\CTR\ctr-scripts')) %github repository
addpath(genpath('C:\Data\CTR\postprocessed\windAnalysis'))
addpath(genpath('C:\Data\CTR\supportData'))

% add path to mat files and choose directory for png's   
baseDir = 'E:\DAQ-data\processed\';
saveDir = 'C:\Data\CTR\postprocessed\windAnalysis\';


% Download new files?
downloadWind = false;

% do you want to process new files for this analysis? 
% update and run makeTransectMatrix first 
% makeTransectMatrix
% or load the transect matrix that has been saved
load('Itransects.mat')
%% MAKE PLOTS
fig = figure;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12.8 7.2];
fig.Units = 'pixels';
fig.Position = [0 0 1080 720];

axIntensity = axes('position',[0.0690    0.6256    0.8191    0.3633]);
axWindDir = axes('position',[0.0690    0.4200    0.8191    0.1688]);
axWindMag = axes('position',[0.0690    0.2311    0.8191    0.1688]);
axWindN = axes('position',[0.0690    0.0378    0.8191    0.1744]);


% Intensity
[txDn_full,I] = sort(txDn_full);

txIMat_full = txIMat_full(:,I);

[plotDN,plotRG] = meshgrid(txDn_full,Rg);
set(fig,'currentaxes',axIntensity)
hold on
pcolor(txDn_full(1,1:5:end),Rg,txIMat_full(:,1:5:end))
shading interp
colormap hot 
ylim([0 max(Rg)])
xlim([min(txDn_full) max(txDn_full)])
datetick('x','keeplimits')
axIntensity.TickLabelInterpreter = 'latex';
% c=colorbar;
% caxis([10 100])
ylabel('Range [m]','interpreter','latex')
set(axIntensity,'xgrid','on','gridcolor','white')


% Wind Direction
[dnWind,magWind,dirWind] = loadWindNDBC('MetData_NDBC44039.txt');
windex = find(dnWind==0);
dnWind(windex)=[];magWind(windex)=[];dirWind(windex)=[];
set(fig,'currentaxes',axWindDir);
hold on
plot(dnWind,dirWind,'.k')
% plot([min(txDn_full) max(txDn_full)],[0 0],'-','color',[0.5 0.5 0.5]) 
plot([min(txDn_full) max(txDn_full)],[90 90],'-','color',[0.5 0.5 0.5]) 
plot([min(txDn_full) max(txDn_full)],[180 180],'-','color',[0.5 0.5 0.5]) 
plot([min(txDn_full) max(txDn_full)],[270 270],'-','color',[0.5 0.5 0.5]) 
xlim([min(txDn_full) max(txDn_full)])
datetick('x','keeplimits')
set(axWindDir,'xticklabel','')
axWindDir.TickLabelInterpreter = 'latex';
yticks([0 90 180 270])
ylim([0 360])
ylabel('Wind Direction [$^o$]','interpreter','latex')
set(axWindDir,'xgrid','on','gridcolor','black')

%Wind Magnitude
set(fig,'currentaxes',axWindMag);
hold on
plot(dnWind,magWind,'.k')
xlim([min(txDn_full) max(txDn_full)])
datetick('x','keeplimits')
axWindMag.TickLabelInterpreter = 'latex';
ylabel('Wind Speed [m/s]','interpreter','latex')
grid on
set(axWindMag,'xticklabel','')

%Wind N Component
vWind = -1.*magWind.*cosd(dirWind);
set(fig,'currentaxes',axWindN);
hold on
plot(dnWind,vWind,'.k')
plot([min(txDn_full) max(txDn_full)],[0 0],'-k') 
xlim([min(txDn_full) max(txDn_full)])
axWindN.TickLabelInterpreter = 'latex';
datetick('x','keeplimits')
ylabel({'N component','of Wind [m/s]'},'interpreter','latex')
grid on



%% Zoom plot w/ tide
% Load tidal data
[yCurrent.RB dnCurrent.RB] = railroadBridgeCurrent; % Railroad Bridge 
dirEbb.RB = 198; %deg True
dirFlood.RB = 0; %deg True
latCurrent.RB = 41.3167; %N
lonCurrent.RB = 72.3462; %W

[yCurrent.CP dnCurrent.CP] = cornfieldPointCurrent; % Cornfield Point 
dirEbb.CP = 94; %deg True
dirFlood.CP= 256; %deg True
latCurrent.CP = 41.215; %N
lonCurrent.CP = 72.3733; %W

fig2 = figure;
fig2.PaperUnits = 'inches';
fig2.PaperPosition = [0 0 12.8 7.2];
fig2.Units = 'pixels';
fig2.Position = [0 0 1080 720];


axIntensity2 = axes(fig2,'position',[0.0690    0.5133    0.8191    0.4656]);
% axTide = axes(fig2,'position',[0.0690    0.2778    0.8184    0.1744]);
axTide = axes(fig2,'position',[0.0690    0.5967    0.8191    0.1744]);
axWindN2 = axes('position',[0.0690    0.2622    0.8191    0.1944]);

% INTENSITY
set(fig2,'currentaxes',axIntensity2)
hold on
pcolor(txDn_full(1,1:5:end),Rg,txIMat_full(:,1:5:end))
shading interp
colormap hot 
ylim([3500 5000])
xlim([min(txDn_full) max(txDn_full)])
set(axIntensity2,'xticklabel',[])
datetick('x','keeplimits','keepticks')
% c=colorbar;
caxis([5 80])
ylabel('Range [m]','interpreter','latex')
grid on
axIntensity2.TickLabelInterpreter = 'latex';

% TIDE
set(fig2,'currentaxes',axTide)
cla(axTide)
hold(axTide,'on')
xlim([min(txDn_full) max(txDn_full)])
datetick('x','mmm-dd','keeplimits','keepticks')    
hy1 = ylabel('Current [m/s]','fontsize',11,'interpreter','latex');
tmp1 = get(hy1,'position');
set(hy1,'position',[tmp1(1)+1/50 tmp1(2:3)])
ylim([-1.82 1.82])
% title([datestr(nowTime,'HH:MM:SS'),' UTC'],'fontsize',14,'interpreter','latex')
axTide.TickLabelInterpreter = 'latex';    
% velocity current in sound (Cornfield Point "CP")
    h5=area(dnCurrent.CP,yCurrent.CP,'facecolor','white');
    h3=area(dnCurrent.CP,yCurrent.CP,'facecolor','green');
    alpha(h3,0.25)
% velocity current in river (railroad bridge "RB")
    h4=area(dnCurrent.RB,yCurrent.RB,'facecolor','blue');
set(axTide,'visible','off')    
legTide = legend([h3 h4],{'Sound','River'});
set(legTide,'position',[0.8178    0.5752    0.0706    0.0507])
set(axTide,'color','none')

%Wind N Component
set(fig2,'currentaxes',axWindN2);
hold on
plot(dnWind,vWind,'.k')
plot([min(txDn_full) max(txDn_full)],[0 0],'-k') 
xlim([min(txDn_full) max(txDn_full)])
datetick('x','keeplimits')
axWindN2.TickLabelInterpreter = 'latex';
ylabel({'N component','of Wind [m/s]'},'interpreter','latex')
grid on
