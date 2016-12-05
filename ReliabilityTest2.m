% Parameters
beta  = 2.5;
eta   = 4000;
tp    = 2000;
m1    = 0.8;
m2    = 0.5;
t_max = 6000;

% Pre-Alloc
R2P = [0 1];
h2P = [0 0];

R1b = [0 1];
h1b = [0 0];

R1a = [0 1];
h1a = [0 0];

Rna = [0 1];
hna = [0 0];

% NO-ACTION
Rnaj = [1];
hnaj = [0];
for t=1:t_max
    [Rna, Rnaj] = ReliabilityT(Rna, Rnaj, 1, t, t + 1, 1, 0, eta, beta);
    [hna, hnaj] = FailureRateT(hna, hnaj, 0, t, t + 1, 1, 0, eta, beta);
end

% 1a maintenance
R1aj = [1];
h1aj = [0];
for t=1:t_max
    [R1a, R1aj] = ReliabilityT(R1a, R1aj, 1, t, tp, m1, 0, eta, beta);
    [h1a, h1aj] = FailureRateT(h1a, h1aj, 0, t, tp, m1, 0, eta, beta);
end

% 1b maintenance
R1bj = [1];
h1bj = [0];
for t=1:t_max
    [R1b, R1bj] = ReliabilityT(R1b, R1bj, 1, t, tp, m1, m2, eta, beta);    
    [h1b, h1bj] = FailureRateT(h1b, h1bj, 0, t, tp, m1, m2, eta, beta);
end

% 2P maintenance
R2Pj = [1];
h2Pj = [0];
for t=1:t_max
    [R2P, R2Pj] = ReliabilityT(R2P, R2Pj, 1, t, tp, 1, 1, eta, beta);       
    [h2P, h2Pj] = FailureRateT(h2P, h2Pj, 0, t, tp, 1, 1, eta, beta);
end

% OUTPUT
% Output reliability function.
figure;
plot(R2P(:, 1), R2P(:, 2));
hold on;
plot(R1b(:, 1), R1b(:, 2));
hold on;
plot(R1a(:, 1), R1a(:, 2));
hold on;
plot(Rna(:, 1), Rna(:, 2));
title('Reliability over time');
legend({'2P-maintenance', '1b-maintenance', '1a-maintenance', 'No action'}, 'Location','southwest');
ylim([0 1]);
xlim([0 t_max]);
xlabel('Time [h]');
ylabel('Reliability [-]');

% Output hazard function
figure;
plot(h2P(:, 1), h2P(:, 2));
hold on;
plot(h1b(:, 1), h1b(:, 2));
hold on;
plot(h1a(:, 1), h1a(:, 2));
hold on;
plot(hna(:, 1), hna(:, 2));
title('Failure rate over time');
xlim([0 6000]);
xlabel('Time [h]');
ylabel('Failure rate [-]');
legend({'2P-maintenance', '1b-maintenance', '1a-maintenance', 'No action'}, 'Location','northwest');