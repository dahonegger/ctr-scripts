
% add paths to CTR HUB Support Data and GitHub Repository
addpath(genpath('E:\SupportData')) %CTR HUB 
addpath(genpath('C:\Data\CTR\ctr-scripts')) %github repository

% add path to mat files and choose directory for png's   
baseDir = 'E:\DAQ-data\processed\';
saveDir = 'C:\Data\CTR\postprocessed\windAnalysis\';


output_fname = 'ITransects2.mat';

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

save(['C:\Data\CTR\postprocessed\windAnalysis\',fname],'txIMat_full','txDn_full','Rg','-v7.3')
