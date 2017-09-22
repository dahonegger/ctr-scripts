tic
close all; clear all;
% add paths to CTR HUB Support Data and GitHub Repository
addpath(genpath('E:\SupportData')) %CTR HUB 
addpath(genpath('C:\Data\CTR\ctr-scripts')) %github repository

% add path to mat files and choose directory for png's   
baseDir = 'E:\DAQ-data\processed\';
saveDir = 'C:\Data\CTR\postprocessed\windAnalysis\';


% Download new files?
downloadWind = false;


%% Prep files
% make save directory
if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);
% initialize transect matrix & time vector
txIMat_full = zeros(2031,1); % <--- shouldn't be hard coded
txDn_full = 0;

% download environmental files
% WIND: buoy number, save directory, save fname
if downloadWind;fetchWindNDBC(44039,fullfile('E:\','SupportData','Wind'),'MetData_NDBC44039.txt'); end 

%% loop through mat files
for iDay = 13:length(dayFolder)%loop through days
% for iDay = 14:16 %loop through days
        dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));

   for iRun = 1:length(dayFolder(iDay).polRun) %loop through files
% iRun = 1;
        cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
  
%% LOAD TIMEX
load(cubeName,'Azi','Rg','timex','timeInt','results');
if ~exist('timex','var') || isempty(timex)
    load(cubeName,'data')
    timex = double(mean(data,3));
else
end        
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-results.heading);
THdeg = wrapTo360(AZI+results.heading);
[X,Y] = pol2cart(TH,RG);

% choose degrees to average over
desiredStartAngle = 185;
desiredAngles = 1; %degrees 

% grab these angles from intensity
[idx idx] = min(abs(THdeg(1,:) - desiredStartAngle));
angles = [idx:1:idx+desiredAngles./mean(diff(Azi))];


txI = mean(double(timex(:,angles)),2);
% txDnMat = mean(epoch2Matlab(timeInt(angles,:)),1);

txIMat(:,iRun) = txI';
txDn(iRun) = mean(epoch2Matlab(timeInt(:)));



   end

txIMat_full = horzcat(txIMat_full,txIMat);
txDn_full = horzcat(txDn_full,txDn);

end

txIMat_full = txIMat_full(:,2:end);
txDn_full = txDn_full(2:end);

save('C:\Data\CTR\postprocessed\windAnalysis\Itransects.mat','txIMat_full','txDn_full','Rg','-v7.3')

%% MAKE PLOTS
fig = figure;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12.8 7.2];
fig.Units = 'pixels';
fig.Position = [0 0 1080 720];

axIntensity = axes('position',[0.0690    0.5133    0.8191    0.4656]);
axWindDir = axes('position',[0.0690    0.2778    0.8184    0.1744]);
axWindMag = axes('position',[0.0690    0.0533    0.8206    0.1767]);


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
% c=colorbar;
% caxis([10 100])
ylabel('Range [m]','interpreter','latex')
grid on


% Wind Direction
[dnWind,magWind,dirWind] = loadWindNDBC('MetData_NDBC44039.txt');
windex = find(dnWind==0);
dnWind(windex)=[];magWind(windex)=[];dirWind(windex)=[];
set(fig,'currentaxes',axWindDir);
hold on
plot(dnWind,dirWind,'.k')
plot([min(txDn_full) max(txDn_full)],[0 0],'-k') 
plot([min(txDn_full) max(txDn_full)],[90 90],'-k') 
plot([min(txDn_full) max(txDn_full)],[180 180],'-k') 
plot([min(txDn_full) max(txDn_full)],[270 270],'-k') 
xlim([min(txDn_full) max(txDn_full)])
datetick('x','keeplimits')
ylabel('Wind Direction [$^o$]','interpreter','latex')
grid on

%Wind Magnitude
set(fig,'currentaxes',axWindMag);
hold on
plot(dnWind,magWind,'.k')
xlim([min(txDn_full) max(txDn_full)])
datetick('x','keeplimits')
ylabel('Wind Speed [m/s]','interpreter','latex')
grid on

% hold on
% pcolor(X,Y,timex); shading interp; colormap hot
% plot(X(:,angles),Y(:,angles),'-c')
toc
