function pk = betabinompmf(k, n, modeval, conc)
    % Convert modeval and conc to alpha (alphaval) and beta (betaval)
    alphaval = 1 + conc * modeval;
    betaval = 1 + conc * (1 - modeval);

    % Compute the PMF of the beta binomial distribution
    coeff = nchoosek(n, k);
    numerator = beta(k + alphaval, n - k + betaval);
    denominator = beta(alphaval, betaval);
    pk = coeff * (numerator / denominator);
      
end