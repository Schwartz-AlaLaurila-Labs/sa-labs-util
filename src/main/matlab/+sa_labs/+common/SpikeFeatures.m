classdef SpikeFeatures < sa_labs.analysis.core.FeatureIdentifier
    
    enumeration
        SPIKE_AMP(?sa_labs.analysis.entity.Feature, 'pA')
        SPIKE_TIME(?sa_labs.analysis.entity.Feature, 'sec')
    end
end

