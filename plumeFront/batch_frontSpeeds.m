%%% THIS SCRIPT READS FRONT-STRUCTURE FILES AND THEN CREATES (A) FRONT
%%% SPEEDS BY FORWARD DIFFERENCING AND (B) INTERPOLATES THEM TO A REGULAR
%%% GRID

plumeDir = fullfile(atticDir,'hallerm','RADAR_DATA','CTR','postprocessed','plumeFront');
files = dir(fullfile(plumeDir,'*.mat'));

for i = 1:length(files)
    fprintf('%d of %d\n',i,length(files))
    load(fullfile(files(i).folder,files(i).name));
%     frontDiff = frontSpeedFromCurves(front);
    if ~isempty(frontDiff)
        [frontDiffGrd,dbfig] = frontDiffToGrid(frontDiff);
    
        [~,fname,~] = fileparts(files(i).name);
%         print(dbfig,'-dpng','-r200',sprintf('%s_frontSpeed.png',fullfile(plumeDir,fname)))

%         save(fullfile(files(i).folder,files(i).name),'-append','frontDiff','frontDiffGrd')
    
    
        
        close(dbfig)
        clear dbfig
    end
end


%% Mooring Plots
mooringDir = fullfile(depotDir,'haller','shared','RADAR_DATA','USRS','connecticut','supportData','moorings');
load(fullfile(mooringDir,'casts_deploy_lisbuoys_065781_20170519_1302'))

for i = 1:length(files)
    disp(i)
    load(fullfile(files(i).folder,files(i).name));
    [hFig,hAx,hPl] = frontSpeedOnInSitu(frontDiffGrd,loncast,latcast);
    
    if ~isempty(hFig)
        
        [~,fname,~] = fileparts(files(i).name);
        print(hFig,'-dpng','-r200',sprintf('%s_frontSpeedMooringsContour.png',fullfile(files(i).folder,fname)))
        close(hFig)
    end
    
    clear hFig hAx hPl
end

%% Concatenated domain

for i = 1:length(files)
    disp(i)
    load(fullfile(files(i).folder,files(i).name));
    if i==1
        fieldNames = fieldnames(frontDiffGrd);
        frontDiffCat = frontDiffGrd;
    else
        for j = 1:length(fieldNames)
            frontDiffCat.(fieldNames{j}) = cat(3,frontDiffCat.(fieldNames{j}),frontDiffGrd.(fieldNames{j}));
        end
    end
end

