function  plotSpikesStatistics(epochData, devices, axes, varargin)
n = numel(devices);

sa_labs.analysis.util.clearAxes(axes);
axesArray = sa_labs.analysis.util.getNewAxesForSublot(axes, n);
 
for i = 1 : n
    device = devices{i};

    statistics = epochData.getDerivedResponse('spikeStatistics', device);
    peakAmplitudes = statistics.peakAmplitudes;
    
    rebound = statistics.rebound;
    clusterIndex = statistics.clusterIndex;
    spikeClusterIndex = statistics.spikeClusterIndex;
    nonspikeClusterIndex = statistics.nonspikeClusterIndex;
    
    ax = axesArray(i);
    subplot(n, 1, i, ax);
    
    plot3(ax, peakAmplitudes(clusterIndex == spikeClusterIndex),...
        rebound.Left(clusterIndex == spikeClusterIndex),...
        rebound.Right(clusterIndex == spikeClusterIndex), 'ro');
    hold(ax, 'on');
    plot3(ax, peakAmplitudes(clusterIndex == nonspikeClusterIndex),...
        rebound.Left(clusterIndex == nonspikeClusterIndex),...
        rebound.Right(clusterIndex == nonspikeClusterIndex), 'ko');
    hold(ax, 'off');
end
xlabel(ax, 'Peak Amplitude');
ylabel(ax, 'L rebound');
zlabel(ax, 'R rebound');
end