
%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository

% SUPPORT DATA PATH
% supportDataPath = 'D:\Data\CTR\SupportData'; % LENOVO HARD DRIVE
% supportDataPath = 'E:\SupportData'; %CTR HUB 
supportDataPath = 'E:\supportData';

% GITHUB DATA PATH
addpath(genpath('C:\Data\CTR\ctr-scripts')) %GITHUB REPOSITORY


% MAT FILES LOCATION
% baseDir = 'E:\DAQ-data\processed\'; %CTR HUB
% baseDir = 'D:\Data\CTR\DAQ-data\processed\'; % LENOVO HARD DRIVE
% baseDir = 'E:\RadarData\'; %CTR Disk 1 (slim)
baseDir = 'E:\DAQ-data\processed\'; 


% PNG LOCATION
% saveDir = 'E:\PNGs\timex_enviroInfo5\'; % CTR HUB
saveDir = 'C:\Data\CTR\postprocessed\timex_enviroInfo5\'; % LENOVO HARD DRIVE

% rewrite existing files in save directory? true=yes
doOverwrite = false;

% Download new support data files?
downloadWind = false;
downloadDischarge = false;

%% Prep files
% make save directory
addpath(genpath(supportDataPath)) 

if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

% download environmental files
% WIND: buoy number, save directory, save fname
if downloadWind;fetchWindNDBC(44039,fullfile(supportDataPath,'Wind'),'MetData_NDBC44039.txt'); end 
% DISCHARGE: save directory, save fname 
if downloadDischarge; fetchDischargeUSGS(fullfile(supportDataPath,'Discharge'),'CTdischarge_Site01193050.txt');end

%% Process Files 
imgId = 1;
for iDay = 1:length(dayFolder)
        
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    saveDirSub = [saveDir,dayFolder(iDay).name];
    if ~exist(saveDirSub);mkdir(saveDirSub);end
    
        for iRun = 1:length(dayFolder(iDay).polRun)
            
            fprintf('%3.f of %3.f in dir %3.f of %3.f: ',...
                iRun,length(dayFolder(iDay).polRun),...
                iDay,length(dayFolder))
            
            cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
            
            [~,cubeBaseName,~] = fileparts(cubeName);
            
            pngBaseName = sprintf('%s_timex.png',cubeBaseName);
            pngName = fullfile(saveDirSub,pngBaseName);
            
            fileExists = exist(pngName,'file');
            if fileExists && ~doOverwrite
                fprintf('%s exists. Skipping ...\n',pngName)
            else
                fprintf('%s ...',cubeBaseName)
%                 try
                    cube2timex_tides(cubeName,pngName)
                    fprintf('Done.\n')
%                 catch
%                     fid = fopen(['FAILED_on_file_',pngBaseName,'.txt'], 'wt' );
%                     fclose(fid)
%                 end
                    
            end
            
            imgId = imgId + 1;
          end
       
end
      