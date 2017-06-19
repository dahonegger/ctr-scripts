function [yTide,dnTide] = railroadBridgeCurrentLocal

fname = fullfile(fileparts(mfilename('fullpath')),'tideLocal','xtide_railroadBridge_currents.txt');

[yTide,dnTide] = loadXTide(fname);

conversion = 0.5144; %1 naut = 0.5144 m/s
yTide = yTide.*conversion;