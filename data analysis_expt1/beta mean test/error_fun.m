function NLL = error_fun(param,obs_val)
% mode1 = param(1);
% conc1 = param(2);
% mode2 = param(3);
% conc2 = param(4);

mode1 = param(1);
conc1 = param(2);
mode2 = param(1);
conc2 = param(3);%param(2)

LL = 0;
for x1 = obs_val{1}'
    px1 = betabinompmf(x1,3*16,mode1,conc1);
    LL = LL + log(px1);
end

for x2 = obs_val{2}'
    px2 = betabinompmf(x2,3*16,mode2,conc2);
    LL = LL + log(px2);
end

NLL = -LL;
end