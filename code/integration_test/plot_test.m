clear
clf

T = readtable("data/dana_point/afternoon/sonar_026");
data = table2array(T);
i
total_samples = size(data);
total_samples = (total_samples(1)/3)/2

sample_to_plot = 100;

teensy_conversion = 3.3/2^10;
time_conversion = 1e-6;

figure(1)
tiledlayout(4,1)

nexttile
plot(data(3*sample_to_plot+1, :)*time_conversion, data(6*sample_to_plot+2, :)*teensy_conversion)
ylim([0 3.3])

nexttile
plot(data(3*sample_to_plot+1, :)*time_conversion, data(6*sample_to_plot+3, :)*teensy_conversion)
ylim([0 3.3])

nexttile
plot(data(3*sample_to_plot+1, :)*time_conversion, data(6*sample_to_plot+5, :)*teensy_conversion)
ylim([0 3.3])

nexttile
plot(data(3*sample_to_plot+1, :)*time_conversion, data(6*sample_to_plot+6, :)*teensy_conversion)
ylim([0 3.3])

time_signal = data(3*sample_to_plot+1, :)*time_conversion;
tof_signal = data(6*sample_to_plot+6, :)*teensy_conversion;
[l,s] = runlength(tof_signal>0.5, 1e5);

tof = mean(l(~s & l > 5 & l < 200)) * (time_signal(1)-time_signal(2))
dist = 1500 * tof

% figure(2)
% Fs = 1/(time_signal(1) - time_signal(2));
% L = length(tof_signal);
% T = 1/Fs;

% Y = fft(tof_signal);
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);

% f = Fs/L*(0:(L/2));

% plot(f, P1)