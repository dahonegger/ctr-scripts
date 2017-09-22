%%

ctrEnvironmentalConditions

%% interp to common grid

dt = 1/24/2; % 30 min
grd.dn = datenum([2017 05 15 0 0 0]):dt:datenum([2017 07 01 0 0 0]);

% Armstrong
arm.dt = median(diff(arm.time),'omitnan'); % in days
[arm.met.wspdMax,arm.met.idxMax] = max(arm.met.wspd10,[],2);
arm.met.idxMaxVec = (arm.met.idxMax-1)*numel(arm.met.idxMax) + (1:numel(arm.met.idxMax))';
arm.met.wdirMax = arm.met.wdir_true(arm.met.idxMaxVec);

arm.met.ws = smooth(arm.met.wspdMax,ceil(dt/arm.dt),'rlowess');
arm.met.wsdir = smooth(arm.met.wdirMax,ceil(dt/arm.dt),'rlowess');

grd.arm.wspd = interp1(arm.time,arm.met.ws,grd.dn);
grd.arm.wdir = interp1(arm.time,arm.met.wsdir,grd.dn);

% NDBC
ndbc.dt = median(diff(ndbc.dn),'omitnan');
ndbc.ws = smooth(ndbc.wspd10,ceil(dt/ndbc.dt),'rlowess');
ndbc.wsdir = smooth(ndbc.wdir,ceil(dt/ndbc.dt),'rlowess');
grd.ndbc.wspd = interp1(ndbc.dn,ndbc.ws,grd.dn);
grd.ndbc.wdir = interp1(ndbc.dn,ndbc.wsdir,grd.dn);
distBad = find(min(abs(ndbc.dn-grd.dn),[],1) > 2*dt);
grd.ndbc.wspd(distBad) = nan;
grd.ndbc.wdir(distBad) = nan;