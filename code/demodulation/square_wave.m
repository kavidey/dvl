clear
clf
clc

Fs = 10e6; % 10 MHz
f = 750e3; % 750 kHz
% duration = 0.0002; % 0.2 ms
duration = 100 / f; % 100 cycles

t = 0:1/Fs:duration;
y1 = square(2*pi*(f-20e3)*t);

y2 = square(2*pi*(f+1e3)*t)+randn(size(t))/10;
y3 = square(2*pi*(f-1e3)*t)+randn(size(t))/10;

demod1 = y1.*y2;
demod2 = y1.*y3;

lpf = @(y) lowpass(y, 10e3, Fs, ImpulseResponse="iir",Steepness=0.8);
filtered1 = lpf(demod1);
filtered2 = lpf(demod2);

set(gcf, 'Color', 'w');

subplot(4, 1, 1)
hold on
plot(t, y1, 'DisplayName', 'Base Frequency');
xlabel("Time [s]")
legend()
title("Base Frequency: 730 kHz")
hold off


subplot(4, 1, 2)
hold on
plot(t, demod1, 'DisplayName', 'Demodulated');
plot(t, filtered1, "DisplayName", 'Filtered', 'LineWidth', 2)
xlabel("Time [s]")
legend()
title("Test Signal: 751 kHz")
hold off


subplot(4, 1, 3)
hold on
plot(t, demod2, 'DisplayName', 'Demodulated');
plot(t, filtered2, "DisplayName", 'Filtered', 'LineWidth', 2)
xlabel("Time [s]")
legend()
title("Test Signal: 749 kHz")
hold off

subplot(4, 1, 4)
hold on
plot(t, filtered1, "DisplayName", '751 kHz', 'LineWidth', 2)
plot(t, filtered2, "DisplayName", '749 kHz', 'LineWidth', 2)
legend()
title("Compare response with different frequencies")
xlabel("Time [s]")
hold off