dir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'data');
data = load([dir '/signal-for-spike.dat']);

tic
util = sa_labs.common.SpikeUtil('mht.spike_util');
features = util.extractSpikes(data(1, :));
toc;

util.smoothingWindowPSTH = 100;

plot(util.getPSTH(features(ismember({features.name}, 'SPIKE_TIME')),...
    containers.Map({'sampleRate', 'responseLength'}, {10000, 15000})))

% Benchmarking spike detection algorithm
tic; mht.spike_util.detectSpikes(data); toc;
mht.spike_util.detectSpikes(data, 'checkDetection', true);