function [beta, eta] = FindWeibullOfComponentById( component_id, Components )
% explenation of use of this funtion
%{
  jhkihhlk  
%}

%% Locate Component by ID

    component_ids = Components(:, 1);
    [rn, ~] = find([component_ids{:}] == component_id);

%% FINDWEIBULLOFTASK Find the Weibull parameters of a task.
    
     beta = Components{rn, 4};
     eta = Components{rn, 3};

end

