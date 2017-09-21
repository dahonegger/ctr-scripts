%% SCRIPTS
scrDir = '/nfs/depot/cce_u1/haller/shared/honegger/radar/usrs/connecticut/ctr-scripts/';
addpath(genpath(scrDir))

%% CUBES LOCATION
% This is on SMAUG
cubeDir = fullfile('/media','CTR HUB 2','DAQ-data','processed');

%% OUTPUT LOCATION
pngDir = '/nfs/attic/hallerm/RADAR_DATA/CTR/supportData/vesselData/RADAROVERLAYS/2017-06-28/';
if ~exist(pngDir,'dir');mkdir(pngDir);end

%% LOAD GPS
gpsDir = '/nfs/attic/hallerm/RADAR_DATA/CTR/supportData/vesselData/ctr_dawntreader_nav/surfboard_gps/';
gps = load(fullfile(gpsDir,'nav_surfboard.mat'));

gps.dnutc = gps.dn+4/24; % EDT2UTC
gps.dvutc = datevec(gps.dnutc);

gps.lonSmooth = smooth(gps.lon,3);
gps.latSmooth = smooth(gps.lat,3);


%% June 23rd

ii = find(gps.dvutc(:,3)==28);% & gps.dvutc(:,4)<15);

Cube = stackTimex(cubeDir,gps.dnutc(ii(1)),gps.dnutc(ii(end)),2/60/24);
Cube = cartCube(Cube);
[Cube.lat,Cube.lon] = UTMtoll(Cube.ydom,Cube.xdom,18); % Zone number 18
alpha = (max(Cube.lat(:))-min(Cube.lat(:)))/(max(Cube.lon(:))-min(Cube.lon(:)));

%%
dd = 5;
fig = figure('visible','off');
ax = gca;
    hp = pcolor(Cube.lon(1:dd:end,:),Cube.lat(1:dd:end,:),Cube.data(1:dd:end,:,1));
        shading interp;axis image
        colormap(hot)
        caxis([5 200])
        title(datestr(Cube.dn(1)))
        xlabel('Longitude')
        ylabel('Latitude')
        box on
    set(gca,'dataaspectratio',[1 alpha 1])
    hold on
    hg = plot(gps.lon(ii(1:11)),gps.lat(ii(1:11)),'.-c');
    hn = plot(gps.lon(ii(2)),gps.lat(ii(2)),'ow','markerfacecolor','k','linewidth',1.5);
    
    
%%
for i = 6:1:length(ii)-5
    fprintf('%d of %d\n',i,length(ii))
    
    gpsi = max(1,i-5):min(i+5,length(ii));
    
    [~,radari] = min(abs(Cube.dn-gps.dnutc(ii(i))));
    radari = radari(1);
    hp.CData = Cube.data(1:dd:end,:,radari);
    
    set(hg,'XData',gps.lon(ii(gpsi)),'YData',gps.lat(ii(gpsi)))
    set(hn,'XData',gps.lon(ii(i)),'YData',gps.lat(ii(i)))
    
    gpsStr = sprintf('\\makebox[4in][c]{Surfboard GPS Time: %s EDT}',datestr(gps.dn(ii(i))));
    radStr = sprintf('\\makebox[4in][c]{Radar Time Span: %s - %s}',datestr(Cube.dn(radari)-40/86400-4/24),datestr(Cube.dn(radari)+40/86400-4/24,'HH:MM:SS'));
    title({gpsStr,radStr},'fontsize',12,'interpreter','latex')
    
    ax.XLim = gps.lonSmooth(ii(i))+.005*[-1 1];
    ax.YLim = gps.latSmooth(ii(i))+.005*[-1 1]*alpha;
    
    pngName = sprintf('gpsOnRadar-%sEDT.png',datestr(gps.dn(ii(i)),'yyyymmdd-HHMMSS'));
    print(fig,'-dpng','-r100',fullfile(pngDir,pngName))
end
    
%% FRONT CROSSING TIMES

% 2017 06 27 08 32 03;
dnCross = datenum([...
2017 06 28 06 53 18;
2017 06 28 06 57 17;
2017 06 28 06 58 57;
2017 06 28 07 02 26;
2017 06 28 07 04 42;
2017 06 28 07 07 54;
2017 06 28 07 09 45;
2017 06 28 07 11 11;
2017 06 28 07 12 49;
2017 06 28 07 14 59;
2017 06 28 07 16 35;
2017 06 28 07 18 41;
2017 06 28 07 19 48;
2017 06 28 07 22 04;
2017 06 28 07 23 13;
2017 06 28 07 24 30;
2017 06 28 07 26 24;
2017 06 28 07 27 39;
2017 06 28 07 29 02;
2017 06 28 07 30 29;
2017 06 28 07 31 43;
2017 06 28 07 32 59;
2017 06 28 07 34 03;
2017 06 28 07 35 27;
2017 06 28 07 36 13;
2017 06 28 07 40 11;
2017 06 28 07 41 56;
2017 06 28 07 52 19;
2017 06 28 08 08 01;
2017 06 28 08 13 57;
2017 06 28 08 20 16;
2017 06 28 08 28 03;
2017 06 28 08 43 37;
2017 06 28 08 54 03 ...
]);

clear transect
fig.Visible = 'on';
for iCross = 1:length(dnCross)
    fprintf('%d of %d\n',i,length(ii))
    
    
    [~,i] = min(abs(gps.dn(ii)-dnCross(iCross)));
    gpsi = max(1,i-5):min(i+5,length(ii));
    
    [~,radari] = min(abs(Cube.dn-gps.dnutc(ii(i))));
    radari = radari(1);
    hp.CData = Cube.data(1:dd:end,:,radari);
    
    set(hg,'XData',gps.lon(ii(gpsi)),'YData',gps.lat(ii(gpsi)))
    set(hn,'XData',gps.lon(ii(i)),'YData',gps.lat(ii(i)))
    
    gpsStr = sprintf('\\makebox[4in][c]{Surfboard GPS Time: %s EDT}',datestr(gps.dn(ii(i))));
    radStr = sprintf('\\makebox[4in][c]{Radar Time Span: %s - %s}',datestr(Cube.dn(radari)-40/86400-4/24),datestr(Cube.dn(radari)+40/86400-4/24,'HH:MM:SS'));
    title({gpsStr,radStr},'fontsize',12,'interpreter','latex')
    
    ax.XLim = gps.lonSmooth(ii(i))+.005*[-1 1];
    ax.YLim = gps.latSmooth(ii(i))+.005*[-1 1]*alpha;
    
    
    doClickLine = true;
    while doClickLine
        try
            % Click front line & get x-y
            [fLon,fLat,~,hpf] = ginputLine;
            [fNorth,fEast] = lltoUTM(fLat,fLon);

            % Get gps coords on either side of front
            if floor(dnCross(1))==datenum([2017 06 26 0 0 0])
                if iCross >= 24 % LIS-ebb front
                    lisIdx = find(gps.lon(ii(gpsi))<mean(fLon));
                    ctrIdx = find(gps.lon(ii(gpsi))>mean(fLon));
                else % LIS-flood front
                    lisIdx = find(gps.lat(ii(gpsi))<mean(fLat));
                    ctrIdx = find(gps.lat(ii(gpsi))>mean(fLat));
                end
            else
                lisIdx = find(gps.lon(ii(gpsi))<mean(fLon));
                ctrIdx = find(gps.lon(ii(gpsi))>mean(fLon));
            end


            lisLon = gps.lon(ii(gpsi(lisIdx)));
            lisLat = gps.lat(ii(gpsi(lisIdx)));
            [lisNorth,lisEast] = lltoUTM(lisLat,lisLon);
            ctrLon = gps.lon(ii(gpsi(ctrIdx)));
            ctrLat = gps.lat(ii(gpsi(ctrIdx)));
            [ctrNorth,ctrEast] = lltoUTM(ctrLat,ctrLon);
% 
            if mean(diff(lisLon))>0
                txIdx = [lisIdx(end) ctrIdx(1)];
            else
                txIdx = [ctrIdx(end) lisIdx(1)];
            end
            txLon = gps.lon(ii(gpsi(txIdx)));
            txLat = gps.lat(ii(gpsi(txIdx)));
            [txNorth,txEast] = lltoUTM(txLat,txLon);

            % Calculate global angles
            fTheta   = atand((diff(fNorth)/diff(fEast)))+90;
%             lisTheta = atand(diff(lisNorth)./diff(lisEast));
%             ctrTheta = atand(diff(ctrNorth)./diff(ctrEast));
%             txTheta  = atand(diff(txNorth)./diff(txEast));

%             % Calculate cross-front angles
%             txPhi  = txTheta  - fTheta;
%             lisPhi = lisTheta - fTheta;
%             ctrPhi = ctrTheta - fTheta;
%             if txPhi>90
%                 txPhi = txPhi-180;
%             elseif txPhi<-90
%                 txPhi = txPhi+180;
%             end
%             if lisPhi>90
%                 lisPhi = lisPhi-180;
%             elseif lisPhi<-90
%                 lisPhi = lisPhi+180;
%             end
%             if ctrPhi>90
%                 ctrPhi = ctrPhi-180;
%             elseif ctrPhi<-90
%                 ctrPhi = ctrPhi+180;
%             end

%             % Calculate cross-front distance
            [txPosEast,txPosNorth] = lineIntersect(txEast,txNorth,fEast,fNorth);
%             lisDX = lisEast(1:end-1)+diff(lisEast)/2;
%             lisDY = lisNorth(1:end-1)+diff(lisNorth)/2;
%             ctrDX = ctrEast(1:end-1)+diff(ctrEast)/2;
%             ctrDY = ctrNorth(1:end-1)+diff(ctrNorth)/2;
% 
%             lisS = hypot(lisDX-txPosEast,lisDY-txPosNorth);
%             ctrS = hypot(ctrDX-txPosEast,ctrDY-txPosNorth);

            % Plot result
            [fx,fy] = pol2cart(fTheta*pi/180,.001);
            [txPosLat,txPosLon] = UTMtoll(txPosNorth,txPosEast,18);
            hpr = quiver(txPosLon,txPosLat,fx,fy*alpha,0,'c','linewidth',2);

            % Get user go-ahead
            drawnow
            xlabel('Happy? LMB=yes; RMB=no.')
            [~,~,button] = ginput2(1,'circle');
            switch button
                case 1
                    delete(hpf)
                    delete(hpr)
                    doClickLine = false;
                otherwise
                    delete(hpf)
                    delete(hpr)
                    doClickLine = true;
            end
        catch
            delete(hpf)
            delete(hpr)
            doClickLine = true;
        end
    end
    
    
    % Save to transect structure
    transect(iCross).surfboardDateNum = dnCross(iCross);
    transect(iCross).radarImageTimespan = Cube.dn(radari)+40/86400*[-1 1] - 4/24; % Hardcode to 80s
    transect(iCross).frontHeading = fTheta;
%     transect(iCross).localAngle = txPhi;
%     transect(iCross).lisAngles = lisPhi;
%     transect(iCross).ctrAngles = ctrPhi;
%     transect(iCross).lisApproxDistanceFromFront = lisS;
%     transect(iCross).ctrApproxDistanceFromFront = ctrS;
%     transect(iCross).units = 'Times: MATLAB datenum EDT; Angles: Degrees CCW from front-normal; Distance: Meters';
    transect(iCross).units = 'Times: MATLAB datenum EDT; Angles: Degrees CCW from East';
    
    
%     fprintf('Local angle: %f degrees\n',txPhi)
    
    
%     pngName = sprintf('gpsOnRadar-%sEDT.png',datestr(gps.dn(ii(i)),'yyyymmdd-HHMMSS'));
%     print(fig,'-dpng','-r300',fullfile(pngDir,pngName))
end

save(fullfile(pngDir,sprintf('frontHeading_%s',datestr(floor(dnCross(1)),'yyyy-mm-dd'))),'-v7.3','transect')