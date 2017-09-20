function [yTide,dnTide,timeZone] = railroadBridgeCurrent

fname = 'xtide_railroadBridge_currents.txt';

[yTide,dnTide,meta] = loadXTide(fname);

conversion = 0.5144; %1 naut = 0.5144 m/s
yTide = yTide.*conversion;

timeZone = meta.timeZone;