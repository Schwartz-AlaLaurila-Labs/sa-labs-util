%% Load test file

dir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'data');
data = load([dir '/signal-for-spike.dat']);


%% Detect spikes and create feature
import sa_labs.common.spike.features.*;
samplingRate = 1e4;

% paramter in seconds
baselineStart = 0.5;
stimTime = 1;
tailTime = 1;
endTime = stimTime + tailTime;

% detect the spikes
[spikeTimes, spikeAmplitudes] = mht.spike_util.detectSpikes(data);
n = size(spikeTimes, 1);

features = SpikeTimeFeature.empty(0, n);
for i = 1 : n
    spikeTimesReleativeToStim = spikeTimes{i}/samplingRate - baselineStart;
    
    % Figure(1) Time axis :
    %
    %       { baselineIntervalLen }                  {---    responseIntervalLength --}  {-- poststimIntervalLen --}
    %       |----------------------|-----------------|------------------|---------------|---------------------------|
    %     -0.5                  <desc>             0.0                <desc>
    % (baselineStart)       (baseLineEnd = 0) (intervalStart = 0) (endOffset = 0) (intervalEnd)                   (endTime)
    f = SpikeTimeFeature(spikeTimesReleativeToStim, -baselineStart, stimTime, samplingRate, endTime) %#ok
    features(i) = f;
end

% calculate mean baseline rate and set it to all features

features.setMeanBaseLineRate(mean([features.baseLineRate]));

%% plot psth response of the detected spike

% a) get psth using variable arguments
[x, y] = SpikeTimeFeature.getPSTH(features, 'smoothingWindowPSTH', 0.0001, 'binWidthPSTH', 0.01);

figure()
plot(x, y);
xlabel('Time (seconds)');
ylabel('Firing rate');
title('PSTH with smoothing window');


% b) using feature description instance for online analysis with GUI
% control

props = containers.Map();
props('id') = 'PSTH';
props('smoothingWindowPSTH') = 0.0001;
props('binWidthPSTH') =  0.01;
psthDesc = sa_labs.analysis.entity.FeatureDescription(props);

psthHandle = @() SpikeTimeFeature.getPSTH(features, 'description', psthDesc);
[x, y] = psthHandle();
plot(x, y);
xlabel('Time (seconds)');
ylabel('Firing rate');
title('PSTH with smoothing window');

% modifying psthdesc instance
psthDesc.smoothingWindowPSTH = 0;
% gui will reflect the non smoothed psth

figure()
[x, y] = psthHandle();
plot(x, y);
xlabel('Time (seconds)');
ylabel('Firing rate');
title('PSTH with smoothing window');

%% Benchmarking spike detection algorithm

disp('Time elapsed for detecting 6 spikes')
tic; mht.spike_util.detectSpikes(data); toc;

%% Visual verification
% mht.spike_util.detectSpikes(data, 'checkDetection', true);