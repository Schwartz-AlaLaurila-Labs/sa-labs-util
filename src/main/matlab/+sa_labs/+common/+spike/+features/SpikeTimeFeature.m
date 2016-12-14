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
        baselineStart
        endTime
        meanBaseLineRate
    end
    
    properties (Dependent)
        
        intervalEnd
        baseLineEnd
        
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
        
        postStimulsSpikeTimes
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
        
        function obj = SpikeTimeFeature(description, data, parameters)
            obj = obj@sa_labs.analysis.entity.Feature(description, data);
            
            obj.epochParameters = parameters;
            obj.intervalStart = 0;
            obj.baselineStart = obj.epochParameters.preTime * 1e-3;
            obj.endTime =  (obj.epochParameters.stimTime + obj.epochParameters.tailTime) * 1e-3;
        end
        
        function data = get.intervalEnd(obj)
            data = (obj.epochParameters.stimTime + obj.description.endOffset) * 1e-3;
        end
        
        function data = get.responseIntervalLen(obj)
            data = obj.intervalEnd - obj.intervalStart;
        end
        
        function data = get.baseLineEnd(obj)
            data = obj.description.baseLineEnd * 1e-3;
        end
        
        function data = get.baselineIntervalLen(obj)
            data = obj.baseLineEnd - obj.baselineStart;
        end
        
        function data = get.poststimIntervalLen(obj)
            data = obj.endTime - obj.intervalEnd;
        end
        
        function data = get.spikeTimes(obj)
            data = obj.data;
        end
        
        function data = get.isi(obj)
            data = cumsum(diff(obj.spikeTimes));
        end
        
        function data = get.baselineSpikeTimes(obj)
            data = obj.spikeTimes(obj.spikeTimes < obj.baseLineEnd);
        end
        
        function data = get.baseLineSpikeCount(obj)
            data = length(obj.baselineSpikeTimes);
        end
        
        function data = get.baselineIsi(obj)
            data = diff(obj.baselineSpikeTimes);
        end
        
        function data = get.baselineIsi2(obj)
            data = obj.baselineIsi(1 : end - 1) + obj.baselineIsi(2 : end);
        end
        
        function data = get.baseLineRate(obj)
            data = length(obj.baselineSpikeTimes) / obj.baselineIntervalLen;
        end
        
        function data = get.postStimulsSpikeTimes(obj)
            data = obj.spikeTimes(obj.spikeTimes > obj.intervalEnd);
        end
        
        function data = get.postStimulsSpikeCount(obj)
            data = length(find(obj.spikeTimes >= obj.intervalEnd));
        end
        
        function data = get.postStimulsSpikeCountBaseLineSubstracted(obj)
            data = obj.postStimulsSpikeCount - obj.baseLineSpikeCount;
        end
        
        function data = get.postStimulsRate(obj)
            data = length(obj.postStimulsSpikeTimes) / obj.poststimIntervalLen;
        end
        
        function data = get.onSetSpikeCount400ms(obj)
            if obj.responseIntervalLen >= 0.4
                data = length(find(obj.spikeTimes >= obj.intervalStart & obj.spikeTimes < obj.intervalStart + 0.4));
            end
        end
        
        function data = get.OffSetSpikeCount400ms(obj)
            if obj.intervalEnd + 0.4 <= obj.endTime
                data = length(find(obj.spikeTimes >= obj.intervalEnd & obj.spikeTimes < obj.intervalEnd + 0.4));
            end
        end
        
        function data = get.meanBaseLineRate(obj)
            
            if isempty(obj.meanBaseLineRate)
                data = obj.baseLineRate;
                return
            end
            data = obj.meanBaseLineRate;
        end
        
        % below method requires meanBaseLineRate
        
        function data = get.baseLineSubstractedSpikeCount(obj)
            data = obj.spikeCount - obj.meanBaselineRate / obj.responseIntervalLen;
        end
        
        function data = get.baseLineSubstractedSpikeRate(obj)
            data = obj.baseLineSubstractedSpikeCount / obj.responseIntervalLen;
        end
        
        function data = get.baseLineSubstractedOnSetSpikeCount400ms(obj)
            data = obj.onSetSpikeCount400ms - obj.meanBaselineRate / 0.4;
        end
        
        function data = get.baseLineSubstractedOffSetSpikeCount400ms(obj)
            data = obj.OffSetSpikeCount400ms - obj.meanBaselineRate / 0.4;
        end
        
    end
end