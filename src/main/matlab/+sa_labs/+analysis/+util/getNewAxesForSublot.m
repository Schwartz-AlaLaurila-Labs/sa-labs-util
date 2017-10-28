function axesArray = getNewAxesForSublot(axes, n)
axesArray = axes;
for i = 2 : n
    ax = copyobj(axes, get(axes, 'Parent'));
    axesArray = [axesArray, ax]; %#ok
end
end