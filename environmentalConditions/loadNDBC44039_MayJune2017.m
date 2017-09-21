dat = importdata('May-June2017.txt');

dv = cat(2,dat.data(:,1:5),0*dat.data(:,1));
dat.dn = datenum(dv);
dat.wdir = dat.data(:,6);
dat.wspd = dat.data(:,7);
dat.wgst = dat.data(:,8);
dat.wvht = dat.data(:,9);
dat.dpd  = dat.data(:,10);
dat.apd  = dat.data(:,11);
dat.mwd  = dat.data(:,12);
dat.atmp = dat.data(:,14);

dat.wdir(dat.wdir==999) = nan;
dat.wspd(dat.wspd==99)  = nan;
dat.wgst(dat.wgst==99)  = nan;
dat.wvht(dat.wvht==99)  = nan;
dat.dpd(dat.dpd==99)  = nan;
dat.apd(dat.apd==99)  = nan;
dat.mwd(dat.mwd==99)  = nan;
dat.atmp(dat.atmp==99)  = nan;

dat.readme = [...
    'Long Island Sound NDBC buoy 44039, May-June 2017:                ';
    'dn   = matlab datenum in utc                                     ';
    'wdir = wind direction in degrees true (nautical convention)      ';
    'wspd = wind speed in m/s                                         ';
    'wgst = wind gust in m/s                                          ';
    'wvht = significant wave height in m                              ';
    'dpd  = dominant wave period in s                                 ';
    'apd  = average wave period in s                                  ';
    'mwd  = mean wave direction in degrees true (nautical convention) ';
    'atmp = air temperature in degrees Celsius                        '];
    
save('ndbc44039','-v7.3','-struct','dat')