function plumeFront2kmz(inFile,kmlFile)

%% Load inFile
load(inFile)

%% Generate arrays
lonPoints = [];
latPoints = [];
dnPoints = [];
tideHrPoints = [];
colorPoints = [];

decim = 1;

for i = 1:length(front)
    lonPoints = [lonPoints;front(i).lon(1:decim:end)];
    latPoints = [latPoints;front(i).lat(1:decim:end)];
    dnPoints = [dnPoints;front(i).dn*ones(size(front(i).lon(1:decim:end)))];
    tideHrPoints = [tideHrPoints;front(i).tideHr*ones(size(front(i).lon(1:decim:end)))];
    colorPoints = [colorPoints;...
        repmat(...
            val2rgb(...
                front(i).tideHr,...
                'cmap','custom','customMap',colorcet('d1'),...
                'range',[-3.5 3.5])',...
            length(front(i).lon(1:decim:end)),1)];
end

iconScale = 0.25*ones(size(lonPoints));

%% Save kml

[kmlFilePath,kmlFileName,kmlFileExt] = fileparts(kmlFile);

kmlPoints(...
    fullfile(kmlFilePath,kmlFileName),...
    lonPoints,...
    latPoints,...
    'time',dnPoints,...
    'iconColor',colorPoints,...
    'iconScale',iconScale);

%% kml2kmz

kml2kmz(fullfile(kmlFilePath,[kmlFileName,'.kml']),true);
