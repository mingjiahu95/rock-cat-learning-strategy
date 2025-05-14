function output_matrix = helper_func(value_matrix_cell,key_matrix)

global n_cat
if size(value_matrix_cell,1) ~= n_cat || size(key_matrix,1) ~= n_cat
    error('the input matrices must have %i rows!', n_cat);
end
output_matrix = cell(size(key_matrix'));
for icat = 1:n_cat
    row_indices = key_matrix(icat,:);
    output_matrix(:,icat) = value_matrix_cell(icat,row_indices);
end
end


