function [ data ] = DataReader( filepath )
    %DATAREADER Reads excel data and strips header column
    [~, ~, raw] = xlsread(filepath);
    raw_size = size(raw);
    data = raw(2:raw_size(1,1), 1:raw_size(1,2));
    data = data(any(cellfun(@(x)any(~isnan(x)),data),2),:);
end

