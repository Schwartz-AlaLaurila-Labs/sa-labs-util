function formatParameter(cellData, parameters)
% description : Standardize cell data and epoch parameters for analysis. For Example, if the file is from symphony_v1, then format parameter as per new analysis.
% ---
for epoch = cellData.epochs
    number = epoch.get('epochNumber');
    if ~ isempty(number)
        remove(epoch.attributes, epochNumber);
        epoch.attributes('h5EpochNumber') = number;
    end
end
end

