function [ random_input ] = GenerateRandomInput(min_value, Tasks )
    %GENERATERANDOMINPUT This function generates a random interval for each of the tasks, to use in the MC simulation
    
    number_of_tasks = size(Tasks, 1);
    random_input = cell(number_of_tasks,1);
    
    
    for i = 1:number_of_tasks
        random_input{i} = min_value + (1 - min_value) * rand();
    end
    
    
end

