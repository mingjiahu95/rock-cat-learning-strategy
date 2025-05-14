% compute the probability density (px) of x (0 < x < 1)
%  from a beta distribution with mode = "modeval" and
%   concentration = "conc", where the concentration parameter 
%    is defined as conc = alpha + beta -  2
%    conc must be constrained to be greater than 0
%
function px = betaprobdens(x,modeval,conc)
alphaval=1 + conc*modeval;
betaval=1 + conc*(1-modeval);
pxnum1 = x^(conc*modeval);
pxnum2 = (1-x)^(conc*(1-modeval));
px = (pxnum1*pxnum2)/beta(alphaval,betaval);


