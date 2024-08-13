x1=linspace(-0.5,0.585,40);
x2=linspace(0.585,pi/2,40);
x3=linspace(pi/2,3);
y1=exp(-x1);
y2=sin(x2);
y3=0.8+sin(5*x3)*0.2

x=-2:.01:4;
y=x.^2-2*x+1.4;

b=plot([x1,x2,x3],[y1,y2,y3]);
b=plot(x,y);
set(b,'linewidth',2)
grid
bodechange

