function [ relevant_tasks ] = FindTasksByComponentId( component_id, tasks )
    %FINDTASKSBYCOMPONENTID This function find the relevant tasks by the
    %affected component id.
    %   It executes a search on the tasks by affected component id.
    task_ids = tasks(:, 7);
    [~, rowNumbers] = find([task_ids{:}] == component_id);
    
    relevant_tasks = cell(size(rowNumbers, 1), size(tasks, 2));
    
    for i = 1:length(rowNumbers)
        relevant_tasks(i, :) = tasks(rowNumbers(i), :);
    end
end

