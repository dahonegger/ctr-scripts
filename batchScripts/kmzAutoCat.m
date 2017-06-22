function kmzName = kmzAutoCat(nHrs,decim)
%
% This function reads in a file containing a list of kmz files and outputs 
% a single, concatenated kmz file.
% 
%
% 2017-Jun-15 David Honegger

fprintf('kmzAutoCat: Combining %d hours with %d decimation at %s\n',nHrs,decim,datestr(now))

if ispc
    attic = '\\attic.engr.oregonstate.edu\hallerm';
else
    attic = '/nfs/attic/hallerm';
end
pathToKmz = fullfile(attic,'RADAR_DATA', 'CTR', 'site_push', 'kmz');
pathToKmzStack = fullfile(attic,'RADAR_DATA', 'CTR', 'site_push', 'kmzStack');

kmzList = dir(fullfile(pathToKmz,'*.kmz'));

% Get Timestamps
dt_strs = regexp({kmzList.name}, '20\d{9}', 'match', 'once');
dt_vals = cellfun(@(C) sscanf(C, '%4f%3f%2f%2f'), dt_strs, 'UniformOutput', false);
dnList = cellfun(@(C) datenum([C(1), 0, C(2:4)', 0]), dt_vals);

%fprintf('Most recent kmz: %s\n',datestr(dnList(end)))
beginTime = now - nHrs/24 + 7/24; % Don't forget: Computer in PDT, timestamps in UTC!
idxList = find(dnList>beginTime);
%keyboard
if isempty(idxList)
	return
end
kmzList = kmzList(idxList(1:decim:end)); 

kmzName = sprintf('%s/kmzStack_mostRecent%.fHrs.kmz',pathToKmzStack,nHrs);
% [~,firstBase,~] = fileparts(kmzList(1));
% [~,lastBase,~] = fileparts(kmzList(end));
% kmzName = sprintf('./%s_to_%s.kmz',firstBase,lastBase);
% if exist(kmzName,'file')
%     disp('No new files')
%     return
% end

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

try

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
    eval(['! chmod 775 ',dest])
elseif ispc
    eval(['! move ',src,' ',dest])
end
% movefile([kmzName,'.zip'],kmzName)

catch
	fclose(fid);
	% Delete temp directory
	rmdir(tmpReadFolder,'s')
	rmdir(tmpWriteFolder,'s')

end

% Delete temp directory
rmdir(tmpReadFolder,'s')
rmdir(tmpWriteFolder,'s')

fprintf('Done.\n')
