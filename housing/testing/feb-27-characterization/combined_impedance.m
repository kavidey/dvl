test2 = load('test2.mat');
test3 = load('test3.mat');
test4 = load('test4.mat');
test5 = load('test5.mat');

close all

hold on
cm = colormap('lines'); % Get default line colors
plot(test2.input_freq(2000:end), test2.impedance(2000:end), 'Color', cm(1,:), 'HandleVisibility', 'off')
plot(test3.input_freq, test3.impedance, 'Color', cm(1,:), 'HandleVisibility', 'off')
plot(test4.input_freq, test4.impedance, 'Color', cm(1,:), 'HandleVisibility', 'off')
plot(test5.input_freq(1500:end), test5.impedance(1500:end), 'Color', cm(1,:), 'HandleVisibility', 'off')
plot(NaN, 'DisplayName', 'Impedance', 'Color', cm(1,:))

xline(750e3, 'DisplayName', 'Predicted Resonant Frequency', 'Color', cm(2,:))

legend("Location", "best")
xlabel('Frequency [Hz]')
ylabel('Impedance [$\Omega$]','interpreter','latex')
title('Peizo Transfer Function')
grid on
xscale log
yscale log
hold off
set(gcf, "Color", "w")