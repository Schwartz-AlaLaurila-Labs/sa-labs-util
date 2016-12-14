%% Load test file

dir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'data');
data = load([dir '/signal-for-spike.dat']);


%% Detect spikes and create feature

features = sa_labs.common.spike.features.SpikeTimeFeature.empty(0, 6);
props = containers.Map();
props('id') = 'SPIKE';
props('properties') = 'endOffset = 0, baseLineEnd = 0';
para = struct('preTime', 500, 'stimTime', 1000, 'tailTime', 1000, 'responseLength', 25000, 'sampleRate', 10000);

[spikeTimes, spikeAmplitudes] = mht.spike_util.detectSpikes(data);
description = sa_labs.analysis.entity.FeatureDescription(props);

for i = 1 : length(spikeTimes)
    f = sa_labs.common.spike.features.SpikeTimeFeature(description, spikeTimes{i}, para) %#ok
    features(i) = f;
end

%% plot psth response of the detected spike

props = containers.Map();
props('id') = 'PSTH';
props('properties') = 'smoothingWindowPSTH = 200, binWidthPSTH = 10';
psthDesc = sa_labs.analysis.entity.FeatureDescription(props);

[x, y] = sa_labs.common.spike.getPSTH(psthDesc, features);
plot(x,y);

%% Benchmarking spike detection algorithm

tic; mht.spike_util.detectSpikes(data); toc;

%% Visual verification
% mht.spike_util.detectSpikes(data, 'checkDetection', true);