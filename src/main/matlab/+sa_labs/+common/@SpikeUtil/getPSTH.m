function count = getPSTH(obj, spikeTimeFeatures)

    spikeTimes = [spikeTimeFeatures.data];

    bins = 1 : obj.getSampleSizePerBin : numel(response);
    count = histc(spikeTimes, bins);

    if isempty(count)
        count = zeros(1, length(bins));
    end

    if obj.smoothingWindowPSTH
        smoothingWindow_pts = round(obj.smoothingWindowPSTH / obj.binWidth);
        w = gausswin(smoothingWindow_pts);
        w = w / sum(w);
        count = conv(count, w, 'same');
    end
    count = count / spikeTimeFeatures.length / (obj.binWidth * 1E-3);
end