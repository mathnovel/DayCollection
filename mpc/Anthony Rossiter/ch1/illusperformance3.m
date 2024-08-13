G1=tf(2^2,[1 2*2*0.3 2^2]);
G2=tf(4^2,[1 2*4*0.25 4^2]);
G3=tf(0.8^2,[1 2*0.8*0.4 0.8^2]);
G4=tf(1^2,[1 2*1*1.3 1^2]);

b=figure(1);clf reset
[y1,t]=step(G1,10);
[y2]=step(G2,t);
[y3]=step(G3,t);
[y4]=step(G4,t);
b=plot(t,y3,'b',[0,0,10],[0,1,1],'r');
set(b,'linewidth',2)
grid
bodechange
xlim([-2 10])

