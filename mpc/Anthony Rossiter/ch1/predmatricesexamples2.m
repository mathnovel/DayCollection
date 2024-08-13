%%% Example 1
a=[1 -0.8]
b=[2 1]
h=impulse(tf(b,a,1),40);

[Ca,Ha]=caha([1 -1],1,4)
[Cb,Hb]=caha(h',1,4);
Cai=inv(Ca)
H=Cai*Cb
P=Cai*Hb
Q=Cai*Ha

