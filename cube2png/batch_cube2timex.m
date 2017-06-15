
baseDir = 'C:\Data\CTR\DAQ-data\processed\';
% saveDir = 'C:\Data\CTR\postprocessed\timex';
saveDir = 'C:\Data\CTR\postprocessed\timex';
doOverwrite = false;



if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

imgId = 1;
for iDay = 1:length(dayFolder)
    
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    
        for iRun = 1:length(dayFolder(iDay).polRun)
            
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
                cube2timex(cubeName,pngName)
                fprintf('Done.\n')
            end
            
            imgId = imgId + 1;
        end
        
end
            