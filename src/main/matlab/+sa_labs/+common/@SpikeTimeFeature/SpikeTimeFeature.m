classdef SpikeTimeFeature < sa_labs.analysis.entity.Feature
    
    
    % Time axis :
    %
    %       { baselineIntervalLen }                  {---    responseIntervalLength --}  {-- poststimIntervalLen --}
    %       |----------------------|-----------------|------------------|---------------|---------------------------|
    %      0.5                  <desc>             0.0                <desc>
    % (baselineStart)       (baseLineEnd = 0) (intervalStart = 0) (endOffset = 0) (intervalEnd)                   (end)
    
    properties
        epochParameters
        intervalStart
        meanBaseLineRate
    end
    
    properties (Dependent)
        
        intervalEnd
        baselineStart
        responseIntervalLen
        baselineIntervalLen
        poststimIntervalLen

        spikeTimes
        isi

        baselineSpikeTimes
        baseLineSpikeCount
        baselineIsi
        baselineIsi2
        baseLineRate

        postStimulsspikeTimes
        postStimulsSpikeCount
        postStimulsSpikeCountBaseLineSubstracted
        postStimulsRate

        onSetSpikeCount400ms
        OffSetSpikeCount400ms

        % below property requires meanBaseLineRate
        baseLineSubstractedSpikeCount
        baseLineSubstractedSpikeRate
        baseLineSubstractedOnSetSpikeCount400ms
        baseLineSubstractedOffSetSpikeCount400ms
    end
    
    methods
        
        function obj = SpikeFeature(description, data, parameters)
            obj@sa_labs.analysis.entity.Feature(description, data);
            
            obj.epochParameters = parameters;
            obj.intervalStart = 0;
        end
        
    end
end