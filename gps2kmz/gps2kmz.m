function gps2kmz(inFile,kmlFile)

load(inFile)

lonPoints = lon;
latPoints = lat;
dnPoints = dn+4/24;

kmlPoints(...
	kmlFile,...
	lonPoints,...
	latPoints,...
	'time',dnPoints);

[kmlFilePath,kmlFileName,kmlExt] = fileparts(kmlFile);

kml2kmz(fullfile(kmlFilePath,[kmlFileName,'.kml']),false);
