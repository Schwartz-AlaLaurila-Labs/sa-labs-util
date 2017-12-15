function duration = getUniqueDurationInSeconds(epochGroup)

	data = epochGroup.get('preTime') + epochGroup.get('stimTime') + epochGroup.get('tailTime');
	duration = unique(data) * 1e-3;
end