addpath(genpath('E:/SupportData'))

[current,timeC]=railroadBridgeCurrent;
[elev,timeE]=railroadBridgeElevation;

figure
hold on
yyaxis left
plot(timeC,current,'-b')
ylabel('current')
yyaxis right
plot(timeE,elev,'-k')
ylabel('elevation')
datetick('x')
legend('current','elev')
% xlim([min(timeC),timeC(numel(timeC)./3)])