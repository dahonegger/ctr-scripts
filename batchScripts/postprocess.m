%% What to do?
doProcessCube           = true;
doWriteKmz              = false;
doWriteBfKmz            = false;

%% What to redo?
doReprocessCube         = false;
doOverwriteKmz          = false;
doOverwriteBfKmz        = false;

%% Process only these folders
folderList = [];%...
%               {'2017-06-07',...
%               '2017-06-08',...
%               '2017-06-09',...
%               '2017-06-10',...
%               '2017-06-11',...
%               '2017-06-12'};

%% Work forwards or backwards? (Good for two matlab calls)
goBackwardInTime = false;

%% Where are the scripts?
% scrDir = 'C:\Data\CTR\scripts_updated';
% if ispc
%     scrDir = '\\attic.engr.oregonstate.edu\hallerm\RADAR_DATA\CTR\scripts';
% elseif isunix
%     scrDir = '/nfs/attic/hallerm/RADAR_DATA/CTR/scripts';
% end
addpath(genpath(fileparts(pwd)));
% addpath(genpath(scrDir))

%% Where to read and write data?
% On Dell:
baseDir = 'D:\DAQ-data';
% baseDir = 'C:\Data\CTR\DAQ-data';
% baseDir = '/data';

% Data directory
% cubeDir = 'E:\Data\CTR\DAQ-data\processed\';
cubeDir = fullfile(baseDir,'processed');

% Save intensity kmz directory
% SAve to same folder as cube
kmzSaveDir = fullfile(baseDir,'postprocessed','kmz');
if ~exist(kmzSaveDir,'dir'); mkdir(kmzSaveDir); end

% Save edge filtered kmz directory
% kmzBfSaveDir = 'E:\Data\CTR\postprocessed\rectBfKmz\';
kmzBfSaveDir = fullfile(baseDir,'postprocessed','bf-kmz');
if doWriteBfKmz
    if ~exist(kmzBfSaveDir,'dir'); mkdir(kmzBfSaveDir); end
end



%% Start Processing

% Read in data
dayFolder = dir(fullfile(cubeDir,'2017*'));

iFail = 0;


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
            
            try
                
                cubeName = fullfile(cubeDir, dayFolder(iDay).name, dayFolder(iDay).polRun(iRun).name);

                [~,cubeBaseName,~] = fileparts(cubeName);

                %% Time saving measures: don't overwrite if already done
                doProcessThisCube   = doProcessCube;
                doWriteThisKmz      = doWriteKmz;
                doWriteThisBfKmz    = doWriteBfKmz;

                % Cube:
                % Check if a heading offset is already present
                vars = who('-file',cubeName);
                if ismember('headingOffset',vars) && ~doReprocessCube
                    doProcessThisCube = false;
                    fprintf('Cube already processed. ')
                end
                % Kmz:
                if doWriteKmz
                    kmzName = fullfile(kmzSaveDir, [cubeBaseName,'.kmz']);
                    if exist(kmzName, 'file') && ~doOverwriteKmz
                        fprintf('Kmz Exists. Not overwriting. ')
                        doWriteThisKmz = false;
                    end
                end
                % Bilateral filtered Kmz:
                if doWriteBfKmz
                    bfKmzName = fullfile(kmzBfSaveDir, [cubeBaseName,'_bf.kmz']);
                    if exist(bfKmzName,'file') && ~doOverwriteBfKmz
                        fprintf('BF-Kmz Exists. Not overwriting. ')
                        doWriteThisBfKmz = false;
                    end
                end



                %% This is hardcoded for 720 Azimuths
                load(cubeName,'Azi');
                nAzi = length(Azi);
                if nAzi == 720



                    %% Rectify and write rectCube
                    if doProcessThisCube

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
                        % Save new cube to original location
                        fprintf('Saving. ')
                        save(cubeName,'-struct','Cube','-v7.3')
                        fprintf('\n')
                    end



                    %% Create kmz from new cube
                    if doWriteThisKmz
                        polMat2TimexKmz(cubeName,kmzName)
                    end



                    %% Create bfKmz from new cube
                    if doWriteThisBfKmz
                        polMat2TimexKmz(cubeName,bfKmzName,true)
                    end

                    fprintf('\n')

                else
                    fprintf('Footprint too small. Skipping.\n')
                end

                if toc(ticTime)>2
                    fprintf('Run processed in %.0f seconds.\n',toc(ticTime))
                end
                
            catch ME
                fidFail = fopen('postprocessfails.txt','a+t');
                fprintf(fidFail,'%s: %s\n',cubeName,ME.message);
                fclose(fidFail);
                fprintf('\n')
            end
                

        end
          
        
        fprintf('\n')
end
            
