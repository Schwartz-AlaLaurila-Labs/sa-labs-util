function plotEpochs(epochs, devices, axes, varargin)

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
    ylabel(axes, [device '(',units ')']);
end
hold(axes, 'off');
xlabel(axes, 'Time (s)');

end

function clearAxes(axes)
pannel = get(axes, 'Parent');
childAxes = get(pannel, 'Children');

for i = 1 : numel(childAxes)
    if ~ isequal(childAxes(i), axes)
        delete(childAxes(i));
    end
end
cla(axes, 'reset');
end

function axesArray = getNewAxesForSublot(axes, n)
axesArray = axes;
for i = 2 : n
    ax = copyobj(axes, get(axes, 'Parent'));
    axesArray = [axesArray, ax]; %#ok
end
end