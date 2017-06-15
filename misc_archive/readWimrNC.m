load CapeD_20130529T092600Z.mat
%% User input
interpFlag = 1;
nRot = 12;

%% Constants 
nAzi = 512;

%% Generate regular grid (if interp)

grd.rg = vars.range;
grd.azi = vars.azimuth(1):0.5:vars.azimuth(512);

[grd.AZI,grd.RG] = meshgrid(grd.azi,grd.rg);
[grd.X,grd.Y] = pol2cart((90-grd.AZI)*pi/180,grd.RG);

%% Generate image(s)

figure;

hold on;

axis image;
axis(5000*[-1 1 -1 1]);

if interpFlag
    hh = pcolor(grd.X,grd.Y,0*grd.X);
end

for i = 1:nRot
    aziVec = (nAzi*(i-1)+1):nAzi*i;
    
    dat.azi = vars.azimuth(aziVec);
    dat.rg = vars.range; 
    
    [dat.AZI,dat.RG] = meshgrid(dat.azi,dat.rg);
    dat.I = vars.return_intensity(:,aziVec);
    
    dat.AZI = double(dat.AZI);
    dat.RG = double(dat.RG);
    dat.I = double(dat.I);
    
    if interpFlag
        Itmp = nan*grd.X;
        parfor iRg = 1:length(grd.rg)
            Itmp(iRg,:) = interp1qr(dat.AZI(iRg,:)',dat.I(iRg,:)',grd.azi(:));
        end
        grd.I = Itmp;
%         interpolantFunc = scatteredInterpolant(dat.AZI(:),dat.RG(:),dat.I(:));
%         grd.I = interpolantFunc(double(grd.AZI),double(grd.RG));

%         pcolor(grd.X,grd.Y,grd.I)
        hh.CData = grd.I;
    else
        [dat.X,dat.Y] = pol2cart(pi/2-dat.AZI*pi/180,dat.RG);
        pcolor(dat.X,dat.Y,dat.I)
    end
        shading flat
        colormap(hot)
        caxis([15 150])
        
    title(sprintf('Sweep Number %.0f',i))
    
    drawnow
    pause(0.1)
end