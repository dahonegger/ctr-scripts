%function to interpolate to a snapshot mode the images of the radar. We
%assume that they are in range-azimuth space. note that due to
%interpolation, we can only obtain two images less than the original cube.

function [snapCube,snapTime]=RadarScanToSnap(data,baseTime);

%%
disp('Computing Snaps')
%extracting some info from the data
[nsamples,ncoll,nrot]=size(data);

%now we define the time domain.
%first, we extract the time domain from the data , say from the heading
%times
nref=round(ncoll/2); %defines which azimuth will be used as reference
snapTime=baseTime(nref,2:end-1);

%now we preallocate the new cube
snapCube=uint8(zeros(nsamples,ncoll,nrot-2));

%now we perform the interpolation. We go azimuth by azimuth, because the
%times are different for each.
%%
for jj=1:ncoll
    if(rem(jj,round(ncoll/10))==0)
        fprintf(1,'..done %g percent..\r', jj/ncoll*100)
    end
    for kk=1:nsamples
        slice=squeeze(double(data(kk,jj,:)));
        loctime=squeeze(baseTime(jj,:));
        u=interp1(loctime,slice,snapTime,'linear');
     %   plot(loctime,slice,'.',snapTime,uint8(u),'r');[max(u) max(slice)],pause;
        snapCube(kk,jj,:)=uint8(u);
    end
end
    %
%     try
%         slice=double(squeeze(data(:,jj,:)));
%         if nref~=jj
% 
%             loctime=squeeze(baseTime(jj,:));
%             [samples,loctime]=meshgrid([1:nsamples],loctime);
%             [samples2,snapTime2]=meshgrid([1:nsamples],snapTime);
%             u=griddata(samples(:),loctime(:),slice(:),samples2(:),snapTime2(:));
%             snapCube(:,jj,:)=uint8(reshape(u,[nsamples,1,nrot-2]));
%         else
%             snapCube(:,jj,:)=uint8(data(:,jj,2:end-1));
%         end
%     catch
%         snapCube(:,jj,:)=0;
%     end
%end

