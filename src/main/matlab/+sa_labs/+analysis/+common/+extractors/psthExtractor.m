function psthExtractor(~, epochGroup, paramter)

% description : Extracts Peri-Stimuls histogram from the epochGroup. Below are the list of parameters
% binWidthPSTH:
%   default : 0.01
%   description: bin width in seconds to estimate the PSTH
% smoothingWindowPSTH:
%   default: 0
%   description: Guassian smoothing window for smoothening the PSTH
% ---

    binWidthPSTH = paramter.binWidthPSTH;
    smoothingWindowPSTH = paramter.smoothingWindowPSTH;

	spikeTimes = epochGroup.getFeatureData('SPIKETIMES');
	duration = sa_labs.analysis.common.getUniqueDurationInSeconds(epochGroup);

	if numel(duration) > 1
	    error('cannot get psth for varying response duration. check preTime, stimTime and tailTime')
	end
	
	rate = epochGroup.getParameter('sampleRate');
	preTime = epochGroup.getParameter('preTime') * 1e-3; % in seconds
	n = round(binWidthPSTH * rate);
	durationSteps = duration * rate;
	
	bins = 1 : n : durationSteps;
	spikeTimeSteps = (cell2mat(spikeTimes) * 1e-3 + preTime) * rate;
	count = histc(spikeTimeSteps, bins);
	
	if smoothingWindowPSTH
	    smoothingWindowSteps = round(rate * (smoothingWindowPSTH / binWidthPSTH));
	    w = gausswin(smoothingWindowSteps);
	    w = w / sum(w);
	    count = conv(count, w, 'same');
	end

	count = count / numel(spikeTimes) / binWidthPSTH ;
	x = bins/rate - preTime;
    
    epochGroup.createFeature('PSTH', count, ...
        'xAxis', x, ...
        'xLabel', 'Time (s)', ...
        'yLabel', 'PSTH', ...
        'binWidthPSTH', binWidthPSTH, ...
        'smoothingWindowPSTH', smoothingWindowPSTH);
end