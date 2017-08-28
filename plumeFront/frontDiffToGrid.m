function [frontDiffGrd,fig] = frontDiffToGrid(frontDiff)

dbug = 1;
dx = 30; % Grid size in meters

%%% Regular Grid
xg = min([frontDiff(:).east]):dx:max([frontDiff(:).east]);
yg = min([frontDiff(:).north]):dx:max([frontDiff(:).north]);
[Xg,Yg] = meshgrid(xg,yg);
[Latg,Long] = UTMtoll(Yg,Xg,18);

%%% Time grid
for i = 1:length(frontDiff)
    frontDiff(i).DN = frontDiff(i).dn*ones(size(frontDiff(i).c));
    frontDiff(i).TideHour = frontDiff(i).tideHr*ones(size(frontDiff(i).c));
end

%%% Interpolants
fInt  = scatteredInterpolant([frontDiff(:).east]',[frontDiff(:).north]',[frontDiff(:).c]','linear');
cxInt = scatteredInterpolant([frontDiff(:).east]',[frontDiff(:).north]',[frontDiff(:).cx]','linear');
cyInt = scatteredInterpolant([frontDiff(:).east]',[frontDiff(:).north]',[frontDiff(:).cy]','linear');
dnInt = scatteredInterpolant([frontDiff(:).east]',[frontDiff(:).north]',[frontDiff(:).DN]','linear');
thInt = scatteredInterpolant([frontDiff(:).east]',[frontDiff(:).north]',[frontDiff(:).TideHour]','linear');
Cg    = fInt(Xg,Yg);
Cxg   = cxInt(Xg,Yg);
Cyg   = cyInt(Xg,Yg);
DNg   = dnInt(Xg,Yg);
THg   = thInt(Xg,Yg);

%%% Bounding polygon for mask
clear xmin xmax ymin ymax
for i = 1:length(frontDiff)
    xmin(i) = frontDiff(i).east(1);
    xmax(i) = frontDiff(i).east(end);
    ymin(i) = frontDiff(i).north(1);
    ymax(i) = frontDiff(i).north(end);
end
xv = [fliplr(frontDiff(1).east(:)') xmin(2:end-1) (frontDiff(end).east(:)') fliplr(xmax(2:end-1))];
yv = [fliplr(frontDiff(1).north(:)') ymin(2:end-1) (frontDiff(end).north(:)') fliplr(ymax(2:end-1))];

%%% Create mask
inp = inpolygon(Xg,Yg,xv,yv);
maskg = double(inp);
maskg(~maskg) = nan;

%%% Generate output structure
frontDiffGrd.X = Xg;
frontDiffGrd.Y = Yg;
frontDiffGrd.Lat = Latg;
frontDiffGrd.Lon = Long;
frontDiffGrd.C = Cg;
frontDiffGrd.Cx = Cxg;
frontDiffGrd.Cy = Cyg;
frontDiffGrd.DN = DNg;
frontDiffGrd.tideHr = THg;
frontDiffGrd.mask = maskg;

if dbug
    fig = figure;
    ax = gca;
    hold on
    hg = contourf(Long,Latg,THg.*maskg,-3.5:.125:3.5,'linestyle','none');
    hg2 = contour(Long,Latg,THg.*maskg,-3.5:.5:3.5,'color',[.5 .5 .5]);
%     hp = plot([frontDiff(:).lon],[frontDiff(:).lat],'.b');
%     hv = plot(xv,yv,'.-g');
    dd = 10;
    mapFac = cosd(nanmean(Latg(:)));
    qFac = .01;
    hq = quiver(Long(1:dd:end,1:dd:end),Latg(1:dd:end,1:dd:end),qFac*Cxg(1:dd:end,1:dd:end).*maskg(1:dd:end,1:dd:end),qFac*Cyg(1:dd:end,1:dd:end).*maskg(1:dd:end,1:dd:end)*mapFac,0,'k');
    box on;grid on
    xlabel('Longitude');ylabel('Latitude')
    tideHrs = [frontDiff(:).tideHr];
    [~,idx] = nanmin(abs(tideHrs));
    title(sprintf('Max Ebb: %s EDT',datestr(frontDiff(idx).dn-4/24)))
    hc = colorbar;caxis([-3.5 3.5]);ylabel(hc,'Hr since max ebb','interpreter','latex','fontsize',12)
    colormap(flipud(brewermap([],'RdBu')))
    set(ax,'dataaspectratio',[1 mapFac 1])
    
    hRef = quiver(min(Long(:)),min(Latg(:)),qFac*.5*(-1/sqrt(2)),qFac*.5*(-1/sqrt(2)),0,'r');
    txtReg = text(min(Long(:)),min(Latg(:)),'50 cm/s','horizontalalignment','center','verticalalignment','bottom','interpreter','latex','fontsize',10,'color',[1 0 0]);
end