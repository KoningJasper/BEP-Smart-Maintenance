function [ Failure_Rate_Graphs_No_Maintenance ] = ConstructFailureRateGraphsNoMaintenance(t_max, Components)
    %ConstructFailureRateGraphsNoMaintenance Summary of this function goes here
    % Detailed explanation goes here
    t = 1:(t_max + 1);
    no_components = size(Components, 1);
    Failure_Rate_Graphs_No_Maintenance = zeros(no_components, t_max + 1);
    m1 = 1;
    
    for i = 1:no_components
        beta  = Components{i, 4};
        theta = Components{i, 3};
        Failure_Rate_Graphs_No_Maintenance(i, :) = beta/theta .* (((((1/m1) .* (t)) / theta).^(beta-1)));
    end
end

