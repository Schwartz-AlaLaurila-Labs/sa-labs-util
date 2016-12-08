dir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'data');
data = load([dir '/signal-for-spike.dat']);

mht.spike_util.detectSpikes(data, 'checkDetection', true)

% Todo benchmark mht spike detection algorithm
