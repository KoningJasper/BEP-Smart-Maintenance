function [row] = LocateComponentById( component_id, components )
    component_ids = components(:, 1);
    [rn, ~] = find([component_ids{:}] == component_id);
    row = components(rn, :);
end


