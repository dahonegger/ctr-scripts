baseDir = 'E:\DAQ-data\processed\';
kmzDir = 'C:\Data\CTR\kmz\';
scrDir = 'C:\Data\CTR\ctr-scripts\';
addpath(genpath(scrDir))

files = getFiles(baseDir);


for i = 1:length(files)
    cubeFile = fullfile(files(i).path,files(i).name);
    [~,cubeName,~] = fileparts(cubeFile);
    kmzFile = fullfile(kmzDir,[cubeName,'.kmz']);
    disp(cubeFile)
    polMat2TimexKmz(cubeFile,kmzFile,0)
end