% This is a demo of how we can put in time-stamped paths with custom
% properties to visualize data in G-E. The demo will load some of the LTTS
% waypoints from Craig's vehicle with time stamps, and plot them in GE. We
% create 4 different KML files, with different kinds of information
% encoded. 
%
% The first (kml_1) is the simple version, with just the lat-lon paths. 
% 
% The second (kml_2) will include a random altitude, and a color based on
% the time the point was reached. This could equivalently be surface
% soundspeed, temp, salinity, etc. 
% 
% Then, kml_3 uses the size of the icon to encode additional information (in this
% case SNR) but again could be used for any variable. 
%
% Finally, kml_4 adds in the final 2 pieces: icon style and icon
% description. The icon styles could be used to indicate status (on/off),
% while the description is meant to mirror the output of VIP where you can
% encode vehicle information into the icon description. It takes a
% structure input to return the desired description.  
% 
% Dan Plotnick, APL-UW, 5-1-17. 
% =========================================================================
% Load in the data, make the datestr we want
% -------------------------------------------------------------------------
load UW;
cmin=22.48;cmax=22.75;
g=find(UW.LBL_longitude<-90 & UW.LBL_latitude>30.394);

for i=1:max(size(UW.LBL_time))
    t=UW.LBL_time(i);
    hr=floor(t);
    min=60*(t-hr);
    sec=floor(60*(min-floor(min)));
    
    UW.LBL_MT(i)=datenum(cat(2,'06-Mar-2017 ',num2str(hr),':',num2str(min),':',num2str(sec)));
end
datestr(UW.LBL_MT) %check; use me as input into new GE function

% =========================================================================
% Convert value (time, in this case) to RGB
% -------------------------------------------------------------------------
% There are a bunch of knobs here, look at the examples in this function to
% see them. This does he same thing your code did, with the same limits. 
color = val2rgb(UW.LBL_time(g),'range',[22.48, 22.75]);

% =========================================================================
% Create our simple KML file
% =========================================================================
% This one should just contain lat-lon pairs at 0 altitude relative to
% ground and with no time attached. 
kmlPoints('kml_1',UW.LBL_longitude(g),UW.LBL_latitude(g));

% =========================================================================
% Add in color and a time stamp
% =========================================================================
% We could also add in an altitude vector using 'alt',alt_vec. I am making
% one up, since I dont have any. We can also leave off any of these:
% 'alt','time',or 'iconColor'.
alt = -3+rand(size(color,1),1);

kmlPoints('kml_2',UW.LBL_longitude(g),UW.LBL_latitude(g),...
    'alt',alt,...
    'time',UW.LBL_MT(g),...
    'iconColor',color);

% =========================================================================
% Let's go nuts. Add in scale.
% =========================================================================
% This is where I started my rapid downhill slide. There are a bunch of
% parameters of the icons that can be easily changed to encode more
% information. Here, I am using the LBL_INBAND_SNR to encode the size of
% the icon. 
scale = val2size(UW.LBL_inband_snr_1(g),[0.5,2],[50 120]); 
% This function also has a bunch of knobs, see the documentation.
% Effectively, I have mapped SNRs over the range [50 120] to sizes [0.5, 2].
kmlPoints('kml_3',UW.LBL_longitude(g),UW.LBL_latitude(g),...
    'iconScale',scale,...
    'time',UW.LBL_MT(g),...
    'iconColor',color);

% =========================================================================
% And more: descriptions, names, and icon style
% =========================================================================
% We can change the icon style so that we don't get my default circle in
% there. This is going to take a cell array of strings corresponding to the
% icon styles' names. Empty cells will use the default. This is a good way
% to encode information that is discrete such as 'lbl active/inactive'. 

% Some arbitrary icon styles 
testStyles = cell(length(scale),1);
testStyles{1} = 'placemark_circle';
testStyles{23} = 'placemark_circle';
testStyles{28} = 'placemark_square';
testStyles{41} = 'placemark_square';
testStyles{14} = 'forbidden';
testStyles{34} = 'forbidden';
testStyles{22} = 'forbidden';

% I am also going to add in a name for some of the placemarks. Empties will
% be...empty. 
testNames = cell(length(scale),1); 
testNames{1} = 'start';
testNames{end} = 'finish';

% Let's finally add in some descriptions. These could be just character
% strings, or they can be structures so that we can reproduce the output of
% VIP, where additional information is stored in the description. Here, we
% take advantage of the name-value pair style of the structures. These also
% all go into a cell-array. As you will see, only char-strings or
% single-element numerical arrays will be written into the descriptions. 

testDescription1 = struct('Thing1',4,...
    'Thing2','purple',...
    'Thing3',rand(4));
testDescription2 = struct('Thing3','blitz',...
    'Thing4',pi,...
    'Thing5',rand(4));
testDescription3 = 'GoCougs';

% And we pick some of our placemarks randomly to receive the treatment.
% Empty cells will not have a description. 
testDescriptions = cell(length(scale),1);
testDescriptions{4} = testDescription1;
testDescriptions{28} = testDescription1;
testDescriptions{17} = testDescription2;
testDescriptions{1} = testDescription3;
testDescriptions{34} = testDescription3;

% And lets write one last kml, to check. 
kmlPoints('kml_4',UW.LBL_longitude(g),UW.LBL_latitude(g),...
    'time',UW.LBL_MT(g),...
    'iconColor',color,...
    'iconScale',scale,...
    'iconName',testNames,...
    'iconDescription',testDescriptions,...
    'iconStyle',testStyles);

% Final Note: You may need to turn of all of the other KMLs when you look
% at these, overlapping points are ambiguous as to how they will render.
% Also, the time slider is still finicky. If you want, I can look into how
% to define default views, but that nay just not be worth it. 
%
% Also, while depth is in there (negative altitude), it doesn't really do
% anything to the GE image since the display default is 'clamp to ground'. 