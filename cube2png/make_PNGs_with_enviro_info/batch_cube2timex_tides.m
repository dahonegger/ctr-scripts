tic
addpath(genpath('C:\Data\CTR\scripts-master'))
addpath(genpath('C:\Data\CTR\supportData'))

baseDir = 'D:\Data\CTR\DAQ-data\processed\';
saveDir = 'D:\Data\CTR\postprocessed\timex_tides';
% saveDir = 'C:\Data\CTR\postprocessed\timeZoom';
doOverwrite = true;



if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

imgId = 1;
for iDay = 1:length(dayFolder)
% for iDay = 1:1
        
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    
        for iRun = 1:length(dayFolder(iDay).polRun)
%           for iRun = 1:1
            
            fprintf('%3.f of %3.f in dir %3.f of %3.f: ',...
                iRun,length(dayFolder(iDay).polRun),...
                iDay,length(dayFolder))
            
            cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
            
            [~,cubeBaseName,~] = fileparts(cubeName);
            
            pngBaseName = sprintf('%s_timex.png',cubeBaseName);
            pngName = fullfile(saveDir,pngBaseName);
            
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
toc            