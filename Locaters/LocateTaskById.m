function [row] = LocateTaskById( task_id, tasks )
    task_ids = tasks(:, 1);
    [rn, ~] = find([task_ids{:}] == task_id);
    row = tasks(rn, :);
end

