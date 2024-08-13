%%% SISO Model and GPC parameters
a=[1 -1.7 1.2];
b=[1 -1.4];
sizey=1;  %%% siso
ny=12;
nu=4;
lambda=1;
Dumax=0.2;
umax=1;
umin=-1.5;
ref = [zeros(1,10),ones(1,30)];
dist=ref*0;
noise = ref*0;
[y,u,Du,r] = mpc_simulate_overlay(b,a,nu,ny,lambda,1,Dumax,umax,umin,ref,dist,noise);
