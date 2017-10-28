function clearAxes(axes)

    pannel = get(axes, 'Parent');
    childAxes = get(pannel, 'Children');

    for i = 1 : numel(childAxes)
        if ~ isequal(childAxes(i), axes)
            delete(childAxes(i));
        end
    end
    fontName = get(axes, 'FontName');
    fontSize = get(axes, 'FontSize');
    cla(axes, 'reset');
    set(axes, 'FontName', fontName);
    set(axes, 'FontSize', fontSize);

end