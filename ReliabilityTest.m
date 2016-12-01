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

Rna = ones(t_max, 1);
hna = [0 0];

% NO-ACTION
for t=1:t_max
    index = t + 1;
    Rna(index, 1) = ReliabilityPartial(1, t, 1, 1, 0, eta, beta);
    hna = [hna; t FailureRatePartial(hna(1,2), t, 1, 1, 0, eta, beta)];
end

% 1a maintenance
for t=1:2000
    R1a = [R1a; t ReliabilityPartial(1, t, 1, 1, tp, eta, beta)];
    h1a = [h1a; t FailureRatePartial(h1a(1,2), t, 1, 1, tp, eta, beta)];
end

R1a_last = R1a(end, 2);
h1a_last = h1a(end, 2);

for t=2000:4000
    R1a = [R1a; t ReliabilityPartial(R1a_last, t, 2, m1, tp, eta, beta)];
    h1a = [h1a; t FailureRatePartial(h1a_last, t, 2, m1, tp, eta, beta)];
end

R1a_last = R1a(end, 2);
h1a_last = h1a(end, 2);

for t=4000:6000
    R1a = [R1a; t ReliabilityPartial(R1a_last, t, 3, m1, tp, eta, beta)];
    h1a = [h1a; t FailureRatePartial(h1a_last, t, 3, m1, tp, eta, beta)];
end

% 1b maintenance
for t=1:2000
    R1b = [R1b; t ReliabilityPartial(1, t, 1, 1, tp, eta, beta)];
    h1b = [h1b; t FailureRatePartial(0, t, 1, 1, tp, eta, beta)];
end

R_0_1_b  = (R1b(end, 2) + m2*(1 - R1b(end, 2)));
h1b_last = h1b(end, 2) + m2*(0 - h1b(end, 2));

for t=2000:4000
    R1b = [R1b; t ReliabilityPartial(R_0_1_b, t, 2, m1, tp, eta, beta)]; 
    h1b = [h1b; t FailureRatePartial(h1b_last, t, 2, m1, tp, eta, beta)];
end

R_0_2_b = (R1b(end, 2) + m2*m2*(1 - R1b(end, 2)));
h1b_last = h1b(end, 2) + m2*m2*(0 - h1b(end, 2));

for t=4000:6000
    R1b = [R1b; t ReliabilityPartial(R_0_2_b, t, 3, m1, tp, eta, beta)];
    h1b = [h1b; t FailureRatePartial(h1b_last, t, 3, m1, tp, eta, beta)];
end

% 2P maintenance
for t=1:2000
    R2P = [R2P; t ReliabilityPartial(1, t, 1, 1, tp, eta, beta)];
    h2P = [h2P; t FailureRatePartial(0, t, 1, 1, tp, eta, beta)];
end

for t=2000:4000
    R2P = [R2P; t ReliabilityPartial(1, t, 2, 1, tp, eta, beta)];    
    h2P = [h2P; t FailureRatePartial(0, t, 2, 1, tp, eta, beta)];
end

for t=4000:6000
    R2P = [R2P; t ReliabilityPartial(1, t, 3, 1, tp, eta, beta)];
    h2P = [h2P; t FailureRatePartial(0, t, 3, 1, tp, eta, beta)];
end

% Output
figure;
plot(R2P(:, 1), R2P(:, 2));
hold on;
plot(R1b(:, 1), R1b(:, 2));
hold on;
plot(R1a(:, 1), R1a(:, 2));
hold on;
plot(Rna(:, 1));
title('Reliability over time');
legend({'2P-maintenance', '1b-maintenance', '1a-maintenance', 'No action'}, 'Location','southwest');
ylim([0 1]);
xlim([0 6000]);
xlabel('Time [h]');
ylabel('Reliability [-]');

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