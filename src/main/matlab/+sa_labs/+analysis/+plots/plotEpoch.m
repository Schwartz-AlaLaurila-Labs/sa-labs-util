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
