G=tf(1,[1 1]);
[y,t]=step(G);
figure(1);clf reset
plot(t,y,'linewidth',2);hold on
for k=1:10;
    plot([0.5*k,0.5*k],[0,1],'k--','linewidth',2);
end
xlim([0 5])

G=tf(1,[1 1]);
[y,t]=step(G);
u=randn(1,101)*0.04+0.4;
tt=0:0.05:5;
[y,t]=lsim(G,u*2,tt);
figure(2);clf reset
plot(t,y,'linewidth',2);hold on
plot(tt,u,'r','linewidth',2);
for k=1:100;
    plot([0.05*k,0.05*k],[0,1],'k--','linewidth',1);
end
xlim([0 2])
ylim([0,0.7])