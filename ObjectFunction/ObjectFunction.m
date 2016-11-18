function [ Output_Objective, interval] = ObjectFunction(input, t_max, t_p, no_components, components, no_maintenance_tasks, tasks, vesselLocation)

% Pre-check %
interval = input .* tasks(:, 6);
for i = 1:no_tasks
    no_executed_maintenance = floor(no_time_steps/interval(i));

    for j = 1:no_executed_maintenance
        if ship_schedule(j*interval)== 0  %0 is op zee, 1 is in de haven
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
        for m = 1:no_maintenance_tasks
            interval = input{m, 2};
            task_id = tasks{m, 1};
            task = LocateTaskById(task_id, tasks);
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