function [yTide,dnTide] = sixMileReef

fname = 'xtide_cornfieldPoint3miS_currents.txt';

[yTide,dnTide] = loadXTide(fname);

conversion = 0.5144; %1 naut = 0.5144 m/s
yTide = yTide.*conversion; 