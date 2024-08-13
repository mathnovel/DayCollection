%%%%%%%%%%%%%%                         (WITH T-filter!!)
%%%%%%%%%%%%%%   Simulates MIMO GPC with constraint handling
%%%%   OVERLAYS THE UNCONSTRAINED CONTROL CHOICE
%%%%   WARNING - INCLUSION OF OUTPUT CONSTRANTS CAN CAUSE INFEASIBILITY -
%%%%   THIS CODE IS NOT DESIGNED TO BE ROBUST TO SUCH CASES!
%%%
%%%%%  [y,u,Du,r] = mpc_simulate_tfilt_outputconstraints(B,A,Tfilt,nu,ny,Wu,Wy,Dumax,umax,umin,ymax,ymin,ref,dist,noise)
%              y, u, Du, r are dimensionally compatible 
% closed-loop outputs/inputs/input increments and supplied set-point and disturbance
%
% MFD model     Ay(k) = Bu(k-1) + Tfilt*dist
%
% ny is output horizon
% nu is the input horizon
% Wu is the diagonal control weighting 
% Wy is the diagonal output weighting
% sizey no. outputs and inputs (assumed square)
% dist, noise are the disturbance and noise signals
% ref is the reference signal
% Dumax is a vector of limits on input increments (assumed symetric)
% umax, umin are vectors of limits on the inputs
%
%%%%%
%%%%%  [y,u,Du,r] = mpc_simulate_tfiltoutputconstraints(B,A,Tfilt,nu,ny,Wu,Wy,Dumax,umax,umin,ymax,ymin,ref,dist,noise)
%%  
%% Author: J.A. Rossiter  (email: J.A.Rossiter@shef.ac.uk)

function [y,u,Du,r] = mpc_simulate_tfiltoutputconstraints(B,A,Tfilt,nu,ny,Wu,Wy,Dumax,umax,umin,ymax,ymin,ref,dist,noise)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Error checks
sizey = size(A,1);
if size(B,2)==sizey;B=[B,zeros(sizey,sizey)];end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Find prediction matrices 
%%%%    yfut = H *Dufut + P*Dupast + Q*ypast
%%%%    yfut = H *Dufut + Pt*Dutpast + Qt*ytpast   %% filtered data
[H,P,Q] = mpc_predmat(A,B,ny);
[Pt,Qt] = mpc_predtfilt(H,P,Q,Tfilt,sizey,ny);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Find control law and parameters of the cost function
%%%%   Dufut = Pr*rfut - Dk*Dutpast - Nk*ytpast 
%%%%    J = Dufut'*S*Dufut + Dufut'*2X*[Dutpast;ytpast;rfut]

[Nk,Dk,Pr,S,X] = mpc_law(H,Pt,Qt,nu,Wu,Wy,sizey);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   Define constraint matrices
%%%%%%   CC*Du(future) - dd - du*u(k-1))-ddu*Dupast-dy*ypast <= 0
[CC,dd,du,ddu,dy]  = mpc_constraints2(Dumax,umax,umin,ymax,ymin,sizey,nu,H(:,1:nu*sizey),Pt,Qt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Set up simulation parameters
nNk = size(Nk,2)/sizey;
nDk = size(Dk,2)/sizey;
nT = size(Tfilt,2)/sizey;
T2 = Tfilt(:,sizey+1:nT*sizey);
nA = size(A,2)/sizey;
nB = size(B,2)/sizey;
init = max([nNk,nDk,nA,nB])+2;
y = zeros(sizey,init);    yt=y;
u = y;ufast=u;
Du = u;     Dut = u;
r = u;
d=u;
opt = optimset('quadprog');
opt.Diagnostics='off';    %%%%% Switches of unwanted MATLAB displays
opt.LargeScale='off';     %%%%% However no warning of infeasibility
opt.Display='off';
opt.Algorithm='active-set';
runtime = size(ref,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=init:runtime-ny-1;
   
    %%% Update unconstrained control law

    
    %%%%% Update filtered data
    ytpast = yt(:,i-1:-1:i-nT+1);
    yt(:,i) = y(:,i) + noise(:,i) - T2*ytpast(:);
    Dutpast = Dut(:,i-2:-1:i-nT);
    Dut(:,i-1) = Du(:,i-1) - T2*Dutpast(:);

   
%%% Define vectors of past filtered data for use by control law
d(1:sizey,i+1)=dist(:,i+1);
ypast = yt(:, i:-1:i+1-nNk);
Dupast = Dut(:, i-1:-1:i-nDk) ;
upast = u(:, i-1);
rfut = ref(:,i+1); 

%%%%%%% Unconstrained law - if needed
Dufast = Pr*rfut - Nk*ypast(:) - Dk*Dupast(:);

% Form constraint matrices and solve constrained optimisation
%%%%%%   CC*Du(future) - dd - du*u(k-1))-ddu*Dupast-dy*ypast <= 0]
%%% note past is filtered data
%  J = Dufut'S*Dufut+2*X*[Dupast(:);ypast(:);rfut(:)]*Dufut
dt = dd+du*upast(:)+ddu*Dupast(:)+dy*ypast(:);
f=X*[Dupast(:);ypast(:);rfut(:)];
[Duqp,fval,exitflag] = quadprog(S,f,CC,dt,[],[],[],[],[],opt);
if exitflag==-2; %%% output constraints causing a problem so ignore
    disp(['Ignoring output constraints at sample ',num2str(i)]);
  vec=1:4*nu*sizey;
  [Duqp,fval,exitflag] = quadprog(S,f,CC(vec,:),dt(vec),[],[],[],[],[],opt);
end
Du(:,i) = Duqp(1:sizey);
u(:,i) = u(:,i-1)+Du(:,i);

%  Ensure the constraints satisfied by proposed control law   
for j=1:sizey;
   if u(j,i)>u(j,i-1)+Dumax(j),u(j,i)=u(j,i-1)+Dumax(j);end
   if u(j,i)<u(j,i-1)-Dumax(j),u(j,i)=u(j,i-1)-Dumax(j);end
   if u(j,i)>umax(j); u(i)=umax(j);end
   if u(j,i)<umin(j); u(i)=umin(j);end
end
Du(:,i) = u(:,i)-u(:,i-1);
%  End to update control law


%%% Simulate the process
upast2 = u(:,i:-1:i-nB+1);
ypast2 = y(:, i:-1:i+2-nA);
y(:,i+1) = -A(:,sizey+1:nA*sizey)*ypast2(:) + B*[upast2(:)]+ d(:,i+1);
r(:,i+1) = ref(:,i+1);


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Ensure all outputs are dimensionally compatible
u(:,i+1) = u(:,i);
Du(:,i+1) = Du(:,i)*0;
noise = noise(:,1:i+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Produce a neat plot
time=0:size(u,2)-1;
for i=1:sizey;
    figure(i+3);clf reset
    plotall(y(i,:),r(i,:),u(i,:),Du(i,:),d(i,:),noise(i,:),umax(i),umin(i),Dumax(i),ymin(i),ymax(i),time,i);
end


disp('*******************************************************************************');
disp(['***    For GPCT there are ',num2str(sizey),' figures beginning at figure 4   ***']);
disp('*******************************************************************************');




%%%%% Function to do plotting in the MIMO case and 
%%%%% allow a small boundary around each plot

function plotall(y,r,u,Du,d,noise,umax,umin,Dumax,ymin,ymax,time,loop)

uupper = [umax,umax]';
ulower = [umin,umin]';
yupper = [ymax,ymax]';
ylower = [ymin,ymin]';
Dulim = [Dumax,Dumax]';
time2 = [0,time(end)];
rangeu = (max(umax)-min(umin))/10;
rangey = (max(ymax)-min(ymin))/10;
ranged = (max(max([d,noise]))-min(min([d,noise])))/20;

subplot(221);plot(time,y','-',time,r','--',time2,yupper,'--',time2,ylower,'--');
axis([time2,ymin-rangey,ymax+rangey]);
xlabel(['GPCT - Outputs and set-point in loop ',num2str(loop)]);
subplot(222);plot(time,Du','-',time2,Dulim,'--',time2,-Dulim,'--');
axis([time2,min(-Dumax)-rangeu,max(Dumax)+rangeu]);
xlabel(['GPCT - Input increments in loop ',num2str(loop)]);
subplot(223);plot(time,u','-',time2,uupper,'--',time2,ulower,'--');
axis([time2,min(umin)-rangeu,max(umax)+rangeu]);
xlabel(['GPCT - Inputs in loop ',num2str(loop)]);
subplot(224);plot(time,d','b',time,noise,'g');
if max(abs([d,noise]))>0;
    axis([time2,min(min([d,noise]))-ranged,max(max([d,noise]))+ranged]);
end
xlabel(['GPCT - Disturbance/noise in loop ',num2str(loop)]);
