theta_u=atand(10^-6);
theta_u/10-atand(10^-7)
%%
cycle=[3*ones(1,25);
       1,kron(ones([1 6]),[4 2 2 1]);
       1*ones(1,13),2*ones(1,12)];
time.ic=6sum(cycle);
time.ii=11*5*6;
time.s=time.i+time.ii
