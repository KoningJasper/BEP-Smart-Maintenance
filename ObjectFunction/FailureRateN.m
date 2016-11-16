function [ failure_rate ] = FailureRate_N( step_size, step_no, weibull_beta,...
    weibull_eta,weibull_m1,FailureRate_0)
%Calculating the new failure rate after each time-step 

%To calculate the new failure rate a weibull-distribution of the failure
%rate of the component in the general case is necesarry, providing beta, m1
%and eta.

FailureRate_N = FailureRate_0 + 1/weibull_m1*weibull_beta/weibull_eta*...
    ((1/weibull_m1*(step_size))/weibull(eta))^(weibull_beta-1);

end

