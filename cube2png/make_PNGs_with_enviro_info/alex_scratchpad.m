box1=patch([arX.CP-arH arX.CP-arH arX.CP+arH arX.CP+arH],...
    [arY.CP-arW arY.CP+arW arY.CP+arW arY.CP-arW],'white');
set(box1,'edgecolor','none')
alpha(box1,0.7)

box2=patch([arX.RB-arW arX.RB-arW arX.RB+arW arX.RB+arW],...
    [arY.RB-arH arY.RB+arH arY.RB+arH arY.RB-arH],'white');
set(box2,'edgecolor','none')
alpha(box2,0.7)


%original origins:
arX.RB = 1; arY.RB = 3.2;
arX.CP = arX.RB+(arW+arH); arY.CP = arY.RB-(arH-arW);