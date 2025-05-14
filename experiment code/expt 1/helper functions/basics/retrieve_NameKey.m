function match_index = retrieve_NameKey(str_array,str_match,varargin)

% Default values
IsCaseSensitive = true;

% Check for name-value pairs
if ~isempty(varargin)
    for k = 1:2:length(varargin)
        name = varargin{k};
        value = varargin{k + 1};
        if strcmpi(name,'iscasesensitive')
            IsCaseSensitive = value;
        else
            error('Unknown option: %s', name);
        end
    end
end

% deal with uppercase letters
if ~IsCaseSensitive
    str_array = lower(str_array);
    str_match = lower(str_match);
end

logical_indices = false(size(str_array));
for i = 1:numel(str_array)
    if ~isempty(strfind(str_match,str_array{i}))
        logical_indices(i) = true;
    end
end
match_index = find(logical_indices);
end


        
    
