function [timeOut,dataOut] = boxfiltCube(timeIn,dataIn,varargin)

switch nargin
    case 2
        wSize = 50;
        dd = wSize;
    case 3
        wSize = varargin{1};
        dd = wSize;
     case 4
        wSize = varargin{1};
        dd = varargin{2};
end

[nRange,nAzi,nRot] = size(dataIn);

i = 1;
tmpIn = double(squeeze(dataIn(i,:,:)))';
[tmpDataLP,timeOut] = boxfilt(tmpIn,wSize,timeIn,dd);
dataOut = uint8(zeros(nRange,nAzi,length(timeOut)));
dataOut(i,:,:) = uint8(tmpDataLP)';

for i = 2:nRange
    if mod(i,100)==0
        fprintf('%d of %d.\n',i,nRange)
    end
    tmpIn = double(squeeze(dataIn(i,:,:)))';
    [tmpDataLP,~] = boxfilt(tmpIn,wSize,timeIn,dd);
    dataOut(i,:,:) = uint8(tmpDataLP)';
end