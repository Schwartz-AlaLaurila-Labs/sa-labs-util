function [spikeTimes, spikeAmplitudes, refractoryViolations] = spikeDetector(dataMatrix,varargin)
% 
% SpikeDetector detects spikes in an extracellular / cell attached recording
%   [SpikeTimes, SpikeAmplitudes, RefractoryViolations] = SpikeDetector(dataMatrix,varargin)
%   
%   RETURNS
%       spikeTimes: In datapoints. Cell array. Or array if just one trial;
%       spikeAmplitudes: Cell array.
%       refractoryViolations: Indices of SpikeTimes that had refractory
%           violations. Cell array.
%   
%   REQUIRED INPUTS
%       dataMatrix: Each row is a trial
%   OPTIONAL ARGUMENTS
%       checkDetection: (false) (logical) Plots clustering information for
%           each trace
%       sampleRate: (1e4) (Hz)
%       refractoryPeriod: (1.5e-3) (sec)
%       searchWindow; (1.2e-3) (sec) To look for rebounds. Search interval
%           is (peak time +/- SearchWindow/2)
%
%   Clusters peak waveforms into 2 clusters using k-means. Based on three
%   quantities about each spike waveform: amplitude of the peak, amlitude
%   of a rebound on the right and left.
%   MHT 9.23.2016 - Ported over from personal version

ip = inputParser;
ip.addRequired('dataMatrix', @ismatrix);
addParameter(ip,'checkDetection', false, @islogical);
addParameter(ip,'sampleRate', 1e4, @isnumeric);
addParameter(ip,'refractoryPeriod', 1.5E-3, @isnumeric);
addParameter(ip,'searchWindow', 1.2E-3, @isnumeric);

ip.parse(dataMatrix, varargin{:});

dataMatrix = ip.Results.dataMatrix;
checkDetection = ip.Results.checkDetection;
sampleRate = ip.Results.sampleRate;
refractoryPeriod = ip.Results.refractoryPeriod * sampleRate; % datapoints
searchWindow = ip.Results.searchWindow * sampleRate; % datapoints

cutoffFrequency = 500; %Hz

dataMatrix = mht.signal_processing.highPassFilter(dataMatrix, cutoffFrequency, 1/sampleRate);

nTraces = size(dataMatrix, 1);
spikeTimes = cell(nTraces, 1);
spikeAmplitudes = cell(nTraces, 1);
refractoryViolations = cell(nTraces, 1);

if (checkDetection)
    figure;
    figHandle = gcf;
end

for tt = 1 : nTraces
    currentTrace = dataMatrix(tt, :);
    if abs(max(currentTrace)) > abs(min(currentTrace)) % flip it over, big peaks down
        currentTrace = -currentTrace;
    end
    
    % get peaks
    [peakAmplitudes, peakTimes] = mht.signal_processing.getPeaks(currentTrace, -1); % -1 for negative peaks
    peakTimes = peakTimes(peakAmplitudes < 0); % only negative deflections
    peakAmplitudes = abs(peakAmplitudes(peakAmplitudes < 0)); % only negative deflections
    
    % get rebounds on either side of each peak
    rebound = mht.spike_util.getRebounds(peakTimes, currentTrace, searchWindow);
    
    % cluster spikes
    clusteringData = [peakAmplitudes', rebound.Left', rebound.Right'];
    startMatrix = [median(peakAmplitudes) median(rebound.Left) median(rebound.Right);...
        max(peakAmplitudes) max(rebound.Left) max(rebound.Right)];
    clusteringOptions = statset('MaxIter', 10000);
    
    try %traces with no spikes sometimes throw an "empty cluster" error in kmeans
        [clusterIndex, centroidAmplitudes] = kmeans(clusteringData, 2,...
            'start',startMatrix,'Options',clusteringOptions);
    catch err
        if strcmp(err.identifier,'stats:kmeans:EmptyCluster')
            %initialize clusters using random sampling instead
            [clusterIndex, centroidAmplitudes] = kmeans(clusteringData, 2,...
                'start', 'sample', 'Options', clusteringOptions);
        end
    end
    
    [~, spikeClusterIndex] = max(centroidAmplitudes(:, 1)); %find cluster with largest peak amplitude
    nonspikeClusterIndex = setdiff([1 2], spikeClusterIndex); %nonspike cluster index
    spikeIndex_logical = (clusterIndex == spikeClusterIndex); %spike_ind_log is logical, length of peaks
    
    % get spike times and amplitudes
    spikeTimes{tt} = peakTimes(spikeIndex_logical);
    spikeAmplitudes{tt} = peakAmplitudes(spikeIndex_logical);
    nonspikeAmplitudes = peakAmplitudes(~spikeIndex_logical);
    
    %check for no spikes trace
    %how many st-devs greater is spike peak than noise peak?
    sigF = (mean(spikeAmplitudes{tt}) - mean(nonspikeAmplitudes)) / std(nonspikeAmplitudes);
    
    if sigF < 5; %no spikes
        spikeTimes{tt} = [];
        spikeAmplitudes{tt} = [];
        refractoryViolations{tt} = [];
        disp(['Trial '  num2str(tt) ': no spikes!']);
        if (checkDetection)
            plotClusteringData();
        end
        continue
    end
    
    % check for refractory violations
    refractoryViolations{tt} = find(diff(spikeTimes{tt}) < refractoryPeriod) + 1;
    ref_violations = length(refractoryViolations{tt});
    if ref_violations > 0
        disp(['Trial '  num2str(tt) ': ' num2str(ref_violations) ' refractory violations']);
    end
    
    if (checkDetection)
        plotClusteringData()
    end
end

if length(spikeTimes) == 1 %return vector not cell array if only 1 trial
    spikeTimes = spikeTimes{1};
    spikeAmplitudes = spikeAmplitudes{1};
    refractoryViolations = refractoryViolations{1};
end

    function plotClusteringData()
        figure(figHandle)
        subplot(1,2,1); hold on;
        plot3(peakAmplitudes(clusterIndex==spikeClusterIndex),...
            rebound.Left(clusterIndex==spikeClusterIndex),...
            rebound.Right(clusterIndex==spikeClusterIndex),'ro')
        plot3(peakAmplitudes(clusterIndex==nonspikeClusterIndex),...
            rebound.Left(clusterIndex==nonspikeClusterIndex),...
            rebound.Right(clusterIndex==nonspikeClusterIndex),'ko')
        xlabel('Peak Amplitude'); ylabel('L rebound'); zlabel('R rebound')
        view([8 36])
        subplot(1,2,2)
        plot(currentTrace,'k'); hold on;
        plot(spikeTimes{tt}, ...
            currentTrace(spikeTimes{tt}),'rx')
        plot(spikeTimes{tt}(refractoryViolations{tt}), ...
            currentTrace(spikeTimes{tt}(refractoryViolations{tt})),'go')
        title(['SpikeFactor = ', num2str(sigF)])
        drawnow;
        pause(); clf;
    end

end
