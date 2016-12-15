function [ FRT ] = ConstructFailureRateGraphsPerTask(t_max, Tasks, Components)
%CONSTRUCTFAILURERATEGRAPHS make the failurerate graphs per component

    t = 1:(t_max + 1);
    no_tasks = size(Tasks, 1);
    FRT = zeros(no_tasks, t_max + 1);
    
    for i = 1:no_tasks
        [beta, theta] = FindWeibullOfComponentById(Tasks{i, 7}, Components);
        m1 = Tasks{i, 8};
        FRT(i, :) = beta/theta .* (((((1/m1) .* (t)) / theta).^(beta-1)));
    end
end

%{

In this function the failure rates per component are generated, this is done
to make the program faster. because every type of maintance has the same
slopeshape. it is faster to calculate the curve once and then interupt it
when maintance is done. At this point the curve is started again an put
head to tail with the previous, a maintance steps is sometimes made
deppeniding on the type of maintance. (AGAO or AGON)

this function works togthere with the no maintance graphs tot get the
compleet graphs.

%}