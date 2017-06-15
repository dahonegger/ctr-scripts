%% What to do?
doWriteRectCube         = true;
doWriteKmz              = true;
doWriteBfKmz            = false;

%% What to redo?
doOverwriteRectCube     = false;
doOverwriteKmz          = false;
doOverwriteBfKmz        = false;

%% Work forwards or backwards?
goBackwardInTime = true;

%% Where are the scripts?
% scrDir = 'E:\Data\CTR\scripts';
if ispc
    scrDir = '\\attic.engr.oregonstate.edu\hallerm\CTR\scripts';
elseif isunix
    scrDir = '/nfs/attic/hallerm/CTR/scripts';
end
addpath(genpath(scrDir))

%% Where to read and write data?
if ispc
    baseDir = '\\attic.engr.oregonstate.edu\hallerm\CTR\';
elseif isunix
    baseDir = '/nfs/hallerm/CTR/';
end

% Data directory
cubeDir = 'E:\Data\CTR\DAQ-data\processed\';

% Save rect cube directory
% rectCubeDir = 'E:\Data\CTR\postprocessed\rectCubes\';
rectCubeDir = fullfile(baseDir,'postprocessed','rectifiedCubes',filesep);
if ~exist(rectCubeDir,'dir');mkdir(rectCubeDir);end

% Save intensity kmz directory
% kmzSaveDir = 'E:\Data\CTR\postprocessed\rectKmz\';
kmzSaveDir = fullfile(baseDir,'postprocessed','rectKmz',filesep);
if ~exist(kmzSaveDir,'dir');mkdir(kmzSaveDir);end

% Save edge filtered kmz directory
% kmzBfSaveDir = 'E:\Data\CTR\postprocessed\rectBfKmz\';
kmzBfSaveDir = fullfile(baseDir,'postprocessed','rectBfKmz',filesep);
if ~exist(kmzBfSaveDir,'dir');mkdir(kmzBfSaveDir);end



%% Start Processing

% Read in data
dayFolder = dir([cubeDir,'2017*']);

dayVec = 1:length(dayFolder);
if goBackwardInTime
    dayVec = flipud(dayVec(:));
end
for iDay = dayVec
    
    dayFolder(iDay).polRun = dir(fullfile(cubeDir,dayFolder(iDay).name,'*_pol.mat'));
        
        runVec = 1:length(dayFolder(iDay).polRun);
        if goBackwardInTime
            runVec = flipud(runVec(:));
        end
        for iRun = runVec
            
            
            fprintf('%3.f of %3.f in dir %3.f of %3.f: ',...
                iRun,length(dayFolder(iDay).polRun),...
                iDay,length(dayFolder))
            
            cubeName = fullfile(cubeDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
            
            [~,cubeBaseName,~] = fileparts(cubeName);
            
            newBaseName = [cubeBaseName,'_rect.mat'];
            newCubeName = [rectCubeDir,newBaseName];
            
            %% Time saving measures: don't overwrite if already done
            % Cube:
            if exist(newCubeName,'file') && ~doOverwriteRectCube
                fprintf('Rectified Cube Exists. Loading new cube instead.')
                doWriteRectCube = false;
            end
            % Kmz:
            kmzName = [kmzSaveDir,newBaseName];
            if exist(kmzName,'file') && ~doOverwriteKmz
                doWriteKmz = false;
            end
            % Bilateral filtered Kmz:
            bfKmzName = [kmzBfSaveDir,newBaseName,'_bf'];
            if exist(BfKmzName,'file') && ~doOverwriteBfKmz
                doWriteBfKmz = false;
            end
            
            
            
            %% This is hardcoded for 720 Azimuths
            load(cubeName,'Azi');
            nAzi = length(Azi);
            if nAzi == 720
                
                
                
                %% Rectify and write rectCube
                if doWriteRectCube
                    % Load Cube
                    fprintf('Loading %s.',cubeBaseName)
                    Cube = load(cubeName);
                    fprintf('\n')
                    % Co-Rectify
                    Cube = coRectify(Cube);
                    % Co-GeoRectify
                    Cube = coGeoRectify(Cube);

                    % Save new cube
                    fprintf('Saving %s.',newBaseName)
                    save(newCubeName,'-struct','Cube','-v7.3')
                    fprintf('\n')
                end
                
                
                
                %% Create kmz from new cube
                if doWriteKmz
                    polMat2TimexKmz(newCubeName,kmzName)
                end
                
                
                
                %% Create bfKmz from new cube
                if doWriteBfKmz
                    polMat2TimexKmz(newCubeName,bfKmzName,true)
                end
                
                
                
            else
                fprintf('Footprint too small. Skipping.\n')
            end
           
            
        end
        
end
            