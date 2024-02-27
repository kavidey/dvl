[wfm, metadata] = read_h5('data/test1.h5');

for i = 1:length(metadata(1, :))
    entry = metadata(1, i); 
    entry.Name
    entry.Value
    switch entry.Name
        case 'XInc'
            Fs = 1/entry.Value;
    end
end

t = (1:length(wfm(1,:))) / Fs;
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
%%
figure(3)
% Take STFT of input
binsize = floor(length(cropped_input)/100); 
overlap_percent = 0.9;
[ X, f, t, S ] = spectrogram(cropped_input, hamming(binsize), floor(binsize*overlap_percent), [], Fs);

% Find most prevalent frequency at each point in time
[amp idx] = max(abs(X), [], 1);
input_freq = f(idx);
input_amp = amp;

hold on
imagesc(t, f, pow2db(S))
plot(t, input_freq, "LineWidth", 1.5, "Color", "black")
set(gca,'YDir','normal')
xlabel('Time [s]')
ylabel('Frequency [Hz]')
ylim([min(f) max(f)])
title('Input Frequency')
hold off

% Take STFT of output
[ X, f, t, S ] = spectrogram(cropped_output, hamming(binsize), floor(binsize*overlap_percent), [], Fs);
% Find most prevalent frequency at each point in time
[amp idx] = max(abs(X), [], 1);
output_amp = amp;

figure(4)
semilogx(input_freq, 20 * log(output_amp' ./ input_amp'))
xlabel('Frequency [Hz]')
ylabel('Gain [dB]')
title('Peizo Transfer Function')
