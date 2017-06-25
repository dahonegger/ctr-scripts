doOverwrite = false;

%% PLUME FRONT MATFILE PATH
frontDir = fullfile('C:','Data','CTR','plumeFront');

%% DEFINE TIDE INFO FOR OUTPUT FILES
[uTide,dnTide] = railroadBridgeCurrentLocal;
dnMaxEbb = tideHrMaxEbb2dn(0,dnTide,uTide);

inputTideDn = datenum('2017-06-25 16:00:00'):15/60/24:datenum('2017-06-26 03:00:00');
[inputTideHr,inputTideNum] = tideHourMaxEbb(inputTideDn,dnTide,uTide,true);
saveTideNum = inputTideNum;
inputZeroHourDn = interp1(inputTideHr,inputTideDn,0);

%% KMZ PATH
kmzDir = fullfile('C:','Data','CTR','plumeFrontKmz',sprintf('refTo_%s',datestr(inputZeroHourDn,'yyyymmddTHHMMSSZ')));
if ~exist(kmzDir,'dir');mkdir(kmzDir);end


%% Load 

files = dir(fullfile(frontDir,'plumeFront*.mat'));
clear ebb
for i = 1:length(files)
    inFile = fullfile(files(i).folder,files(i).name);
    [inFilePath,inFileName,inFileExt] = fileparts(inFile);
    
    load(inFile)
    clear newdn
    for i = 1:numel(front)
        tmp = interp1(inputTideHr,inputTideDn,front(i).tideHr);
        front(i).dn = tmp;
    end
    [~,tideNumIn] = 
    daysAgo = 
    newMatName = sprintf('%s_refTo_%s',inFileName,datestr(inputZeroHourDn,'yyyymmddTHHMMSSZ'));
    newMatPath = fullfile(inFilePath,sprintf('refTo_%s',datestr(inputZeroHourDn,'yyyymmddTHHMMSSZ')));
    if ~exist(newMatPath,'dir');mkdir(newMatPath);end
    
    newMatFile = fullfile(newMatPath,newMatName);
    save(newMatFile,'-v7.3','front')
    
    inFile = [newMatFile,'.mat'];
    [inFilePath,inFileName,inFileExt] = fileparts(inFile);
    
    kmzFile = fullfile(kmzDir,inFileName);
    
    if exist([kmzFile,'.kmz'],'file')
        if doOverwrite
            fprintf('%s to %s.kmz:',inFile,kmzFile)
            plumeFront2kmz(inFile,kmzFile)
        else 
            fprintf('Exists.Skipping.')
        end
    else
        fprintf('%s to %s.kmz:',inFile,kmzFile)
        plumeFront2kmz(inFile,kmzFile)
    end
    fprintf('\n')
end