function struct_shuffled = shuffleND_struct(struct_unshuffled)

    fieldNames = fieldnames(struct_unshuffled);
    numFields = numel(fieldNames);
    
    struct_shuffled = struct();
    array_dims = cell(1,numFields);
    for i = 1:numFields
        
        fieldName = fieldNames{i};
        array_unshuffled = struct_unshuffled.(fieldName);
        if i == 1
            index_shuffled = randperm(numel(array_unshuffled));
        end
        
        array_dims{i} = size(array_unshuffled);
        if i >= 2 && any(array_dims{i} ~= array_dims{i-1})
            error('the field %s does not have the same dimension!',fieldName);
        else
            vector_shuffled = array_unshuffled(index_shuffled);
            array_shuffled = reshape(vector_shuffled,array_dims{i});
            struct_shuffled.(fieldName) = array_shuffled;
        end
    end     
end