function text = getText(file)
    % Read some text file:
    fd = fopen(file, 'rt');
    if fd==-1
        error('Could not open file!');
    end

    text = {};
    tline = 0;
    while ~feof(fd)
        tline = tline + 1;
        tl = fgetl(fd);
        text{tline} = tl; 
    end
    fclose(fd);
end