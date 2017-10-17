movieDir = fullfile('C:','Data','CTR','UAS-DATA','script_test');
movieName = '20171791102.MOV';

% Vector (in seconds) of averaging window
% For example, [1/8:1/8:5] is a window 5 seconds wide, sampled from the video at 8 Hz
windowVec = [1/29.97:1/29.97:5];

% Initialize
vid = VideoReader(fullfile(movieDir,movieName));
vid.CurrentTime = windowVec(1);
windowLength = windowVec(end);
fr = vid.FrameRate;

frameSum = single((readFrame(vid)));
frameStill = frameSum;
ct = 1;
mct = 1;
clear mov
while vid.CurrentTime<5%hasFrame(vid) 
%     disp(ct)
        thisFrame = readFrame(vid);
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

% frameMean = frameSum/length(windowVec);
%             
%     for i = 2:length(windowVec)
%         disp(i)
%         vid.CurrentTime = windowVec(i);
%         thisFrame = readFrame(vid);
%         frameMat = cat(4,frameMean,thisFrame);
%         frameMean = uint8(mean(frameMat,4));
%     end
% end
%% Use filters

blueToRed = mov(:,:,3,:)./mov(:,:,1,:);
greenToRed = mov(:,:,2,:)./mov(:,:,1,:);
blueToGreen = mov(:,:,3,:)./mov(:,:,2,:);

varmov = squeeze(var(mov,[],3));
meanmov = squeeze(mean(mov,3));
meanmovWhite = single(meanmov>160);

%%

ctrBox = [1200  400; 1200 1000; 2100 1000; 2100  400];
lisBox = [1400 2100; 1400 1500; 2500 1500; 2500 2100];

ctrIY =  400:800;
ctrIX = 1600:2100;
lisIY = 1500:2100;
lisIX = 1400:2500;

frameMean = mov(:,:,:,1);

figure
plot3(...
    toVect(frameMean(:,:,1),50),...
    toVect(frameMean(:,:,2),50),...
    toVect(frameMean(:,:,3),50),'.k','markersize',1);
hold on
plot3(...
    toVect(frameMean(lisIY,lisIX,1),5),...
    toVect(frameMean(lisIY,lisIX,2),5),...
    toVect(frameMean(lisIY,lisIX,3),5),'.r',...
    toVect(frameMean(ctrIY,ctrIX,1),5),...
    toVect(frameMean(ctrIY,ctrIX,2),5),...
    toVect(frameMean(ctrIY,ctrIX,3),5),'.b','markersize',3);
    grid on;box on
    xlabel('r');ylabel('g');zlabel('b')
figure
plot3(...
    var(toVect(frameMean(lisIY,lisIX,1),5)),...
    var(toVect(frameMean(lisIY,lisIX,2),5)),...
    var(toVect(frameMean(lisIY,lisIX,3),5)),'.r',...
    var(toVect(frameMean(ctrIY,ctrIX,1),5)),...
    var(toVect(frameMean(ctrIY,ctrIX,2),5)),...
    var(toVect(frameMean(ctrIY,ctrIX,3),5)),'.k');
    grid on;box on
    
figure
plot(...
    mean(toVect(var(frameMean(lisIY,lisIX,:),[],3))),...
    std(toVect(var(frameMean(lisIY,lisIX,:),[],3))),'.r',...
    mean(toVect(var(frameMean(ctrIY,ctrIX,:),[],3))),...
    std(toVect(var(frameMean(ctrIY,ctrIX,:),[],3))),'.k');