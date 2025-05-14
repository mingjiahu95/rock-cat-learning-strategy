function [rand_seq,rand_matrix] = randperm_cycle(n, k)
    rand_seq = zeros(1,k);
    n_repeat = ceil(k/n);
    rand_matrix = zeros(n_repeat - 1,n);
    for i_repeat = 1:n_repeat
        indices = (i_repeat - 1)*n + (1:n);
        rand_seq(indices) = randperm(n);
        k_remain = k - (i_repeat - 1) * n;
        if  k_remain < n && nargout == 2
            warning('The last %i numbers cannot be included in the matrix output.',k_remain);
        else
           rand_matrix(i_repeat,:) = randperm(n);
        end
    end
    rand_seq = rand_seq(1:k);
end