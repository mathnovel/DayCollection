t=[-1 0 0 1 1 2 2 3 3 4 4 5 5 15];
u=[0 0 2 2 1.5 1.5 1 1 1.8 1.8 2.2 2.2 2.4 2.4];

tt=linspace(0,15,100);
uu=2.4*(1-exp(-0.3*tt));
uuu=[zeros(1,8),-sin(0:.12:3.1),zeros(1,66)];
figure(1); clf reset
plot(t,u,'b','linewidth',2); hold on
plot(tt,uu+uuu,'r','linewidth',2); 