function fCube = movingAvgRadarParallel(Cube,windowSize,filterType)
% fCube = movingAverageRadar(Cube,windowSize,filterType)
%
% This function inputs a radar Cube (as created by ReadBin, etc.) and 
% 	performs a lowpass filter on the time series of rotations. In order to
% 	maintain the data structure and save space, the output Cube is the same
% 	as the input, but with the Cube.data variable replaced. Note that any
% 	NaN in the raw time series will result in all NaNs in the filtered time
% 	series.
% 
% Subscripts: cartCube.m
% 
% INPUT:
% 	Cube		=	Radar Cube structure (as created by ReadBin.m, etc.)
% 	windowSize 	=	Filter window size (in rotations, not seconds; e.g. 45 for 1 min means)
% 	filterType 	= 	Type of filter [string]. Use 'filter' for simple moving average;
% 						use 'filtfilt' for double moving average with no phase shift.
% OUTPUT:
% 	fCube 		= 	Radar Cube structure with 'data' field replaced with filtered data


fCube = Cube;

if ~isfield(fCube,'xdom')
    Cube = cartCube(Cube);
    fCube = cartCube(fCube);
end

fprintf('Filtering %s in parallel ...',Cube.header.file)
str = '';
for i = 1:size(Cube.data,1)
    
    for dels = 1:length(str);fprintf('\b');end
    str = sprintf(' %d/%d ranges done.',i,size(Cube.data,1));
    fprintf('%s',str);
    
    tmpSliceIn = squeeze(Cube.data(i,:,:));
    tmpSliceOut = tmpSliceIn;
    parfor j = 1:size(Cube.data,2)
%         eval(sprintf('fCube.data(i,j,:) = uint8(%s(ones(1,windowSize)/windowSize,1,double(squeeze(Cube.data(i,j,:)))));',filterType))
        if strcmp(filterType,'filtfilt')
            tmpSliceOut(j,:) = uint8(filtfilt(ones(1,windowSize)/windowSize,1,double(squeeze(tmpSliceIn(j,:)))));
        elseif strcmp(filterType,'filt')
            tmpSliceOut(j,:) = uint8(filt(ones(1,windowSize)/windowSize,1,double(squeeze(tmpSliceIn(j,:)))));
        end
    end
    fCube.data(i,:,:) = tmpSliceOut;
end
fprintf(' Done.\n')
