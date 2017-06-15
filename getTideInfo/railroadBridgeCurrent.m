function [yTide,dnTide] = railroadBridgeCurrent

fname = 'xtideData/xtide_railroadBridge_currents.txt';

[yTide,dnTide] = loadXTide(fname);