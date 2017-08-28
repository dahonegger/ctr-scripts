function [curve,roi] = img2curve(im,roiIn)
% [curve,roi] = img2curve(im,roiIn) reads image [and optionally roi points]
% and outputs curve indices in i- and j-directions. Additionally outputs
% roi points
%
% im:                   image array (regular grid)
% roiIn.x, roiIn.y:     user input region of interest points for mask
%
% curve.x, curve.y:     output x & y indices of ridge/front/etc.
% roi.x, roi.y:         utilized roi points for mask
%
% 2017-June-19 David Honegger
%
%

doBilateralFilter   = true;
doMask              = true;
doFrangiFilter      = true;
doLowPassFilter     = false;

db = false;
if db
    figure;
    subplot(2,2,1)
        imshow(im)
        title('input')
end

imIn = im;
if doBilateralFilter
    im = uint8(bfWrapper(double(im)));
    imBf = im;
    if db
        subplot(2,2,2)
        imshow(im)
        title('bilateral filter')
    end
end

if doMask
    if ~exist('roiIn','var') || isempty(roiIn)
        figROI = figure('position',[0 0 1280 720]);
            [mask,roi.x,roi.y] = roipoly(im);
        close(figROI)
    else
        [mask,roi.x,roi.y] = roipoly(im,roiIn.x,roiIn.y);
    end
end

if doFrangiFilter
    opts.BlackWhite = false;
    opts.FrangiScaleRange = [1 3];
    opts.FrangiScaleRatio = 1; %3
    [im,scale,direction] = FrangiFilter2D(double(im),opts);
    imFr = im;
    if db
        subplot(2,2,3)
        imshow(im)
        title('frangi filter')
    end
end

if doLowPassFilter
    lowPassSize = [5 5];
    hfLowpass = fspecial('average',lowPassSize);
    im = filter2(hfLowpass,im);
    imLp = im;
    if db
        subplot(2,2,4)
        imshow(im)
        title('lowpass filter')
    end
end

imMasked = im.*mask;


%% RETURN COLUMN MAXIMA
xMaximaCol = nan(size(imMasked,2),1);
yMaximaCol = nan(size(imMasked,2),1);
for i = 1:size(imMasked,2)
    if std(imMasked(:,i))>0
        [~,idx] = max(imMasked(:,i));
        yMaximaCol(i) = idx;
        xMaximaCol(i) = i;
    else
        yMaximaCol(i) = nan;
        xMaximaCol(i) = nan;
    end
end
%% RETURN ROW MAXIMA
xMaximaRow = nan(size(imMasked,1),1);
yMaximaRow = nan(size(imMasked,1),1);
for i = 1:size(imMasked,1)
    if std(imMasked(i,:))>0
        [~,idx] = max(imMasked(i,:));
        xMaximaRow(i) = idx;
        yMaximaRow(i) = i;
    else
        xMaximaRow(i) = nan;
        yMaximaRow(i) = nan;
    end
end

%% SORT & ORGANIZE
% Concatenate to all points
xMaximaAll = [xMaximaCol(:);xMaximaRow(:)];
yMaximaAll = [yMaximaCol(:);yMaximaRow(:)];

% Sort by y-axis
[yMaximaAll,sortIdx] = sort(yMaximaAll);
xMaximaAll = xMaximaAll(sortIdx);

% Remove NaNs
nanIdx = isnan(xMaximaAll.*yMaximaAll);
xMaximaAll(nanIdx) = [];
yMaximaAll(nanIdx) = [];

% Remove redundant positions
[~,idxUnique] = unique([xMaximaAll(:) yMaximaAll(:)],'rows');
xMaximaAll = xMaximaAll(idxUnique);
yMaximaAll = yMaximaAll(idxUnique);
% idxSame = setdiff(1:length(xMaximaAll),idxUnique);
% yMaximaAll(idxSame) = yMaximaAll(idxSame)+1e-3;

%% SMOOTH ALONG TRANSECT
[~,idxFar] = max(yMaximaAll);
sMaximaAll = hypot(xMaximaAll-xMaximaAll(idxFar),yMaximaAll-yMaximaAll(idxFar));
[sMaximaSorted,idxSort] = sort(sMaximaAll);
xMaximaSorted = xMaximaAll(idxSort);
yMaximaSorted = yMaximaAll(idxSort);

xMaximaSmooth = smooth(sMaximaSorted,xMaximaSorted,9,'rloess');
yMaximaSmooth = smooth(sMaximaSorted,yMaximaSorted,9,'rloess');


% Remove redundant positions
% [~,idxUnique] = unique([xMaximaSorted(:) yMaximaSorted(:) sMaximaSorted(:)],'rows');
% xMaximaSorted = xMaximaSorted(idxUnique);
% yMaximaSorted = yMaximaSorted(idxUnique);
% sMaximaSorted = sMaximaSorted(idxUnique);

% [~,idxUniqueX] = unique(xMaximaSorted);
% [~,idxUniqueY] = unique(yMaximaSorted);
% xMaximaSorted = xMaximaSorted(intersect(idxUniqueX,idxUniqueY));
% yMaximaSorted = yMaximaSorted(intersect(idxUniqueX,idxUniqueY));
% sMaximaSorted = sMaximaSorted(intersect(idxUniqueX,idxUniqueY));

%% CHOOSE ENDPOINTS
figEndpoints = figure;
    imshow(imIn)
    hold on
    plot(xMaximaSmooth,yMaximaSmooth,'--r')
    
    iPoint = 0;
    notDone = true;
    while notDone
        title('Click LMB on/near front endpoints')
        iPoint = iPoint + 1;
        [xp,yp,~] = ginput2(1,'cross');
        hClick = plot(xp,yp,'xb');
        d = hypot(xMaximaSmooth-xp,yMaximaSmooth-yp);
        di = find(abs(d)==min(abs(d)));
        hNearest = plot(xMaximaSmooth(di),yMaximaSmooth(di),'ob');
        title('Happy? LMB=yes RMB=no')
        [~,~,button] = ginput2(1,'circle');
        if button~=1
            iPoint = iPoint - 1;
            delete(hClick)
            delete(hNearest)
        else
            iEnd(iPoint) = di(1);
        end
        if iPoint==2
            notDone = false;
        end
    end
if diff(iEnd)<0
    iEnd = flipud(iEnd(:));
end
iInside = iEnd(1):iEnd(2);
xMaximaSmoothIn = xMaximaSmooth(iInside); 
yMaximaSmoothIn = yMaximaSmooth(iInside);  
sMaximaSmoothIn = hypot(xMaximaSmoothIn-xMaximaSmoothIn(end),yMaximaSmoothIn-yMaximaSmoothIn(end));
% Re-sort

% % % [sMaximaSmoothIn,sIdx] = sort(sMaximaSmoothIn);
% % % xMaximaSmoothIn = xMaximaSmoothIn(sIdx);
% % % yMaximaSmoothIn = yMaximaSmoothIn(sIdx);

% hampelWidths = [128 16 8 3];
% for iWidth = hampelWidths
%     xMaximaSmooth = hampel(xMaximaSortedIn,iWidth);
%     yMaximaSmooth = hampel(yMaximaSortedIn,iWidth);
% end

% smoothingWidth = 5;
% xMaximaSmooth2 = smooth(xMaximaSmooth,smoothingWidth,'rloess');
% yMaximaSmooth2 = smooth(yMaximaSmooth,smoothingWidth,'rloess');

% hp = plot(xMaximaSmoothIn,yMaximaSmoothIn,'-g');
% title('This is what you did. I hope you''re happy!')
% drawnow;
delete(figEndpoints)
% 
% [sUnique,iUnique] = unique(sMaximaSorted);
% xUnique = xMaximaSmooth(iUnique);
% yUnique = yMaximaSmooth(iUnique);
% sReg = min(sMaximaSmoothIn):max(sMaximaSmoothIn);
curve.x = xMaximaSmoothIn;%interp1(sMaximaSmoothIn,xMaximaSmoothIn,sReg);
curve.y = yMaximaSmoothIn;%interp1(sMaximaSmoothIn,yMaximaSmoothIn,sReg);
% %% NOW TWEAK TO MOVE BACK UP TO THE RIDGE
% 
% tx.IrBf = bfWrapper(double(tx.Ir),2);
% tx.IrBf = filter2(hfLowpass,tx.IrBf);
% tx.IrBf = tx.Ir;
% tx.sFrontTweak = nan(size(tx.dnr));
% for i = 1:length(tx.dnr)
%     if ~isnan(tx.sFront(i))
%         thisIdx = interp1(tx.s,1:length(tx.s),tx.sFront(i),'nearest');
%         thisTx = smooth(tx.s,tx.IrBf(i,:),9);
% %         keyboard
%         iter = 0;
%         while diff(thisTx(thisIdx-1:thisIdx+1),2)>0
%             thisSlope = mean(diff(thisTx(thisIdx-1:thisIdx+1)));
%             thisIdx = thisIdx + sign(thisSlope);
%             iter = iter+1;
%             fprintf('Tweak: %s. Iter %.f.\n',datestr(tx.dnr(i)),iter)
%         end
%         tx.sFrontTweak(i) = tx.s(thisIdx);
%         
%     else
%         tx.sFrontTweak(i) = nan;
%     end
% end
