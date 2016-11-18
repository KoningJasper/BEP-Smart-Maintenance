function [ relevant_tasks ] = FindTasksByComponentId( component_id, tasks )
    %FINDTASKSBYCOMPONENTID This function find the relevant tasks by the
    %affected component id.
    %   It executes a search on the tasks by affected component id.
    task_ids = tasks(:, 1);
    [rn, ~] = find([task_ids{:}] == component_id);
    
    relevant_tasks = cell(rn, size(tasks, 2));
    
    for i = 1:length(rn)
        relevant_tasks(i, :) = tasks(rn(i), :);
    end

end

