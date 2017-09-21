dnMax = datenum([2017 6 9 12 43 0 ]);
deltaT = 1;

figure;
for iTime = dnMax-3/24:deltaT/24:dnMax+4/24
    Cube = phaseAvgFromTime(iTime,3);
    Cube = cartCube(Cube);
        tcolor(Cube.xdom,Cube.ydom,double(Cube.timexStack)*255/150/255);
        axis image
        title(datestr(iTime))
        print(gcf,'-dpng',sprintf('tideHr_%s.png',24*(iTime-dnMax)))
end