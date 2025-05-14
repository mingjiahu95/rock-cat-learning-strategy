param_init = [0.787,21.785,0.842,10.863];
% nparam = 4;
lb = [0,0,0,0];
ub = [1,Inf,1,Inf];

T = readtable('participant_performance.csv');
obs_val{1} = T{T.cond_factor == 1,'y'};
obs_val{2} = T{T.cond_factor == 2,'y'};
          
[param_best,NLL] = fmincon(@(x) error_fun(x,obs_val),param_init,[],[],[],[],lb,ub);
% [param_best,NLL] = particleswarm(@(x) error_fun(x,obs_val),nparam,lb,ub);
              