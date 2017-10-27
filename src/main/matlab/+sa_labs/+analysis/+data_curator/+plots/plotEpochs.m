function  plotEpochs(epochData, devices, axes, varargin)
response = epochData.getResponse('Amp1');
x = (1 : numel(response))./10000;
plot(axes, x, response);
end

