function [ FR0 ] = ConstructFailureRateGraphsNoMaintenance(t_max, Components)
    %in this function the basegraph of the maintance is created for every compenent when no maintance is done. is need in combination with construct failureRateGraphs per task for the total graph 
    
    t = 1:(t_max + 1);
    no_components = size(Components, 1);
    FR0 = zeros(no_components, t_max + 1);
    m1 = 1;
    
    for i = 1:no_components
        
        beta        = Components{i, 4};
        theta       = Components{i, 3};
        FR0(i, :)   = beta/theta .* (((((1/m1) .* (t)) / theta).^(beta-1)));
        
    end
end

