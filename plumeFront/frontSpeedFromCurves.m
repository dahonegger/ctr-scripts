function [dFront] = frontSpeedFromCurves(front)

if length(front)<2
    dFront = [];
    warning('frontSpeedFromCurves: Insufficient number of fronts for differencing.')
    return
end

dbug = 0;
% thresholdTime = 31*60; % 31 min
smoothingFactor = .1;

for i = 1:length(front)
    [front(i).north,front(i).east] = lltoUTM(front(i).lat,front(i).lon);
    front(i).s = getDistance(front(i).east,front(i).north);
    
    front(i).east = smooth(front(i).s,front(i).east,smoothingFactor,'lowess');
    front(i).north = smooth(front(i).s,front(i).north,smoothingFactor,'lowess');
end

if dbug
    dbfig = figure;
    dbax = gca;
    hold on
    hc = colorbar;
        hAll = plot(cat(1,front(:).east),cat(1,front(:).north),'.','color',[.5 .5 .5]);
        axis(dbax,'image')
end

for i = 1:length(front)-1

    dFront(i).dn = mean([front(i).dn,front(i+1).dn]);
    dFront(i).tideHr = mean([front(i).tideHr,front(i+1).tideHr]);
    
    dFront(i).dt_sec = (front(i+1).dn-front(i).dn)*86400;
    
    [dFront(i).east,dFront(i).north,dFront(i).dist,dFront(i).theta] = diffCurve(...
        [front(i).east(:)    front(i).north(:)   ],...
        [front(i+1).east(:)  front(i+1).north(:) ]);
    
    dFront(i).c = dFront(i).dist/dFront(i).dt_sec;
    dFront(i).cx = dFront(i).c .* cos(dFront(i).theta);
    dFront(i).cy = dFront(i).c .* sin(dFront(i).theta);
    
    isGood = find(...
        ~isnan(dFront(i).c.*dFront(i).east) & ...
        ~isinf(dFront(i).c.*dFront(i).east));
    
    dFront(i).east      = dFront(i).east(isGood);
    dFront(i).north     = dFront(i).north(isGood);
    dFront(i).c         = dFront(i).c(isGood);
    dFront(i).cx        = dFront(i).cx(isGood);
    dFront(i).cy        = dFront(i).cy(isGood);
    dFront(i).dist      = dFront(i).dist(isGood);
    dFront(i).theta     = dFront(i).theta(isGood);
    
    if dbug
        hPair = plot(front(i).east,front(i).north,'.b',front(i+1).east,front(i+1).north,'.r');
        hd = quiver(dFront(i).east,dFront(i).north,dFront(i).cx,dFront(i).cy,'r');
%         hd = scatter(dFront(i).east,dFront(i).north,20,dFront(i).c,'filled');
        title(dbax,i)
        axis([min(cat(1,front(i:i+1).east)) max(cat(1,front(i:i+1).east)) ...
            min(cat(1,front(i:i+1).north)) max(cat(1,front(i:i+1).north))])
        drawnow
        if dbug>1
            pause
        end
        delete(hPair)
        delete(hd)
    end
        
    
end

for i = 1:length(dFront)
    len(i) = length(dFront(i).c);
end
dFront(len==0) = [];

for i = 1:length(dFront)
    [dFront(i).lat,dFront(i).lon] = UTMtoll(dFront(i).north,dFront(i).east,18);
end

if dbug
    close(dbfig);
end
end