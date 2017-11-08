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
            plotSpikes(spikeTimes, data, description, axes);
        else
            plotEpoch(data, description, axes);
        end
        xlabel(axes, '');
        title(axes, '');
    end
    xlabel(axes, 'Time (seconds)');
    title(axesArray(1), ['Epoch number (' num2str(description.epochNum) ')']);
end

end

function plotEpoch(response, description, axes)

sampleRate = description.sampleRate;
stimulusStart = description.preTime * 1e-3; % in seconds
stimulusLength = description.stimTime * 1e-3; % in seconds
device = description.device;
units = description.units;

x = (1 : length(response)) / sampleRate - stimulusStart;  

hold(axes, 'on');
plot(axes, x, response);

if ~ isempty(stimulusLength)
    startLine = line(axes,...
        'Xdata', [0 0],...
        'Ydata', get(axes, 'ylim'), ...
        'Color', 'k',...
        'LineStyle', '--');
    endLine = line(axes,...
        'Xdata', [stimulusLength stimulusLength],...
        'Ydata', get(axes, 'ylim'), ...
        'Color', 'k',...
        'LineStyle', '--');

    set(startLine, 'Parent', axes);
    set(endLine, 'Parent', axes);
end
hold(axes, 'off');

ylabel(axes, [device '(',units ')']);
xlabel(axes, 'Time (s)');
title(axes, ['Epoch number (' num2str(description.epochNum) ')']);
end