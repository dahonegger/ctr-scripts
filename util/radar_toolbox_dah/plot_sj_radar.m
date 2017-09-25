%  function [] = plot_sj_radar(Cube,framebyframe,fname)
function [] = plot_sj_radar(Cube,frames,tstep)
%load rad_cube;

% im = imread('/nfs/lennon/u1/haller/shared/public_html/matlab_files/SJnew.jpg');
% create a timestamp string:
% c_tmst=clock; c_yr=c_tmst(:,1); cfn=sprintf('%04d%07d', c_yr, fname); ct=datestr(now,'local');
% t_vec=[c_tmst(1,1) c_tmst(1,2) c_tmst(1,3) c_tmst(1,4) 15 0];
% t_tm=datestr(t_vec,0);
this=Cube;

%% first, retrieve some parameters from structure array:
Heading=this.results.heading;
%% Convert to polar and cartesian
r=this.Rg; %ground range
%average Azimuths, in radians, in Matlab space but with Y axis horizontal
tht=(-Heading-this.Azi)*pi/180; 

[R,T]=meshgrid(r,tht(:,1));
[X,Y]=pol2cart(T',R');
%framebyframe=3;
figure;
for frame = frames
        a=double(squeeze(this.data(:,:,frame)));
        
	pcolor(X+this.results.XOrigin,Y+this.results.YOrigin,a);shading interp;axis equal tight;
    caxis([0 max(max(a))*0.5])
    drawnow
%     pause(tstep)
end
% 	hold on
%         iim2 = image(im,'XData',[(415281-3600) (415281+2470)],'YData',[(490576-2950) (4940576+2750)]);
%         %set(iim2, 'AlphaData', 0.4)
%         %set(gca,'YDir','reverse');
%         
%         xlim([(412000) (418400)]);
%         ylim([4938500 4942500]);
%         x=get(gca,'xlim'); y=get(gca,'ylim');
%         iim2 = image(x,y([end 1]),im);
%         uistack(p,'top');
%         
%         title({'Newport South Jetty Hourly Radar Intensity Image'; t_tm}); % num2str(fname)});
%         xlabel('Easting (m) (UTM)');
%         ylabel('Northing (m) (UTM)');
%         caxis([0 255]);
%         colorbar;%set(get(gca,'YLabel'),'String','Radar Intensity'); 
%         drawnow;
% 
% f=figure(1); 
%     %saveas(f,'/nfs/lennon/u1/haller/shared/public_html/images/SouthJetty/Current_Radar_Plot.jpg');
%     im_name='/nfs/lennon/u1/haller/shared/public_html/images/SouthJetty/Current_Radar_Plot';
%     %im_name='/tmp/testplot';
%     %print('-f1', '-djpeg', im_name);