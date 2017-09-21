function [yTide,dnTide] = railroadBridgeElevation

fname = 'xtide_saybrookPoints_elevation.txt';

[yTide,dnTide] = loadXTide(fname);