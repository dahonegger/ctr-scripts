function isPatched = isKmzPatched(kmzName)
%
% This function tests if a kmz has been patched to provide a drawOrder, 
% as requested by Dan Plotnick, the USRS-CTR Google Earth czar
% 
%
% 2017-06-16 David Honegger

% Create temp folder to extract into
tmpID = randi(1e4,1);
tmpReadFolder = sprintf('tempFolder%05.f-r',tmpID);
    mkdir(tmpReadFolder)
    
try
    unzip(kmzName,tmpReadFolder)

    % Find and open kml file
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
    while ~contains(thisLine,'drawOrder') && ~feof(fidRead)
        thisLine = fgetl(fidRead);
    end

    if feof(fidRead)
        isPatched = false;
    else
        isPatched = true;
    end
catch
    fprintf('isKmzPatched failed.\n')
    fclose(fidRead);
    % Delete temp directory
    rmdir(tmpReadFolder,'s')
end

fclose(fidRead);
% Delete temp directory
rmdir(tmpReadFolder,'s')
