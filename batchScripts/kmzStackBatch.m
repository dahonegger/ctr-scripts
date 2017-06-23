if exist('kmzStackGen.log','file')
	!rm -f kmzStackGen.log
end

diary('kmzStackGen.log')
disp(datestr(now))

kmzName = kmzAutoCat(1,1);       % Previous 1 hour, all files
%eval(['!chmod a+r ',kmzName])

kmzName = kmzAutoCat(3,2);       % Previous 3 hours, every 2 files
%eval(['!chmod a+r ',kmzName])

kmzName = kmzAutoCat(6,3);       % Previous 6 hours, every 3 files
%eval(['!chmod a+r ',kmzName])

kmzName = kmzAutoCat(12,6);      % Previous 12 hours, every 6 files
%eval(['!chmod a+r ',kmzName])

kmzName = kmzAutoCat(24,9);      % Previous day, every 9 files
%eval(['!chmod a+r ',kmzName])

kmzName = kmzAutoCat(48,9);      % Previous 2 days, every 9 files
%eval(['!chmod a+r ',kmzName])


diary('off')

exit
