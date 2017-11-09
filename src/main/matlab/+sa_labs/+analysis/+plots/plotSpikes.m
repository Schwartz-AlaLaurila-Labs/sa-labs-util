function plotSpikes(spikeTimes, response, description, axes)

sa_labs.analysis.plots.plotEpoch(response, description, axes);
hold(axes, 'on');
x = getStimulsDuration(numel(response), description);
plot(axes, x(spikeTimes), response(spikeTimes), 'rx');
hold(axes, 'off');

end

function x = getStimulsDuration(responseLength, description)

sampleRate = description.sampleRate;
stimulusStart = description.preTime * 1e-3; % in seconds
x = (1 : responseLength) / sampleRate - stimulusStart;

end
