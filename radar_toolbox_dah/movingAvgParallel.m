function dataOut = movingAvgParallel(dataIn,windowSize,filterType)
% dataOut = movingAverageRadar(Cube,windowSize,filterType)
%
% This function inputs a 3D array (X-Y-T) and applies a lowpass filter in time. Note that any
% 	NaN in the raw time series will result in all NaNs in the filtered time
% 	series.

fprintf('Filtering in parallel ...')
str = '';
dataOut = uint16(zeros(size(dataIn)));
for i = 1:size(dataIn,1)
    
    for dels = 1:length(str);fprintf('\b');end
    str = sprintf(' %d/%d ranges done.',i,size(dataIn,1));
    fprintf('%s',str);
    
    tmpSliceIn = squeeze(dataIn(i,:,:));
    tmpSliceOut = tmpSliceIn;
%     keyboard
    parfor j = 1:size(dataIn,2)
%         eval(sprintf('fCube.data(i,j,:) = uint8(%s(ones(1,windowSize)/windowSize,1,double(squeeze(Cube.data(i,j,:)))));',filterType))
        if strcmp(filterType,'filtfilt')
            tmpSliceOut(j,:) = uint16(filtfilt(ones(1,windowSize)/windowSize,1,double(squeeze(tmpSliceIn(j,:)))));
        elseif strcmp(filterType,'filt')
            tmpSliceOut(j,:) = uint16(filt(ones(1,windowSize)/windowSize,1,double(squeeze(tmpSliceIn(j,:)))));            
        end
    end
    dataOut(i,:,:) = tmpSliceOut;
end
fprintf(' Done.\n')
