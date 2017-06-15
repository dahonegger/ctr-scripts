close all; clear all;
tic
addpath(genpath('C:\Data\CTR\scripts-master'))
cubeFile='D:\Data\CTR\DAQ-data\processed\2017-06-10\LyndePt_20171610000_pol.mat';
timexFile= 'D:\Data\CTR\postprocessed\timex_tides\LyndePt_20171610000_pol_timex.png';
cube2timex_tides(cubeFile,timexFile)
toc
