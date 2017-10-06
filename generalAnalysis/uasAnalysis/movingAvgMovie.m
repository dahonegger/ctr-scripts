function mov = movingAvgMovie(fileName,windowLength,sampleRate)

% movieDir = fullfile('C:','Data','CTR','UAS-DATA','script_test');
% movieName = '20171791102.MOV';

% Initialize
vid = VideoReader(fileName);
nativeFrameRate = vid.FrameRate;

% Vector (in seconds) of averaging window
% For example, [1/8:1/8:5] is a window 5 seconds wide, sampled from the video at 8 Hz
dt = 1/sampleRate;
windowVec = [dt:dt:windowLength];

vid.CurrentTime = windowVec(1);
frameSum = single((readFrame(vid)));
frameStill = frameSum;
ct = 1;
mct = 1;
while vid.CurrentTime<20%hasFrame(vid) 
%     disp(ct)
        thisFrame = readFrame(vid);
        if min(abs(vid.CurrentTime-windowVec))<(1/nativeFrameRate/2)
            disp(vid.CurrentTime)
            frameMat = cat(4,frameSum,single((thisFrame)));
            frameSum = sum(frameMat,4);
%             frameMean = single(sum(cat(4,frameMean,rgb2gray(thisFrame)),4));
            
        elseif vid.CurrentTime>max(windowVec)
            
            mov(:,:,:,mct) = frameSum/length(windowVec);
            fprintf('mov %.f\n',mct)
            frameSum = thisFrame;
            mct = mct+1;
            windowVec = windowVec+windowLength;
        end
        
        
        ct = ct+1;
        
end
