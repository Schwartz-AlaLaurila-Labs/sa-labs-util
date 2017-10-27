function d = getdeviceForEpoch(epoch, activeDevices)
devices = epoch.get('devices');
idx = ismember(devices, activeDevices);
d = devices(idx);
end

