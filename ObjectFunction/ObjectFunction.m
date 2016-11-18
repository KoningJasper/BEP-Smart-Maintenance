function [ Output_Objective, plotLambda, plotObj, lambdaOverTime] = ObjectFunction(input, t_max, t_p, components, tasks, vesselLocation)

% Pre-Calc %
no_components = size(components, 1);
no_tasks      = size(tasks, 1);
no_time_steps = t_max/t_p;

% Pre-alloc %
plotObj        = ones(no_time_steps + 1);
plotLambda     = ones(no_time_steps + 1);
lambdaOverTime = ones(no_time_steps + 1, no_components);

% Pre-check %
interval = cell2mat(input) .* cell2mat(tasks(:, 6));
for i = 1:no_tasks
    no_executed_maintenance = floor(no_time_steps/interval(i));

    for j = 1:no_executed_maintenance
        tijdstip = floor(j*interval(i));
        if vesselLocation{tijdstip, 2} == 0  %0 is op zee, 1 is in de haven
            Output_Objective = 0;
            %disp(['Deze is stuk, pre-check, bij tijdstip: ', num2str(tijdstip), '.']);
            return
        end
    end
end

% Integrate over Time %
Output_Objective = 0;
m1               = zeros(no_components, 1);

for i = 2:no_time_steps + 1
    lambda_system = 1;
    
    for n = 1:no_components
        [beta, eta] = FindWeibullOfComponentById(components{n, 1}, components);
        
        component_id = components{n,1};
        relevant_maintenance_tasks = FindTasksByComponentId(component_id, tasks);
        
        m2 = 0;
        
        for m = 1:size(relevant_maintenance_tasks, 1)
            interval              = input{m,1};
            task_id               = relevant_maintenance_tasks{m, 1};
            task                  = LocateTaskById(task_id, relevant_maintenance_tasks);
            timeOfExecution       = floor(interval * task{1, 6});
            endTimeMaintenance    = timeOfExecution + task{1, 4};
            locationOfExecution   = task{1,3};
            affected_component_id = task{1, 7};
            
            % Check correct component
            if(component_id ~= affected_component_id)
                continue;
            end
            
            % Check if maintenance is ongoing
            if(timeOfExecution <= i && i <= endTimeMaintenance)
                % Check location
                location = vesselLocation{i, 2};
                
                if(location ~= locationOfExecution)
                    Output_Objective = 0;
                    %disp(['De pre-check is stuk bij tijdstip  ', num2str(i), 'h en interval ', num2str(interval), '.']);
                    return;
                end
                
                % Reduce availability with working time
                Output_Objective = Output_Objective - t_p;
                
                % Set m1 after maintenance
                if(i == endTimeMaintenance)
                    m1(n, 1) = task{1, 8};
                    m2       = m2 + task{1, 9};
                end
            else
                continue;
            end
        end
        
        % Recalculate reliability
        lambda_component = 1 - FailureRateN(t_p, beta, eta, m1(n, 1), 1 - lambdaOverTime(i - 1, n));
        
        % Add (m2) jump
        if(m2 + lambda_component >= 1)
            lambda_component = 1;
        else
            lambda_component = lambda_component + m2;
        end
        
        % Calculate system reliability
        lambda_system        = lambda_system * lambda_component; 
        lambdaOverTime(i, n) = lambda_component;
    end

    Output_Objective = Output_Objective + lambda_system * t_p;
    plotLambda(i)    = lambda_system;
    plotObj(i)       = Output_Objective;  
end

plotLambda = plotLambda(:, 1);
plotObj    = plotObj(:, 1);
