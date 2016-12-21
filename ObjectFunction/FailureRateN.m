function [ failure_rate ] = FailureRateN( step_size, weibull_beta, weibull_eta, m1, FailureRate_0)
    %Calculating the new failure rate after each time-step 

    %To calculate the new failure rate a weibull-distribution of the failure
    %rate of the component in the general case is necesarry, providing beta, m1
    %and eta.
    
    failure_rate = FailureRate_0 + 1/(m1 + 1) * weibull_beta/weibull_eta*((step_size/(m1 + 1))/weibull_eta)^(weibull_beta-1);
end