function plotEpochs(epochs, devices, axes, varargin)

import sa_labs.analysis.util.*;
clearAxes(axes);
axesArray = getNewAxesForSublot(axes, numel(devices));

for epochData = epochs
    plotEpoch(epochData, devices, axesArray)
end
end

function plotEpoch(epochData, devices, axesArray)

sampleRate = epochData.get('sampleRate');
stimulusStart = epochData.get('preTime') * 1e-3; % in seconds
stimulusLength = epochData.get('stimTime') * 1e-3; % in seconds
n = numel(devices);

for i = 1 : n
    
    device = devices{i};
    response = epochData.getResponse(device);
    units = deblank(response.units(:,1)');
    data = response.quantity';
    x = (1 : length(data)) / sampleRate - stimulusStart;
    
    axes = axesArray(i);
    subplot(n, 1, i, axes);
    hold(axes, 'on');
    plot(axes, x, data);
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
    plotSpikes(epochData, device, x, data, axes)
    ylabel(axes, [device '(',units ')']);
    hold(axes, 'off');
end
xlabel(axes, 'Time (s)');
title(axesArray(1), ['Epoch number (' num2str(epochData.get('epochNum')) ')']);
end

function plotSpikes(epochData, device, x, data, axes)
spikeTimes = epochData.getDerivedResponse('spikeTimes', device);
if ~ isempty(spikeTimes)
    plot(axes, x(spikeTimes), data(spikeTimes), 'rx');
end
end
