% movieDir = fullfile('C:','Data','CTR','UAS-DATA','script_test');
% movieName = '20171791102.MOV';
movieDir = fullfile('D:','uasData','09.11.17 Guadalupe (rips)');
movieName = 'DJI_0046.MP4';

%%
dd = 2;

vid = VideoReader(fullfile(movieDir,movieName));

windowVec = [.25:.25:.5]; % in frames
windowLength = windowVec(end);

vid.CurrentTime = windowVec(1);
fr = vid.FrameRate;

frameSum = single((readFrame(vid)));
frameSum = frameSum(1:dd:end,1:dd:end,:);
frameStill = frameSum;

nFramesOut = 240;
mov = repmat(frameStill,[1 1 1 nFramesOut]);

ct = 1;
mct = 1;
grp = 1;
while mct<=nFramesOut%hasFrame(vid) 
%     disp(ct)
        thisFrame = readFrame(vid);
        thisFrame = thisFrame(1:dd:end,1:dd:end,:);
        if min(abs(vid.CurrentTime-windowVec))<(1/fr/2)
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
