function kmzConcatenate(kmzList,kmzName)
%
% This function reads in a list of kmz files and outputs a single,
% concatenated kmz file.
% 
% INPUT:
% kmzList       = Structure or cell array of kmz files including full path
% kmzName       = String of output kmz file including full path
%
% Example:
% kmzList = dir('*.kmz');
% kmzName = 'concatenatedKmz.kmz';
% kmzConcatenate(kmzList,kmzName)
%
%
% 2017-Jun-06 David Honegger


% Prepare input
if isstruct(kmzList)
    if isfield(kmzList,'folder') && isfield(kmzList,'name')
        % Likely generated using dir.m
        % Let's convert to cell array
        tmp = cell(size(kmzList));
        for i = 1:length(kmzList)
            tmp{i} = fullfile(kmzList(i).folder,kmzList(i).name);
        end
        kmzList = tmp;clear tmp
    else
        fprintf('Filename-containing structure should have fields "folder" and "name" \n')
        fprintf('such as that created with "dir.m\n"')
        error('Try kmzList = dir(''*.kmz'');')
    end
else
    % Assume kmzList is already a cell array
end


% Create temp folders and file
tmpID = randi(1e4,1);
tmpWriteFolder = sprintf('tempFolder%05.f-w',tmpID);
    mkdir(tmpWriteFolder)
    mkdir(fullfile(tmpWriteFolder,'files'))
tmpReadFolder = sprintf('tempFolder%05.f-r',tmpID);
    mkdir(tmpReadFolder)
tmpFile = 'doc.kml';
    fid = fopen(fullfile(tmpWriteFolder,tmpFile),'w');

% Write header
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>');
fprintf(fid,'\n');
fprintf(fid,'<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
fprintf(fid,'\n');

% Open data container
fprintf(fid,'<Folder>');
fprintf(fid,'\n');

% Loop through kmzs and populate
for i = 1:length(kmzList)
    
    [~,baseName,~] = fileparts(kmzList{i});
    fprintf('%s: ',baseName)
    
    % Unzip kmz to kml
    fprintf('Unzipping. ')
    unzip(kmzList{i},tmpReadFolder)
    
    % Find and open kml file
    fprintf('Opening. ')
    kmlDir = dir(fullfile(tmpReadFolder,'*.kml'));
    if length(kmlDir)>1
        disp('More than one kml file in this kmz. That''s weird ...')
        error('Check the kmz file. Something is wrong.')
    else
        kmlReadFile = kmlDir.name;
    end
    fidRead = fopen(fullfile(tmpReadFolder,kmlReadFile),'r');
    
    % Keep reading until the good stuff
    thisLine = fgetl(fidRead);
    while ~contains(thisLine,'GroundOverlay')
        thisLine = fgetl(fidRead);
    end
    
    % Now keep writing until the end of the good stuff
    fprintf('Reading/writing. ')
    fprintf(fid,thisLine);
    thisLine = fgetl(fidRead);
    while ~contains(thisLine,'/GroundOverlay')
        fprintf(fid,thisLine);
        thisLine = fgetl(fidRead);
    end
    fprintf(fid,thisLine);
    
    % Copy overlay png to write folder
    fprintf('Moving overlay. ')
    pngDir = dir(fullfile(tmpReadFolder,'files','*.png'));
    if isempty(pngDir)
        disp('No png files found in source kmz')
        error('Check the kmz file. Something is wrong')
    else
        for iPng = 1:length(pngDir)
            copyfile(fullfile(pngDir(iPng).folder,pngDir(iPng).name),...
                fullfile(tmpWriteFolder,'files',pngDir(iPng).name));
        end
    end
    
    % Clean up temp read folder
    fprintf('Cleaning. ')
    fclose(fidRead);
    delete(fullfile(tmpReadFolder,kmlReadFile))
    rmdir(fullfile(tmpReadFolder,'files'),'s')
    
    fprintf('Done.\n')
end

% Now wrap up the container
fprintf(fid,'</Folder>');
fprintf(fid,'\n');
fprintf(fid,'</kml>');
fprintf(fid,'\n');

% Close the concatenated kml
fclose(fid);

fprintf('Zipping and sending to destination. ')
% Zip kml to kmz and send to destination directory
zip(kmzName,{'doc.kml','files'},tmpWriteFolder)
src = sprintf('%s.zip',kmzName);
dest = sprintf('%s',kmzName);
if isunix
    eval(['! mv ',src,' ',dest])
elseif ispc
    eval(['! move ',src,' ',dest])
end
% movefile([kmzName,'.zip'],kmzName)

% Delete temp directory
rmdir(tmpReadFolder,'s')
rmdir(tmpWriteFolder,'s')

fprintf('Done.\n')