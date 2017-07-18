function tCube = stackTimex(cubeDir,dnStart,dnEnd)

dnVec = dnStart:15/60/24:dnEnd;

for i = 1:length(dnVec)
    cubeNamesAll{i} = cubeNameFromTime(dnVec(i),cubeDir);
end
cubeNamesAll(cellfun(@isempty,cubeNamesAll)) = [];

for i = 1:numel(cubeNamesAll)
    if i==1
        Cube = load(cubeNamesAll{i});
        tCube.data = uint8(zeros(numel(Cube.Rg),numel(Cube.Azi),numel(cubeNamesAll)));
        tCube.dn   = zeros(numel(cubeNamesAll),1);
        tCube.Azi = Cube.Azi;
        tCube.Rg = Cube.Rg;
        tCube.header = Cube.header;
        tCube.results = Cube.results;
        
        
        if isfield(Cube,'timex')
            tCube.data(:,:,i) = uint8(Cube.timex);
        else
            tCube.data(:,:,i) = uint8(mean(Cube.data,3));
        end
        tCube.dn(i) = epoch2Matlab(mean(Cube.timeInt(:)));
        
    else
        load(cubeNamesAll{i},'timex','timeInt')
        if isempty(timex)
            load(cubeNamesAll{i},'data')
            tCube.data(:,:,i) = uint8(mean(data,3));
        else
            tCube.data(:,:,i) = uint8(timex);
        end
        tCube.dn(i) = epoch2Matlab(mean(timeInt(:)));
    end
    
    
    fprintf('Stacking %d of %d.\n',i,numel(cubeNamesAll))
end