classdef SpikeTimeFeature < handle
    
    
    % Figure(1) Time axis :
    %
    %       { baselineIntervalLen }                  {---    responseIntervalLength --}  {-- poststimIntervalLen --}
    %       |----------------------|-----------------|------------------|---------------|---------------------------|
    %     -0.5                  <desc>             0.0                <desc>
    % (baselineStart)       (baseLineEnd = 0) (intervalStart = 0) (endOffset = 0) (intervalEnd)                   (endTime)
    
    
    properties (SetAccess = private)
        
        % input from constructor parameters
        spikeTimes
        baselineStartTime
        stimTime
        endTime
        samplingRate
        description  % property that controls baseLineEnd, endOffset
    end
    
    properties
        intervalStart
        meanBaseLineRate
    end
    
    properties (Dependent)
        baseLineEnd
        intervalEnd
        duration
        
        spikeCount
        responseIntervalLen
        baselineIntervalLen
        poststimIntervalLen
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
        
        function obj = SpikeTimeFeature(spikeTimes, baselineStartTime, stimTime, samplingRate, endTime, description)
            
            if nargin < 6
                description = struct();
                description.id = 'SPIKE_TIME_FEATURE';
                description.baseLineEnd = 0;
                description.endOffset = 0;
                obj.description = description;
            end
            
            obj.intervalStart = 0;
            obj.baselineStartTime = baselineStartTime;
            obj.stimTime = stimTime;
            obj.endTime = endTime;
            obj.spikeTimes = spikeTimes;
            obj.description = description;
            obj.samplingRate = samplingRate;
        end
        
        function data = get.intervalEnd(obj)
            data = obj.stimTime +  obj.description.endOffset;
        end
        
        function data = get.duration(obj)
            data = (obj.endTime - obj.baselineStartTime);
        end
        
        function data = get.responseIntervalLen(obj)
            data = obj.intervalEnd - obj.intervalStart;
        end
        
        function data = get.baseLineEnd(obj)
            data = obj.description.baseLineEnd;
        end
        
        function data = get.baselineIntervalLen(obj)
            data = obj.baseLineEnd - obj.baselineStartTime;
        end
        
        function data = get.poststimIntervalLen(obj)
            data = obj.endTime - obj.intervalEnd;
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
        
        function data = get.spikeCount(obj)
            data = length(obj.spikeTimes);
        end
        
        function objs = setMeanBaseLineRate(objs, value)
            for i = 1 : numel(objs)
                objs(i).meanBaseLineRate = value;
            end
        end
        
        function data = get.meanBaseLineRate(obj)
            
            if isempty(obj.meanBaseLineRate)
                disp('[INFO] mean baseline rate is empty; using just base line rate as mean rate')
                data = obj.baseLineRate;
                return
            end
            data = obj.meanBaseLineRate;
        end
        
        % below method requires meanBaseLineRate
        
        function data = get.baseLineSubstractedSpikeCount(obj)
            data = obj.spikeCount - obj.meanBaseLineRate / obj.responseIntervalLen;
        end
        
        function data = get.baseLineSubstractedSpikeRate(obj)
            data = obj.baseLineSubstractedSpikeCount / obj.responseIntervalLen;
        end
        
        function data = get.baseLineSubstractedOnSetSpikeCount400ms(obj)
            data = obj.onSetSpikeCount400ms - obj.meanBaseLineRate / 0.4;
        end
        
        function data = get.baseLineSubstractedOffSetSpikeCount400ms(obj)
            data = obj.OffSetSpikeCount400ms - obj.meanBaseLineRate / 0.4;
        end
    end
    
    methods (Static)
        
        function psthDescription = parsePSTHInputParameters(varargin)
            ip = inputParser();
            ip.PartialMatching = true;
            ip.KeepUnmatched = true;
            
            if ismember({'description'}, {varargin{1 : 2 : end -1}})
                ip.parse(varargin{:});
                psthDescription = ip.Unmatched.description;
            else
                ip.addParameter('id', 'PSTH_FEATURE', @ischar);
                ip.addParameter('smoothingWindowPSTH', 0, @isnumeric);
                ip.addParameter('binWidthPSTH', 0.01, @isnumeric);
                ip.parse(varargin{:});
                psthDescription = ip.Results;
            end
        end
        
        
        function [x, count] = getPSTH(spikeTimeFeatures, varargin)
            
            import sa_labs.common.spike.features.*;
            desc = SpikeTimeFeature.parsePSTHInputParameters(varargin{:});
            
            smoothingWindowPSTH = desc.smoothingWindowPSTH;
            binWidthPSTH = desc.binWidthPSTH;
            
            duration = unique([spikeTimeFeatures.duration]);
            
            if numel(duration) > 1
                error('cannot get psth for varying response duration')
            end
            
            rate = spikeTimeFeatures(1).samplingRate;
            preTime = - spikeTimeFeatures(1).baselineStartTime;
            
            n = round(binWidthPSTH * rate);
            durationSteps = duration * rate;
            
            bins = 1 : n : durationSteps;
            spikeTimeSteps = ([spikeTimeFeatures.spikeTimes] + preTime) * rate;
            count = histc(spikeTimeSteps, bins);
            
            if isempty(count)
                count = zeros(1, length(bins));
            end
            
            if smoothingWindowPSTH
                smoothingWindowSteps = round(rate * (smoothingWindowPSTH / binWidthPSTH));
                w = gausswin(smoothingWindowSteps);
                w = w / sum(w);
                count = conv(count, w, 'same');
            end
            
            count = count / numel(spikeTimeFeatures) / binWidthPSTH ;
            x = bins/rate - preTime;
        end
    end
end