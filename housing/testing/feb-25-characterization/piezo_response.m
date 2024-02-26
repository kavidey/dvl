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

clf
close all

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
pspectrum(cropped_input, cropped_t, 'spectrogram')