function [yTide,dnTide] = railroadBridgeCurrent

fname = 'xtide_saybrookPoints_elevation.txt';

[yTide,dnTide] = loadXTide(fname);