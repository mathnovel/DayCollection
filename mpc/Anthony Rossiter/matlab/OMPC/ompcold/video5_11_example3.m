%%%%%  Typical data entry required for a 
%%%%%  MIMO state space  example
%%%%%    x(k+1) = A x(k) + B u(k)
%%%%%    y(k) = C x(k) + D u(k) + dist     Note: Assumes D=0
%%%%%
%%%%%   Assumes J = sum x(k+i) Q x(k+1) + u(k+i-1) R u(k+i-1)
%%%%%
%%%%%         and uses    (u-uss) = -k(x-xss)       *ss for steady-state
%%%%%
%%%%%  Illustrates closed-loop simulations with constraint handling
%%%%%  
%%%%%
%%%%%   THIS IS A SCRIPT FILE. CREATES ITS OWN DATA AS REQUIRED
%%%%%   EDIT THIS FILE TO ENTER YOUR OWN MODELS, ETC.
%%  
%% Author: J.A. Rossiter  (email: J.A.Rossiter@shef.ac.uk)

%% Model
A =[0.9 0.2;0 0.8];
B =[0.544   -0.757;
    0.53    1.477];
C =[1 0.5; -0.2 0.6];
D=zeros(2,2);

%% Tuning for prediction parameters
Q=C'*C;
R=eye(2);
nc=5;   %%% no. of d.o.f.
%%% parameters for performance index
Q2=Q; R2=R;

%% Constraints
umax=[1;2];
umin=-[1;2];
Kxmax=[0 0];
xmax=100;
npred=30;

x0=[0;0];    %%% Initial condition


ref = [zeros(2,20),[2*ones(1,40);ones(1,40)],[4*ones(1,20);2*ones(1,20)]];  %% Set point
dist = [zeros(2,40),-ones(2,40)*.4];              %% Disturbance
noise = [zeros(2,40),randn(2,40)*.04]*0;           %% noise

%%%%% Closed-loop simulation 
[x,y,u,c,r] = sompc_simulate(A,B,C,D,Q,R,Q2,R2,nc,umin,umax,Kxmax,xmax,npred,x0,ref,dist,noise);

figure(1); clf reset
v=2:length(y);runtime=length(y);
subplot(221);plot(v,y(:,v)','b','linewidth',2);hold on
plot(v,r(:,v)','k--');
title(['SOMPC output for n_c=',num2str(nc)],'fontsize',18)
subplot(222);plot(v,u(:,v)','m','linewidth',2);hold on
plot([0,runtime],[umax(1),umax(1)],'m--',[0,runtime],[umin(1),umin(1)],'m--');
plot([0,runtime],[umax(2),umax(2)],'c--',[0,runtime],[umin(2),umin(2)],'c--');
title('Inputs','fontsize',18)
subplot(223);plot(v,c(:,v)','linewidth',2);title('c_k for SOMPC','fontsize',18)
subplot(224);plot(v,dist(:,v)','linewidth',2);
title('Disturbance signal','fontsize',18)