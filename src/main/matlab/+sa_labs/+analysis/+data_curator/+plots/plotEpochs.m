function plotEpochs(epochs, devices, axes, varargin)

import sa_labs.analysis.*;
util.clearAxes(axes);
axesArray = util.getNewAxesForSublot(axes, numel(devices));

for epochData = epochs
    n = numel(devices);
    for i = 1 : n
        device = devices{i};
        response = epochData.getResponse(device);
        units = deblank(response.units(:,1)');
        data = response.quantity';
        axes = axesArray(i);
        subplot(n, 1, i, axes);
        
        description = epochData.toStructure();
        description.device = device;
        description.units = units;
        spikeTimes = epochData.getDerivedResponse('spikeTimes', device);
        
        if ~ isempty(spikeTimes)
            plots.plotSpikes(spikeTimes, data, description, axes);
        else
            plots.plotEpoch(data, description, axes);
        end
        xlabel(axes, '');
        title(axes, '');
    end
    xlabel(axes, 'Time (seconds)');
    title(axesArray(1), ['Epoch number (' num2str(description.epochNum) ')']);
end
end
