function kml2kmz(kmlFile,doReplace)

if ~exist('doReplace','var') || isempty(doReplace)
    doReplace = false;
end

[kmlPath,kmlName,kmlExt] = fileparts(kmlFile);
kmzPath = kmlPath;
kmzName = kmlName;
kmzExt = '.kmz';
kmzFile = fullfile(kmzPath,[kmzName,kmzExt]);

% Zip kml to kmz and send to destination directory
zip(kmzName,[kmlName,kmlExt],kmlPath)
src = sprintf('%s.zip',kmzName);
dest = sprintf('%s',kmzFile);
if isunix
    eval(['! mv ',src,' ',dest])
elseif ispc
    eval(['! move ',src,' ',dest])
end

if doReplace
    if isunix
        eval(['! rm -f ',kmlFile])
    elseif ispc
        eval(['! del /f ',kmlFile])
    end
end