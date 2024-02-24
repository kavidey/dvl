f_sample = 100e3; % [hz]

f_signal = 750e3;
f_bandwidth = 10e3;

f = f_signal + linspace(-f_bandwidth/2, f_bandwidth/2, 11);
% f = [f_signal];

f_percieved_p = [f];
while min(f_percieved_p) > f_sample
    f_percieved_p = [f_percieved_p f_percieved_p-f_sample];
end

f_percieved_n = [-f];
while max(f_percieved_n) < f_sample
    f_percieved_n = [f_percieved_n f_percieved_n+f_sample];
end

clf
hold on
stem(f_percieved_p, ones(1, length(f_percieved_p)), "filled", "Color", "b");
stem(f_percieved_n, 0.9*ones(1, length(f_percieved_n)), "filled", "Color", "r");
stem([f_sample], [1.2], "Color", "g");
hold off

xlabel("Frequency [Hz]");
xlim([0 f_signal+f_bandwidth/2]);
ylim([0, 1.5]);
set(gcf, "Color", "w");

pbaspect([5 1 1])
