test_name = 'test5'
[wfm, t] = read_h5(sprintf('data/%s.h5', test_name));
Fs = 1/(t(2)-t(1));
R = 98.1; % [Ohm]
%%
clf
close all

set(gcf, "Color", "w")

figure(1)
hold on
plot(t, wfm(1,:));
plot(t, wfm(2,:));
plot(t, wfm(3,:));
xlabel("Time [s]")
ylabel("Voltage [V]")
title("Original Data")
legend("Input", "Trigger", "Output")
hold off

valid_signal = wfm(2,:) < 3;
cropped_t = (1:sum(valid_signal))/Fs;
cropped_input = wfm(1,valid_signal);
cropped_output = wfm(3,valid_signal);
figure(2)
hold on
plot(cropped_t, cropped_input);
plot(cropped_t, cropped_output);
xlabel("Time [s]")
ylabel("Voltage [V]")
title("Cropped Data")
legend("Input", "Output")
hold off

figure(3)
% Take STFT of input
binsize = floor(length(cropped_input)/50); 
overlap_percent = 0.99;
[ X, f, t, S ] = spectrogram(cropped_input, hamming(binsize), floor(binsize*overlap_percent), [], Fs);

% Find most prevalent frequency at each point in time
[amp idx] = max(abs(X), [], 1);
input_freq = f(idx);
% input_freq = logspace(3,log10(2e6), length(input_freq));
input_amp = amp;

hold on
imagesc(t, f, pow2db(S))
plot(t, input_freq, "LineWidth", 1.5, "Color", "black")
set(gca,'YDir','normal')
xlabel('Time [s]')
ylabel('Frequency [Hz]')
ylim([min(f) max(input_freq)])
xlim([min(t) max(t)])
title('Input Frequency')
hold off

% Take STFT of output
[ X, f, t, S ] = spectrogram(cropped_output, hamming(binsize), floor(binsize*overlap_percent), [], Fs);
% Find most prevalent frequency at each point in time
[amp idx] = max(abs(X), [], 1);
output_amp = amp;
output_current = output_amp/R;
impedance = input_amp ./ output_current;

figure(4)
hold on
plot(input_freq, impedance)
xline(750e3)
legend("Impedance", "Predicted Resonant Frequency")
xlabel('Frequency [Hz]')
ylabel('Impedance [$\Omega$]','interpreter','latex')
title('Peizo Transfer Function')
grid on
xscale log
yscale log
hold off
set(gcf, "Color", "w")

mat_name = strcat(test_name, ".mat");
save(mat_name, 'input_freq', 'impedance');