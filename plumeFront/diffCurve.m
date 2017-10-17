function [xMid,yMid,ds,theta] = diffCurve(xy1,xy2)
% Given two curves xy1 (Mx2) and xy2 (Mx2), diffCurve calculates the
% segment midpoints and the segment-normal distance between the curves

dbug = 0;
angleThreshold = pi/6; % 30 deg
distanceThreshold = 2000;
distanceIncreaseFactorThreshold = 10;


if dbug
    fig = figure;
    ax = gca;
        hp0 = plot(xy1(:,1),xy1(:,2),'.-k',xy2(:,1),xy2(:,2),'.-b');
        axis equal
        axis([min([xy1(:,1);xy2(:,1)]) max([xy1(:,1);xy2(:,1)]) min([xy1(:,2);xy2(:,2)]) max([xy1(:,2);xy2(:,2)])]) 
        hold on
end

nseg1 = size(xy1,1)-1;
nseg2 = size(xy2,1)-1;

ds = nan(1,nseg1);
xMid = ds;
yMid = ds;
theta = ds;
for i = 1:nseg1
    seg1.xy1 = xy1(i,:);
    seg1.xy2 = xy1(i+1,:);
    seg1.dx = diff([seg1.xy2(1),seg1.xy1(1)]);
    seg1.dy = diff([seg1.xy2(2),seg1.xy1(2)]);
    
    [xm,ym,m,b] = makeNormalLine(seg1.xy1,seg1.xy2);
    if isinf(abs(m)) % If slope is inf (line is horizontal)
        dist = hypot(seg1.xy1(1)-seg1.xy2(1),seg1.xy1(2)-seg1.xy2(2));
        seg1.xy2(2) = seg1.xy2(2)+.001*dist;
        [xm,ym,m,b] = makeNormalLine(seg1.xy1,seg1.xy2);
    end
        
    if dbug
        title('Working ...')
        hp1(1) = plot([seg1.xy1(1),seg1.xy2(1)],[seg1.xy1(2),seg1.xy2(2)],'.-k','linewidth',3);
        hp1(2) = plot(xm,ym,'ok','markerfacecolor','k');
        hp1(3) = plot(ax.XLim,m*ax.XLim+b,':k');
    end
    
    tmp.ds = [];tmp.xMid = [];tmp.yMid = [];
    count = 1;
    for j = 1:nseg2
        seg2.xy1 = xy2(j,:);
        seg2.xy2 = xy2(j+1,:);
        seg2.dx = diff([seg2.xy2(1),seg2.xy1(1)]);
        seg2.dy = diff([seg2.xy2(2),seg2.xy1(2)]);
        
        if dbug>1
            hp2(1) = plot([seg2.xy1(1),seg2.xy2(1)],[seg2.xy1(2),seg2.xy2(2)],'.-b','linewidth',3);
            drawnow
        end
        
        % Find the intersection point between the segment-1 normal and
        % segment-2. Returns NaN if the intersection point does not lie on
        % segment-2
        [xi,yi] = crossPoint(seg1.xy1,seg1.xy2,seg2.xy1,seg2.xy2);
        
        if isnan(xi)
            if dbug>1
                delete(hp2)
                drawnow    
            end
            continue
        end
        % Quality control: segment angle difference can't exceed threshold
        seg1.ang = mod(atan2(seg1.dy,seg1.dx),2*pi);
        seg2.ang = mod(atan2(seg2.dy,seg2.dx),2*pi);
        angDiff = abs(wrapToPi(seg1.ang-seg2.ang));
        if angDiff>pi/2 % Always less than or equal to 90 degrees
            angDiff = abs(angDiff-pi);
        end
        if (angDiff> angleThreshold)
            xi = nan;
            yi = nan;
            if dbug>1
                fprintf('QCflag: Threshold angle difference exceeded. Angle difference is %.f degrees.\n',angDiff*180/pi)
                keyboard
            end
        end
        
        % Quality control 1: Enforce maximum distance threshold
        if hypot(xi-xm,yi-ym) > distanceThreshold
            xi = nan;
            yi = nan;
            if dbug>1
                disp('QCflag: Threshold distance exceeded.')
                keyboard
            end
        end
        
        % Quality control: only allow a distance increase/decrease of a
        % threshold factor
        if i>1 && ~isnan(ds(i-1))
            tmpds = hypot(xi-xm,yi-ym);
            if (tmpds > hypot(seg1.dx,seg1.dy)) && (tmpds > distanceIncreaseFactorThreshold*ds(i-1))
                xi = nan;
                yi = nan;
                if dbug>1
                    disp('QCflag: Threshold distance increase exceeded.')
                    keyboard
                end
            end
        end
        
        % Find the midpoint along the line between the segment-1 midpoint
        % and segment-2
        tmp.ds(count) = hypot(xi-xm,yi-ym);
        [tmp.xMid(count),tmp.yMid(count),~,~] = makeNormalLine([xm,ym],[xi,yi]);
        tmp.theta(count) = wrapToPi(atan2(tmp.yMid(count)-ym,tmp.xMid(count)-xm));

        if dbug
            hp1(4) = plot([xm xi],[ym yi],'-r','linewidth',2);
            hp0(2) = plot(tmp.xMid(count),tmp.yMid(count),'or','markerfacecolor','r');
            drawnow
        end
        count = count+1;
        
        if dbug>1
            delete(hp2)
            drawnow
        end
        
    end
    
    if ~isempty(tmp.ds)
        if i==1 || isnan(ds(i-1)) || ds(i-1)==0
            [ds(i),idx] = min(tmp.ds);
            xMid(i) = tmp.xMid(idx);
            yMid(i) = tmp.yMid(idx);
            theta(i) = tmp.theta(idx);
        else
%             if min(tmp.ds)>distanceIncreaseFactorThreshold*ds(i-1)
%                 break
%             else
                [ds(i),idx] = min(tmp.ds);
                xMid(i) = tmp.xMid(idx);
                yMid(i) = tmp.yMid(idx);
                theta(i) = tmp.theta(idx);
%             end
        end
        if dbug
           [u,v] = pol2cart(theta,ds);
            hp3(i) = quiver(ax,xMid,yMid,u,v,0,'r');
        end
        
    end
    
    if dbug>1
        if isempty(tmp.ds)
            title('No Intersection Found')
        else
            title('Intersection Found')
        end
        
        
        pause()
        delete(hp1)
    end
    
end

if dbug
    title('Done')
    response = input('Look okay? Enter if "yes", anything else if "no": ','s');
    if ~isempty(response)
        keyboard
    end
    delete(fig)
end

end


% From two points, find midpoint and create normal line
function [xm,ym,mn,bn] = makeNormalLine(xy1,xy2)

xy = [xy1(1),xy1(2);xy2(1) xy2(2)];

% CALC MIDPOINT
xm = mean(xy(:,1));
ym = mean(xy(:,2));

% CALC SLOPE
m = diff(xy(:,2))/diff(xy(:,1));

% NEW SLOPE
mn = -1./m;

% NEW INTERCEPT
bn = ym-mn*xm;

end

% From two points, get slope and y-intercept
function [m,b] = lineFunc(xy1,xy2)

xy = [xy1(1),xy1(2);xy2(1) xy2(2)];

% CALC SLOPE
m = diff(xy(:,2))/diff(xy(:,1));

% CALC Y-INTERCEPT
b = xy(1,2)-m*xy(1,1);
end

% From two line functions, get x-intersect
function xi = xIntersect(mb1,mb2)

    xi = (mb2(2)-mb1(2))/(mb1(1)-mb2(1));
end

% From a line segment and another line segment, determine if the normal of
% the first crosses the second; if it does, find the intersection point
function [xi,yi] = crossPoint(xy11,xy12,xy21,xy22)

seg1.xy1 = xy11;
seg1.xy2 = xy12;
seg2.xy1 = xy21+eps*ones(size(xy21));
seg2.xy2 = xy22+eps*ones(size(xy22));

% Create "Line A": Project segment-normal line from first segment midpoint
[seg1.xm,seg1.ym,seg1.mn,seg1.bn] = makeNormalLine(seg1.xy1,seg1.xy2);
% Create "Line B": Find line parameters (m & b) of second segment
[seg2.m,seg2.b] = lineFunc(seg2.xy1,seg2.xy2);
% Find the x,y location at which "Line A" intersects "Line B":
xi = xIntersect([seg1.mn seg1.bn],[seg2.m,seg2.b]);
yi = seg1.mn.*xi+seg1.bn;

% Determine if the intersection point lies along the second segment
% (quality control)
if seg2.xy1(1)==seg2.xy2(1) % If second segment is vertical
    % Check if intersection is between the y-vals
    if yi >= min([seg2.xy1(2) seg2.xy2(2)]) && yi < max([seg2.xy1(2) seg2.xy2(2)])
        %%% Intersection is good
    else
        xi = nan;
        yi = nan;
    end
elseif seg2.xy1(2)==seg2.xy2(2) % If second segment is horizontal
    % Check if intersection is between the x-vals
    if xi >= min([seg2.xy1(1) seg2.xy2(1)]) && xi < max([seg2.xy1(1) seg2.xy2(1)])
        %%% Intersection is good
    else
        xi = nan;
        yi = nan;
    end
else % Then second segment is diagonal in some way
    % Check if intersection is between both the x-vals and the y-vals
    if (xi >= min([seg2.xy1(1) seg2.xy2(1)]) && xi < max([seg2.xy1(1) seg2.xy2(1)])) ...
            && (yi >= min([seg2.xy1(2) seg2.xy2(2)]) && yi < max([seg2.xy1(2) seg2.xy2(2)]))
        %%% Intersection is good
    else
        xi = nan;
        yi = nan;
    end
end
end