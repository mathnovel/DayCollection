%%TANK FILL
t=linspace(0,3,30);
h=linspace(0,1.5,30);
t2=linspace(3,5,10);
h2=linspace(1.5,2.5,10);
figure(1); clf
plot(t,h,'k','linewidth',4); hold on
plot(t2,h2,'k--','linewidth',2)
plot([0 5],[2 2],'r--','linewidth',2);
plot([0,3],[1,1],'b-','linewidth',2);
plot([3,5],[1,1],'b--','linewidth',2);

xlabel('time(sec)');
ylabel('depth','fontsize',20);
bodechange