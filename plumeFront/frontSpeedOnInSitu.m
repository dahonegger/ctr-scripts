function [hFig,hAx,hPl] = frontSpeedOnInSitu(frontDiffGrd,xis,yis)

hFig = figure;
hAx(1) = gca;
% hAx(2) = colorbar;
% colormap(flipud(brewermap([],'RdBu')))

hold(hAx(1),'on')


% Front velocity quiver
LatFac = cosd(nanmean(yis(:)));
LenFac = 0.01;
dd = 8;
hPl(3) = quiver(hAx(1),...
    frontDiffGrd.Lon(1:dd:end,1:dd:end),...
    frontDiffGrd.Lat(1:dd:end,1:dd:end),...
    frontDiffGrd.Cx(1:dd:end,1:dd:end).*frontDiffGrd.mask(1:dd:end,1:dd:end)*LenFac,...
    frontDiffGrd.Cy(1:dd:end,1:dd:end).*frontDiffGrd.mask(1:dd:end,1:dd:end)*LenFac*LatFac,...
    0,'k');


% Tide hour pcolor
% [~,hPl(1)] = contourf(hAx(1),frontDiffGrd.Lon,frontDiffGrd.Lat,frontDiffGrd.tideHr.*frontDiffGrd.mask,-3.5:.125:3.5,'linestyle','none');
[cc,hPl(2)] = contour(hAx(1),frontDiffGrd.Lon,frontDiffGrd.Lat,frontDiffGrd.tideHr.*frontDiffGrd.mask,-3.5:.5:3.5,'color',[1 0 0],'linewidth',1.25);
shading(hAx(1),'interp')
% caxis(hAx(1),[-2.5 2.5])
box(hAx(1),'on')

% In-situ labels
CxInt = scatteredInterpolant(frontDiffGrd.Lon(:),frontDiffGrd.Lat(:),frontDiffGrd.Cx(:),'linear','none');
CyInt = scatteredInterpolant(frontDiffGrd.Lon(:),frontDiffGrd.Lat(:),frontDiffGrd.Cy(:),'linear','none');
for i = 1:length(xis)
    Cx(i)    = CxInt(xis(i),yis(i));
    Cy(i)    = CyInt(xis(i),yis(i));
    if ~isnan(Cx(i))
        if i==1
            hPl(4+i) = text(xis(i),yis(i),...
                sprintf('(%.f, %.f) cm/s',100*Cx(i),100*Cy(i)),...
                'horizontalalignment','left','verticalalignment','top','interpreter','latex',...
                'fontsize',10,'color','b','fontweight','bold','backgroundcolor',[1 1 1]);
        elseif i==2
            hPl(4+i) = text(xis(i),yis(i),...
                sprintf('(%.f, %.f) cm/s',100*Cx(i),100*Cy(i)),...
                'horizontalalignment','right','verticalalignment','bottom','interpreter','latex',...
                'fontsize',10,'color','b','fontweight','bold','backgroundcolor',[1 1 1]);
        end
            
    end
end
% In situ locations
hPl(4) = plot(hAx(1),xis,yis,'ow','markerfacecolor','b','markersize',8,'linewidth',1.5);


% Axis labels
xlabel('Longitude')
ylabel('Latitude')
% ylabel(hAx(2),'Hour After Max Ebb','fontsize',12,'interpreter','latex')
dnMax = frontDiffGrd.DN(find(min(abs(frontDiffGrd.tideHr(:))),1,'first'));
title(sprintf('Max Ebb: %s EDT',datestr(dnMax-4/24)))

% Domain
mLon = mean(xis);
mLat = mean(yis);
dLon = abs(diff(xis));
dLat = abs(diff(yis));
% axis(hAx(1),[mLon mLon mLat mLat] + [-1.5*dLon 1.5*dLon -3*dLat 3*dLat])
set(hAx(1),'dataaspectratio',[1 LatFac 1])

% Contour Label
clabel(cc,hPl(2),'labelspacing',100,'color',[1 0 0],'backgroundcolor',[1 1 1])

% Reference Arrow
lonAx = hAx(1).XLim;
latAx = hAx(1).YLim;
txt = text(lonAx(1),latAx(1),'50 cm/s','horizontalalignment','center','verticalalignment','bottom','color',[0 0 0],'interpreter','latex','fontsize',10,'backgroundcolor',[1 1 1]);
hPl(length(hPl)+1) = quiver(lonAx(1),latAx(1),-cosd(45)*.5*LenFac,-sind(45)*.5*LenFac*LatFac,0,'k','maxheadsize',1);
txt = text(hAx(1).XLim(2),hAx(1).YLim(1),'Hour After Max Ebb','horizontalalignment','right','verticalalignment','bottom','fontsize',10,'color','r','interpreter','latex','backgroundcolor',[1 1 1]);