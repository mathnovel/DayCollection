x=linspace(0,3,20);
y=linspace(2,-1,20);
d=[0 0 0.1 ,0.2,0.1,0.3,-0.1 -0.2,0 0.1,0,0.1,0.1,-0.1,-0.2,-0.2,-0.1,0,0.1,0];
y=y+d;
p=polyfit(x(1:6),y(1:6),1)

figure(1);clf reset
plot(x,y,'ro','markersize',10);hold on
plot(x,polyval(p,x),'b','linewidth',2);

x=linspace(0,5,200);
y=sin(x);
p=polyfit(x,y,1)

figure(1);clf reset
plot(x,y,'r','linewidth',2);hold on
plot(x,polyval(p,x),'b','linewidth',2);