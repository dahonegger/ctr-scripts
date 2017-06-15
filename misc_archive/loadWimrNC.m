function Cube = loadWimrNC(fname)


nci = ncinfo(fname);

nVars = length(nci.Variables);

for i = 1:nVars
    try 
        Cube.(nci.Variables(i).Name) = ncread(fname,nci.Variables(i).Name);
        fprintf('Loading %s.\n',nci.Variables(i).Name)
    catch
        fprintf('Failed %s.\n',nci.Variables(i).Name)
    end
        
end


