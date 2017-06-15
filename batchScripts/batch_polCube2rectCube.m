%% What to do?
doWriteRectCube         = true;
doWriteKmz              = true;
doWriteBfKmz            = true;

%% What to redo?
doOverwriteRectCube     = false;
doOverwriteKmz          = false;
doOverwriteBfKmz        = false;

%% Process only these folders
folderList = {'2017-06-07',...
              '2017-06-08',...
              '2017-06-09',...
              '2017-06-10',...
              '2017-06-11'};

%% Work forwards or backwards? (Good for two matlab calls)
goBackwardInTime = false;

%% Where are the scripts?
% % scrDir = 'E:\Data\CTR\scripts';
% if ispc
%     scrDir = '\\attic.engr.oregonstate.edu\hallerm\RADAR_DATA\CTR\scripts';
% elseif isunix
%     scrDir = '/nfs/attic/hallerm/RADAR_DATA/CTR/scripts';
% end
addpath(genpath(fileparts(pwd)));

%% Where to read and write data?
% if ispc
%     baseDir = '\\attic.engr.oregonstate.edu\hallerm\RADAR_DATA\CTR\';
% elseif isunix
%     baseDir = '/nfs/attic/hallerm/RADAR_DATA/CTR/';
% end
baseDir = '/data';

% Data directory
% cubeDir = 'E:\Data\CTR\DAQ-data\processed\';
cubeDir = fullfile(baseDir,'processed');

% Save rect cube directory
% rectCubeDir = 'E:\Data\CTR\postprocessed\rectCubes\';
rectCubeDir = fullfile(baseDir,'postprocessed','rectifiedCubes');
if ~exist(rectCubeDir,'dir'); mkdir(rectCubeDir); end

% Save intensity kmz directory
% kmzSaveDir = 'E:\Data\CTR\postprocessed\rectKmz\';
kmzSaveDir = fullfile(baseDir,'postprocessed','rectKmz');
if ~exist(kmzSaveDir,'dir'); mkdir(kmzSaveDir); end

% Save edge filtered kmz directory
% kmzBfSaveDir = 'E:\Data\CTR\postprocessed\rectBfKmz\';
kmzBfSaveDir = fullfile(baseDir,'postprocessed','rectBfKmz');
if doWriteBfKmz
    if ~exist(kmzBfSaveDir,'dir'); mkdir(kmzBfSaveDir); end
end



%% Start Processing

% Read in data
dayFolder = dir(fullfile(cubeDir,'2017*'));

dayVec = 1:length(dayFolder);
if goBackwardInTime
    dayVec = flipud(dayVec(:))';
end
for iDay = dayVec
    
    if ~isempty(folderList)
        if ~ismember(dayFolder(iDay).name, folderList)
            fprintf('Folder %s not in list.\n', dayFolder(iDay).name);
            continue
        end
    end
    
    dayFolder(iDay).polRun = dir(fullfile(cubeDir, dayFolder(iDay).name,'*_pol.mat'));
        
        runVec = 1:length(dayFolder(iDay).polRun);
        if goBackwardInTime
            runVec = flipud(runVec(:))';
        end
        for iRun = runVec
            
            ticTime = tic;
            
            fprintf('%3.f of %3.f in dir %3.f of %3.f: ',...
                iRun,length(dayFolder(iDay).polRun),...
                iDay,length(dayFolder))
            
            cubeName = fullfile(cubeDir, dayFolder(iDay).name, dayFolder(iDay).polRun(iRun).name);
            
            [~,cubeBaseName,~] = fileparts(cubeName);
            
            newBaseName = [cubeBaseName, '_rect.mat'];
            newCubeName = fullfile(rectCubeDir, newBaseName);
            
%             if iDay == 3 && iRun == 1
%                 keyboard
%             end
            
            %% Time saving measures: don't overwrite if already done
            doWriteThisRectCube = doWriteRectCube;
            doWriteThisKmz      = doWriteKmz;
            doWriteThisBfKmz    = doWriteBfKmz;
            % Cube:
            if doWriteRectCube
                if exist(newCubeName,'file') && ~doOverwriteRectCube
                    fprintf('Rectified Cube Exists. Loading new cube instead.\n')
                    doWriteThisRectCube = false;
                end
            end
            % Kmz:
            if doWriteKmz
                kmzName = fullfile(kmzSaveDir, [newBaseName(1:end-4),'.kmz']);
                if exist(kmzName, 'file') && ~doOverwriteKmz
                    fprintf('Kmz Exists. Not overwriting.\n')
                    doWriteThisKmz = false;
                end
            end
            % Bilateral filtered Kmz:
            if doWriteBfKmz
                bfKmzName = fullfile(kmzBfSaveDir, [newBaseName(1:end-4),'_bf.kmz']);
                if exist(bfKmzName,'file') && ~doOverwriteBfKmz
                    fprintf('BF-Kmz Exists. Not overwriting.\n')
                    doWriteThisBfKmz = false;
                end
            end
            
            
            
            %% This is hardcoded for 720 Azimuths
            load(cubeName,'Azi');
            nAzi = length(Azi);
            if nAzi == 720
                
                
                
                %% Rectify and write rectCube
                if doWriteThisRectCube
                    % Load Cube
                    fprintf('Loading %s.',cubeBaseName)
                    Cube = load(cubeName);
                    fprintf('\n')
                    % Co-Rectify
                    Cube = coRectify(Cube);
                    % Co-GeoRectify
                    Cube = coGeoRectify(Cube);
                    % Add Timex
                    Cube.timex = mean(Cube.data, 3);
                    % Save new cube
                    fprintf('Saving %s.',newBaseName)
                    save(newCubeName,'-struct','Cube','-v7.3')
                    fprintf('\n')
                end
                
                
                
                %% Create kmz from new cube
                if doWriteThisKmz
                    polMat2TimexKmz(newCubeName,kmzName)
                end
                
                
                
                %% Create bfKmz from new cube
                if doWriteThisBfKmz
                    polMat2TimexKmz(newCubeName,bfKmzName,true)
                end
                
                fprintf('\n')
                
            else
                fprintf('Footprint too small. Skipping.\n')
            end
           
            fprintf('Run processed in %.0f seconds.\n',toc(ticTime))
            
        end
        
end
            
