function [x, count] = getPSTH(obj, spikeTimeFeatures, parameters)
    
    sampleRate = parameters.sampleRate;
    rate = round(sampleRate / 1E3);
    n = round(obj.description.binWidthPSTH * rate);

    bins = 1 : n : parameters.responseLength;
    spikeTimes = [spikeTimeFeatures.data];
    count = histc(spikeTimes, bins);

    if isempty(count)
        count = zeros(1, length(bins));
    end

    if obj.smoothingWindowPSTH
        smoothingWindow_pts = round(obj.description.smoothingWindowPSTH / obj.binWidthPSTH);
        w = gausswin(smoothingWindow_pts);
        w = w / sum(w);
        count = conv(count, w, 'same');
    end
    
    count = count / numel(spikeTimeFeatures) / (obj.binWidthPSTH * 1E-3);
    x = bins/sampleRate - (parameters.preTime * 1E-3);

end