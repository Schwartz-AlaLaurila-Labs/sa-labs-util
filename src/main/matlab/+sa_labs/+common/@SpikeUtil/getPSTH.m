function count = getPSTH(obj, spikeTimeFeatures, epochParameters)

    spikeTimes = [spikeTimeFeatures.data];
    
    rate = round(epochParameters('sampleRate') / 1E3);
    n = round(obj.binWidthPSTH * rate);

    bins = 1 : n : epochParameters('responseLength');
    count = histc(spikeTimes, bins);

    if isempty(count)
        count = zeros(1, length(bins));
    end

    if obj.smoothingWindowPSTH
        smoothingWindow_pts = round(obj.smoothingWindowPSTH / obj.binWidthPSTH);
        w = gausswin(smoothingWindow_pts);
        w = w / sum(w);
        count = conv(count, w, 'same');
    end
    count = count / numel(spikeTimeFeatures) / (obj.binWidthPSTH * 1E-3);
end