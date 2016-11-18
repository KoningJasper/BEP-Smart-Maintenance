function [ Output_Objective, interval] = ObjectFunction(input, t_max, t_p, components, tasks, vesselLocation)

% Pre-Calc %
no_components = size(components, 1);
no_tasks      = size(tasks, 1);
no_time_steps = t_max;

% Pre-check %
interval = input{:} .* tasks{:, 6};
for i = 1:no_tasks
    no_executed_maintenance = floor(no_time_steps/interval(i));

    for j = 1:no_executed_maintenance
        if vesselLocation{floor(j*interval(i)), 2} == 0  %0 is op zee, 1 is in de haven
            Output_Objective = 0;
            return
        end
    end
end

% Integrate over Time %
lambdaOverTime = ones(t_max + 1, no_components);
Output_Objective = 0;
plotObj = ones(t_max + 1);
plotLambda = ones(t_max + 1);

for i = 2:t_max + 1
    lambda_system = 1;
    
    for n = 1:no_components
        m1 = 0;
        [beta, eta] = FindWeibullOfComponentById(components{n, 1}, components);
        
        component_id = components{n,1};
        relevant_maintenance_tasks = FindTasksByComponentId(component_id, tasks);
        
        for m = 1:size(relevant_maintenance_tasks, 1)
            interval = input{m,1};
            task_id = relevant_maintenance_tasks{m, 1};
            task = LocateTaskById(task_id, relevant_maintenance_tasks);
            timeOfExecution = floor(interval * task{1, 6});
            locationOfExecution = task{1,3};
            
            affected_component_id = task{1, 7};
            
            % Check correct component
            if(component_id ~= affected_component_id)
                continue;
            end
            
            % check execution
            if(timeOfExecution == i)
                % Check location
                location = vesselLocation{i, 2};
                
                if(location ~= locationOfExecution)
                    Output_Objective = 0;
                    return;
                end
                
                m1 = task{1, 8};
            else
                continue;
            end
        end
        
        lambda_component = 1 - FailureRateN(t_p, beta, eta, m1, 1 - lambdaOverTime(i - 1, n));
        lambda_system = lambda_system * lambda_component; 
        lambdaOverTime(i, n) = lambda_component;
    end
    
    plotLambda(i) = lambda_system;
    Output_Objective = Output_Objective + lambda_system * t_p;
    plotObj(i) = Output_Objective;
    
end

figure;
plot(plotLambda(:, 1));

figure;
plot(plotObj(:, 1));