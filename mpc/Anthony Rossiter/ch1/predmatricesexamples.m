%%% Example 1
a=[1 -0.8]
b=[2 1]
A =conv(a,[1 -1])
[Ca,Ha]=caha(A,1,4)
[Cb,Hb]=caha(b,1,4);
Cai=inv(Ca)
H=Cai*Cb
P=Cai*Hb
Q=Cai*Ha

%%% Increase the horizon
[Ca,Ha]=caha(A,1,8);
[Cb,Hb]=caha(b,1,8);
Cai=inv(Ca); H=Cai*Cb,P=Cai*Hb,Q=Cai*Ha

%%% Higher order system
a=[1 -0.8 -0.12 -0.03];
b=[2 -1 0.4 0.2];
A =conv(a,[1 -1]);
[Ca,Ha]=caha(A,1,10);
[Cb,Hb]=caha(b,1,10);
Cai=inv(Ca); H=Cai*Cb,P=Cai*Hb,Q=Cai*Ha

%%% MIMO system Ay = Bu
A=[];B=[];
A(1,1:3:12) = poly([.5,.8,-.2]);
A(2,2:3:12) = poly([-.2,.9,.5]);
A(3,3:3:12) = poly([-.1,.4,.6]);
A(1,5:3:12) = [ -.2 .1 .02];
A(2,4:3:12) = [ .4 0 -.1];
A(3,4:3:12) = [0 .2 .2];
A(2,6:3:12) = [-1 .1 .3];
A(:,4:12) = A(:,4:12)*.8;
B = [.5 0.2 -.5 1 2 1;2 0 .3 -.8 .6 .5;0 .9 -.4 1 .3 .5];
D = [eye(3),-eye(3)]; %% MIMO form of Delta
AD = convmat(A,D); %%% Forms A * Delta

[Ca,Ha]=caha(AD,3,10);
[Cb,Hb]=caha(B,3,10);
Cai=inv(Ca); H=Cai*Cb,P=Cai*Hb,Q=Cai*Ha
whos H P Q

