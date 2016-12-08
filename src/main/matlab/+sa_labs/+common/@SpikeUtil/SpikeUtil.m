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
        
        function features = extractSpikes(obj, response)
            
            spikeTimeId = sa_labs.common.SpikeFeatures.SPIKE_TIME;
            spikeAmpId = sa_labs.common.SpikeFeatures.SPIKE_AMP;
            
            switch obj.detectorMode
                case 'mht.spike_util'
                    [spikeTimes, spikeAmp] = mht.spike_util.detectSpikes(response);
                    
            end
            
            features = sa_labs.analysis.entity.Feature.empty(0, 2);
            spikeTimeFeature = sa_labs.analysis.entity.Feature.create(spikeTimeId.description);
            spikeTimeFeature.data = spikeTimes;
            features(1) = spikeTimeFeature;
            
            spikeAmpFeature = sa_labs.analysis.entity.Feature.create(spikeAmpId.description);
            spikeAmpFeature.data = spikeAmp;
            features(2) = spikeAmpFeature;
        end
        
    end
    
    methods(Access = private)
        
        function n = getSampleSizePerBin(obj, sampleRate)
            rate = round(sampleRate / 1E3);
            n = round(obj.binWidth * rate);
        end
        
    end
    
end

