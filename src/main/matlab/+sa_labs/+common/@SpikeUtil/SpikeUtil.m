classdef SpikeUtil < handle
    
    properties
        binWidthPSTH
        smoothingWindowPSTH
        detectorMode
    end
    
    properties
        
    end
    
    methods
        
        function obj = SpikeUtil(mode, binWidth)
            
            if nargin < 2
                binWidth = 10;
            end
            obj.binWidthPSTH = binWidth;
            obj.smoothingWindowPSTH = 10;
            obj.detectorMode = mode;
        end
        
        function features = extractSpikes(obj, responses)
            
            spikeTimeId = sa_labs.common.SpikeFeatures.SPIKE_TIME;
            spikeAmpId = sa_labs.common.SpikeFeatures.SPIKE_AMP;
            
            switch obj.detectorMode
                case 'mht.spike_util'
                    [spikeTimes, spikeAmp] = mht.spike_util.detectSpikes(responses);
                    
            end
            import sa_labs.analysis.entity.*
            
            [n, ~] = size(spikeTimes);
            features = Feature.empty(0, 2 * n);
            index = 1;
            
            if n == 1
                spikeTimes = {spikeTimes};
                spikeAmp = {spikeAmp};
            end
            
            for i = 1 : n
                spikeTimeFeature = Feature.create(spikeTimeId.description);
                spikeTimeFeature.data = spikeTimes{i};
                features(index) = spikeTimeFeature;
                index = index + 1;
                
                spikeAmpFeature = Feature.create(spikeAmpId.description);
                spikeAmpFeature.data = spikeAmp{i};
                features(index) = spikeAmpFeature;
                index = index + 1;
            end
        end
    end
end

