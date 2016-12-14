function GatherOutput(Failure_Rate_Per_Task, Failure_Rate_Graphs_No_Maintenance, input, t_max, t_p, components, tasks, vesselLocation, forwardBias, maximumBias, costPerManhour, penaltyCost, timeFactorAtSea)
    %GATHEROUTPUT Summary of this function goes here
    %   Detailed explanation goes here

    % PARAMS
    % bool forwardBias = true geeft wanneer de oplossing niet kan wordt er
    % eerst gezocht naar oplossing die verder weg zijn niet dichterbij. Bij
    % false andersom.
    % double maximumBias = 0<maximumBias<1; is de maximum afwijking, factor,
    % die wordt afgeweken van het interval.

    % Pre-Calc %
    no_components = size(components, 1);
    no_tasks      = size(tasks, 1);
    no_time_steps = t_max/t_p;

    % Pre-alloc %
    maintenanceTimes      = zeros(no_components, no_tasks);    % Start times of maintenance, per component;
    endTimeMaintenance    = cell(no_components, no_tasks);    % EndTimes of maintenance, per component
    noComponentMainte     = ones(no_components, 1);
    maintTimePerComponent = zeros(no_components, 1);
    FailureRepairTimes    = cell2mat(components(:, 6));
    SignificanceIndices   = cell2mat(components(:, 5));

    % Pre-check %
    interval = cell2mat(input) .* cell2mat(tasks(:, 6)); % in tijd (h)
    for i = 1:no_tasks
        no_executed_maintenance = floor(no_time_steps/interval(i));

        for j = 1:no_executed_maintenance
            tijdstip = floor(j*interval(i));
            if(tijdstip <= 1)
                tijdstip = 1;
            end

            if(tijdstip > t_max)
                continue;
            end

            if (vesselLocation(tijdstip, 2) ~= 1)  %0 is op zee, 1 is in de haven
                % Deze planning kan dus niet omdat het schip dan op zee is.
                % Verzin een nieuwe oplossing.

                ht = floor(tijdstip);
                % Check possible solutions later than t;
                if(forwardBias == true)
                    endTime = (1 + maximumBias) * interval(i);

                    if(j > 1)
                        if(endTime >= (maintenanceTimes(i, j-1) + tasks{i, 6}))
                            endTime = tasks{i, 6};
                        end
                        endTime = endTime + maintenanceTimes(i, j - 1);
                    else
                        if(endTime >= tasks{i, 6})
                            endTime = tasks{i, 6};
                        end
                    end
                    tijdstip = findMaintenanceTime(ht, endTime, t_p, vesselLocation, tasks{i, 4});
                end

                % Check possible solutions earlier than t;
                if(tijdstip == 0 || forwardBias == false)
                    startTime = floor((1 - maximumBias) * interval(i));
                    if(startTime <= 0)
                        startTime = 0;
                    end

                    if(j > 1)
                        startTime = floor(startTime + maintenanceTimes(i, j - 1));
                    else
                        if(startTime <= 0)
                            startTime = 0;
                        end
                    end
                    tijdstip = findMaintenanceTime(startTime, ht, t_p, vesselLocation, tasks{i,4});
                end

                if(tijdstip == 0)
                    totalCost = realmax('single');
                    return;
                else
                    % Solution found.
                    maintenanceTimes(i,j) = tijdstip;
                    component_id = tasks{i, 7};
                    endTimeMaintenance{component_id, noComponentMainte(component_id, 1)} = [tijdstip + tasks{i, 4}, i];
                    noComponentMainte(component_id, 1) = noComponentMainte(component_id, 1) + 1;
                    maintTimePerComponent(component_id, 1) = maintTimePerComponent(component_id, 1) + tasks{i, 4};
                end
            else
                % This time is valid.
                maintenanceTimes(i, j) = tijdstip;
                component_id = tasks{i, 7};
                endTimeMaintenance{component_id, noComponentMainte(component_id, 1)} = [tijdstip + tasks{i, 4}, i];
                noComponentMainte(component_id, 1) = noComponentMainte(component_id, 1) + 1;
                maintTimePerComponent(component_id, 1) = maintTimePerComponent(component_id, 1) + tasks{i, 4};
            end
        end
    end

    % Integrate over Time %
    FailureRateOverTimePerComponent = zeros(no_components, t_max + 1);
    for i = 1:no_components
        endTimes = endTimeMaintenance(i, :);
        endTimes = endTimes(~cellfun('isempty', endTimes));

        FailureRateOverTimePerComponent(i, :) = Failure_Rate_Graphs_No_Maintenance(i, :);

        sz = size(endTimes, 2);
        times = zeros(1, sz);
        ids   = zeros(1, sz);
        for n=1:sz
            times(n) = endTimes{1, n}(1);
            ids(n)   = endTimes{1, n}(2);
        end

        for t = 1:sz
            time = times(t);
            id   = ids(t);

            if(time > t_max)
                continue;
            end

            rest_time = t_max + 1 - time + 1;
            shift     = FailureRateOverTimePerComponent(i, time);
            m2        = tasks{id, 9};
            shift     = shift + m2 * (0 - shift);
            FailureRateOverTimePerComponent(i, time:end) = Failure_Rate_Per_Task(id, 1:rest_time) + shift;
        end
    end

    % Find total cost.
    componentFailures = zeros(no_components, 1);
    for i=1:no_components
        componentFailures (i) = trapz(FailureRateOverTimePerComponent(i, :)); % Integrate
    end
    TotalSignificance = sum(SignificanceIndices);

    Cost_CM   = SignificanceIndices .* FailureRepairTimes .* componentFailures .* timeFactorAtSea .* penaltyCost  ./ TotalSignificance;
    Cost_PM   = maintTimePerComponent .* costPerManhour;
    totalCost = sum(Cost_CM + Cost_PM);
    
    figure;
    title('System failure-rate');
    plot(sum(FailureRateOverTimePerComponent));
    xlabel('Time (h)');
    ylabel('Failure-rate (-)');
    
    figure;
    title('Failure-rate per component');
    for i = 1:no_components
        hold on;
        plot(FailureRateOverTimePerComponent(i, :));
    end
    xlabel('Time (h)');
    ylabel('Failure-rate (-)');
end

