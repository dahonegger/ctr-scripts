function [frame,dnOut] = getWavg(fname,dn,filterSize)

% Test if Cube is size of filter
load(fname,'header','timeInt')
if header.rotations <= filterSize
    useTimex = true;
else
    useTimex = false;
end

if useTimex
    load(fname,'timex')
    if ~exist('timex','var') || isempty(timex)
        load(fname,'data')
        frame = uint8(mean(data,3));
    end
    dnOut = epoch2Matlab(mean(timeInt(:)));
else
    load(fname,'data')
    % Find corresponding frame to time
    dnRots = epoch2Matlab(mean(timeInt));
    idx = find(abs(dnRots-dn)==min(abs(dnRots-dn)));
    if mod(filterSize,2)==0
        isEven = true;
    else
        isEven = false;
    end
    if isEven
        minIdx = filterSize/2;
        maxIdx = header.rotations-filterSize/2;
        idx = max(idx,minIdx);
        idx = min(idx,maxIdx);
        idxVec = idx-(filterSize/2)+1:idx+(filterSize/2);
    else
        minIdx = (filterSize-1)/2 + 1;
        maxIdx = header.rotations - (filterSize-1)/2;
        idx = max(idx,minIdx);
        idx = min(idx,maxIdx);
        idxVec = idx-(filterSize-1)/2:idx+(filterSize-1)/2;
    end
    frame = mean(data(:,:,idxVec),3);
    dnOut = dnRots(idx);
end