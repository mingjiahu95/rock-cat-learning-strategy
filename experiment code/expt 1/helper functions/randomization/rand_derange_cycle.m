function varargout = rand_derange_cycle(n,k,varargin)

% Make blocking constraint optional
% Default values
BlockSize = 1;

% Check for name-value pairs
if ~isempty(varargin)
    for i = 1:2:length(varargin)
        name = varargin{i};
        value = varargin{i + 1};
        if strcmpi(name,'blocksize')
            BlockSize = value;
        else
            error('Unknown option: %s', name);
        end
    end
end

% Define the maximum number of unique order vectors
b = BlockSize;
nrow_unique = n/b;

% give warning when unique row positions are not guarenteed
if k > n*nrow_unique
    warning('unique row positions cannot be guarenteed as k > %i',n*nrow_unique);
end

% Generate the initial Latin matrix
latin_matrix = zeros(nrow_unique, n);
latin_matrix(1,:) = 1:n;

for irow = 2:nrow_unique
    latin_matrix(irow, :) = circshift(latin_matrix(irow-1, :), b);
end

% Create a permutated cyclical sequence based on the latin matrix
perms_seq = zeros(1,k);
n_repeat = ceil(k/n);
perms_matrix = zeros(n_repeat - 1,n);
for i_repeat = 1:n_repeat
    if rem(i_repeat,nrow_unique) == 1 %randomize the latin matrix every time a new cycle begins
        if BlockSize
            n_block = n*nrow_unique/b;
            block_switch_indices = repelem(0:n_block - 1, b)*b + randperm_cycle_equal(b,n*nrow_unique);
            latin_matrix_transposed = latin_matrix';
            perms_vec_temp = latin_matrix_transposed(block_switch_indices);
            perms_matrix_temp = reshape(perms_vec_temp,n,nrow_unique)';
            col_shuffle_indices = repelem(randperm(nrow_unique) - 1,b)*b + repmat(1:b,[1 nrow_unique]);
            perms_matrix_temp = perms_matrix_temp(randperm(nrow_unique), col_shuffle_indices);
        else
            perms_matrix_temp = latin_matrix(randperm(nrow_unique), randperm(n));
        end
    end
    i_row = rem(i_repeat - 1,nrow_unique) + 1; % cycle through the permutated latin matrix
    k_remain = k - (i_repeat - 1) * n;
    if k_remain < n
        seq_indices = n * (i_repeat - 1) + (1:rem(k,n));
        perms_seq(seq_indices) = perms_matrix_temp(i_row,1:k_remain);
        if nargout == 2
            warning('The last %i numbers cannot be included in the matrix output.',k_remain);
        end
    else
        seq_indices = n * (i_repeat - 1) + (1:n);
        perms_seq(seq_indices) = perms_matrix_temp(i_row,:);
        perms_matrix(i_repeat,:) = perms_matrix_temp(i_row,:);
    end
end

switch nargout
    case {0,1}
        varargout{1} = perms_seq;
    case 2
        varargout{1} = perms_seq;
        varargout{2} = perms_matrix;
    otherwise
        error('Unsupported number of output arguments');
end

function rand_seq = randperm_cycle_equal(n,k)
    all_perms = perms(1:n);
    n_perms = size(all_perms,1);
    k_perms = floor(k/n);
    rem_seq = rem(k,n);

    base_perms = floor(k_perms/n_perms);
    rem_perms = rem(k_perms,n_perms);
    perms_idx_seq = [repelem(1:n_perms,base_perms),1:rem_perms];
    rand_perms_idx_seq = perms_idx_seq(randperm(k_perms));

    rand_seq = zeros(1,k);
    for i_perms = 1:k_perms
        seq_idx = (i_perms - 1)*n + (1:n);
        rand_seq(seq_idx) = all_perms(rand_perms_idx_seq(i_perms),:);
    end
    rand_seq(k_perms*n+1:k) = randperm(rem_seq);
end
end


