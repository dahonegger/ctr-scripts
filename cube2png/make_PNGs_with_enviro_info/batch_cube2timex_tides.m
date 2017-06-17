
%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository
addpath(genpath('E:\SupportData')) %CTR HUB 
addpath(genpath('C:\Data\CTR\ctr-scripts')) %github repository

% add path to mat files and choose directory for png's   
baseDir = 'E:\DAQ-data\processed\';
saveDir = 'C:\Data\CTR\postprocessed\timex_enviroInfo2\';

% rewrite existing files in save directory? true=yes
doOverwrite = false;


%% 
if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

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
                cube2timex_tides(cubeName,pngName)
                fprintf('Done.\n')
            end
            
            imgId = imgId + 1;
          end
        
end
      