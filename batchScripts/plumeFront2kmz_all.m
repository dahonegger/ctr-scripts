%% PLUME FRONT MATFILE PATH
frontDir = fullfile('C:','Data','CTR','plumeFront');

%% KMZ PATH
kmzDir = fullfile('C:','Data','CTR','plumeFrontKmz');
if ~exist(kmzDir,'dir');mkdir(kmzDir);end

%% Load

files = dir(fullfile(frontDir,'plumeFront*.mat'));
clear ebb
for i = 1:length(files)
    inFile = fullfile(files(i).folder,files(i).name);
    [inFilePath,inFileName,inFileExt] = fileparts(inFile);
    kmzFile = fullfile(kmzDir,inFileName);
    
    fprintf('%s to %s.kmz:',inFile,kmzFile)
    plumeFront2kmz(inFile,kmzFile)
    fprintf('\n')
end