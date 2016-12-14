function [x, count] = getPSTH(psthDescription, spikeTimeFeatures)
    
    desc = psthDescription;
    smoothingWindowPSTH = str2double(desc.smoothingWindowPSTH);
    binWidthPSTH = str2double(desc.binWidthPSTH);
    
    parameters = spikeTimeFeatures(1).epochParameters;
    sampleRate = parameters.sampleRate;
    
    rate = round(sampleRate / 1E3);
    n = round(binWidthPSTH * rate);

    bins = 1 : n : parameters.responseLength;
    spikeTimes = [spikeTimeFeatures.data];
    count = histc(spikeTimes, bins);

    if isempty(count)
        count = zeros(1, length(bins));
    end

    if smoothingWindowPSTH
        smoothingWindow_pts = round(smoothingWindowPSTH / binWidthPSTH);
        w = gausswin(smoothingWindow_pts);
        w = w / sum(w);
        count = conv(count, w, 'same');
    end
    
    count = count / numel(spikeTimeFeatures) / (binWidthPSTH * 1E-3);
    x = bins/sampleRate - (parameters.preTime * 1E-3);

end