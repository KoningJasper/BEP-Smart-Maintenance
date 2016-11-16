function [ random_input ] = GenerateRandomInput( tasks )
    %GENERATERANDOMINPUT This function generates a random interval for each
    %of the tasks.
    
    number_of_tasks = size(tasks, 1);
    random_input = cell(number_of_tasks,1);
    for i = 1:number_of_tasks
        random_input{i} = rand();
    end
end

