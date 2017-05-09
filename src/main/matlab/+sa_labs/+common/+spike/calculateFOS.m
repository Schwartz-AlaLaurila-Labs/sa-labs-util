function fractionCorrect = calculateFOS(preSpikeCount, postSpikeCount, indices)

% Description - calculate the frequency of seeing 
%
% input parameter  
%   preSpikeCount   - 2 dimensional array of spike count before the start of stimulus
%   postSpikeCount  - 2 dimensional array of spike count after the start of stimulus
%   indices         - list of indices to be looked up for calculating fraction of choice
%
% returns 
%   fractionCorrect: mean choices made for the given list of indices
%
% Author - Sanna Koskela, Ala-Laurila Lab
% Reference - Murphy & Rieke 2011 

    % Calculate the mean of post-time spikecount and baseline-correct it with the mean of
    % pre-time. This is the discriminant (template).

    sumPreTime = sum(preSpikeCount);
    sumPostTime = sum(postSpikeCount);
    n = size(preSpikeCount, 1);
    discriminant = @(i)(sumPostTime - sumPreTime + preSpikeCount(i, :) - postSpikeCount(i, :))./n;

    % Calculate correlation of the current epoch with the discriminant.
    % Subtract the preFR (meanPreSpikeCount) from the pre- and postSpikeCounts
    % before correlation.

    choices = zeros(1, numel(indices));
    preCorr_temporary = choices;
    postCorr_temporary = choices;
    for j = 1 : numel(indices)
        i = indices(j);
        meanPreSpikeCount = mean(preSpikeCount(i, :));
        preCorrelation = (preSpikeCount(i, :) - meanPreSpikeCount) * discriminant(i)';
        postCorrelation = (postSpikeCount(i, :) - meanPreSpikeCount) * discriminant(i)';      
        preCorr_temporary(j) = preCorrelation;
        postCorr_temporary(j) = postCorrelation;
        
        if preCorrelation < postCorrelation
            choices(j) = 1;
        elseif preCorrelation == postCorrelation
            choices(j) = 0.5;
        end
    end
    fractionCorrect = mean(choices);
end