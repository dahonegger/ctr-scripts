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

load('ITransects3.mat')

smooth_size = 10; %for smoothing NDBC, OSU, and Intensity transect along "puff" range

%% LOAD NDBC WIND SENSOR DATA
if downloadWind;fetchWindNDBC(44039,fullfile('E:\','SupportData','Wind'),'MetData_NDBC44039.txt'); end 

[NDBCdnWind,NDBCmagWind,NDBCdirWind] = loadWindNDBC('MetData_NDBC44039.txt');

windex = find(NDBCdnWind==0); %remove down times
NDBCdnWind(windex)=[];NDBCmagWind(windex)=[];NDBCdirWind(windex)=[];

NDBCmagWind = smooth(NDBCmagWind,smooth_size,'rloess');
NDBCdirWind = smooth(NDBCdirWind,smooth_size,'rloess');

% N component
NDBCvWind = -1.*NDBCmagWind.*cosd(NDBCdirWind);
NDBCvWind = smooth(NDBCvWind,smooth_size,'rloess');

%% LOAD OSU WIND SENSOR DATA
baseDir = 'E:\DAQ-data\wind\raw\';
dayFolder = dir([baseDir,'2017*']);

FFTdnWind = [];
FFTmagWind = [];
FFTdirWind = [];

for iDay = 1:length(dayFolder)
    directory_name = fullfile('E:\','DAQ-data','wind','raw',dayFolder(iDay).name);
    files = dir(directory_name);
    fileIndex = find(~[files.isdir]);
    for iRun = 1:length(fileIndex)
        
        fileName = files(fileIndex(iRun)).name;
        
        wind = loadFTTechLog(fullfile(directory_name,fileName));
        
        FFTdnWind = horzcat(FFTdnWind,wind.dateNum);
        FFTmagWind = horzcat(FFTmagWind,wind.speed);
        FFTdirWind = horzcat(FFTdirWind,wind.direction);
        
    end     
end

% smooth OSU Sensor Wind
FFTmagWind = smooth(FFTmagWind,smooth_size,'rloess');
FFTdirWind = smooth(FFTdirWind,smooth_size,'rloess');

FFTvWind = -1.*FFTmagWind.*cosd(FFTdirWind);
FFTvWind = smooth(FFTvWind,smooth_size,'rloess');

%% LOAD TIDES

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

% [tideHr,tideNum] = tideHourMaxEbb(txDn_full,dnCurrent.CP,yCurrent.CP,'false');
TideDN = tideHrMaxEbb2dn(0,dnCurrent.CP,yCurrent.CP);

%% MAKE PLOTS
% INITIALIZE PLOTS
fig = figure;
figname = 'Intensity_Transects_Wind_Comparison';
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12.8 7.2];
fig.Units = 'pixels';
fig.Position = [0 0 880 720];

axIntensity = axes('position',[0.0690    0.6256    0.8191    0.3633]);
axWindDir = axes('position',[0.0690    0.4200    0.8191    0.1688]);
axWindMag = axes('position',[0.0690    0.2311    0.8191    0.1688]);
axWindN = axes('position',[0.0690    0.0378    0.8191    0.1744]);

% Intensity
[txDn_full,I] = sort(txDn_full);
txIMat_full = txIMat_full(:,I);
txIMat_full = txIMat_full(:,txDn_full > 0);
txDn_full = txDn_full(txDn_full > 0);

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
ylabel('Range [m]','interpreter','latex','fontsize',14)
set(axIntensity,'xgrid','on','gridcolor','white')

% Wind Direction

set(fig,'currentaxes',axWindDir);
hold on
plot(NDBCdnWind,NDBCdirWind,'.k') %NDBC 
plot(FFTdnWind,FFTdirWind,'.r') %OSU SENSOR
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
ylabel('Wind Direction [$^o$]','interpreter','latex','fontsize',14)
set(axWindDir,'xgrid','on','gridcolor','black')

%Wind Magnitude
set(fig,'currentaxes',axWindMag);
hold on
plot(NDBCdnWind,NDBCmagWind,'.k') %NDBC
plot(FFTdnWind,FFTmagWind,'.r') %OSU SENSOR 
xlim([min(txDn_full) max(txDn_full)])
datetick('x','keeplimits')
axWindMag.TickLabelInterpreter = 'latex';
ylabel('Wind Speed [m/s]','interpreter','latex','fontsize',14)
grid on
set(axWindMag,'xticklabel','')

%Wind N Component
set(fig,'currentaxes',axWindN);
hold on
plot(NDBCdnWind,NDBCvWind,'.k') %NDBC
plot(FFTdnWind,FFTvWind,'.r') %OSU SENSOR
plot([min(txDn_full) max(txDn_full)],[0 0],'-k') 
xlim([min(txDn_full) max(txDn_full)])
axWindN.TickLabelInterpreter = 'latex';
datetick('x','keeplimits')
ylabel({'N component','of Wind [m/s]'},'interpreter','latex','fontsize',14)
grid on


%% Zoom plot w/ tide
%get transect over time at range of interest (e.g. stationary bathy
%signature)

RangeOfInterest = 4300;
[idx idx] = min(abs(Rg-RangeOfInterest));
RangeIndices = [idx-7:1:idx+7];

Irange_subset = nanmean(txIMat_full(RangeIndices,:),1);
Irange_subset_smooth = smooth(Irange_subset,smooth_size,'rloess');


fig2 = figure;
figname2 = 'Zoom_Intensity_Transects_Wind_Comparison';
fig2.PaperUnits = 'inches';
fig2.PaperPosition = [0 0 12.8 7.2];
fig2.Units = 'pixels';
fig2.Position = [0 0 880 720];


axIntensity2 = axes(fig2,'position',[0.0690    0.5133    0.8191    0.4656]);
% axTide = axes(fig2,'position',[0.0690    0.2778    0.8184    0.1744]);
axTide = axes(fig2,'position',[0.0690    0.5967    0.8191    0.1744]);
axWindN2 = axes('position',[0.0690    0.2622    0.8191    0.1944]);

[T, R] = meshgrid(txDn_full,Rg);

% INTENSITY
set(fig2,'currentaxes',axIntensity2)
hold on
pcolor(txDn_full,Rg,txIMat_full)
plot(T(RangeIndices(1),:),R(RangeIndices(1),:),'--w')
plot(T(RangeIndices(end),:),R(RangeIndices(end),:),'--w')
shading interp
colormap hot 
ylim([3800 4800])
xlim([min(txDn_full) max(txDn_full)])
set(axIntensity2,'xticklabel',[])
datetick('x','keeplimits','keepticks')
% c=colorbar;
caxis([5 80])
ylabel('Range [m]','interpreter','latex','fontsize',14)
grid on
axIntensity2.TickLabelInterpreter = 'latex';

% TIDE
set(fig2,'currentaxes',axTide)
cla(axTide)
hold(axTide,'on')
xlim([min(txDn_full) max(txDn_full)])
datetick('x','mmm-dd','keeplimits','keepticks')    
hy1 = ylabel('Current [m/s]','fontsize',11,'interpreter','latex','fontsize',14);
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
yyaxis left
plot(NDBCdnWind,NDBCvWind,'.k')
plot(FFTdnWind,FFTvWind,'.b')
plot(TideDN,zeros(size(TideDN)),'.b')
plot([min(txDn_full) max(txDn_full)],[0 0],'-k') 
ylabel({'N component','of Wind [m/s]'},'interpreter','latex','fontsize',14)

yyaxis right
plot(txDn_full,Irange_subset_smooth,'-r')
xlim([min(txDn_full) max(txDn_full)])
datetick('x','keeplimits')
axWindN2.TickLabelInterpreter = 'latex';
ylim([-80 80])
grid on

%% print figures
% print(fig,'-dpng','-r100',figname)
% print(fig2,'-dpng','-r100',figname2)



