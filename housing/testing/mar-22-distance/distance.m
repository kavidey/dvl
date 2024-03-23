clf
clc
clear

input_voltage = 12;  % [V]
bucket_width = 50 * 0.01; % [m]

% shaky measurements, trust trial 2 more
dist1 = [57, 50, 40, 30, 20, 25, 34, 45] * 0.01; % [m] (need to subtract 2cm offset because of where bottom piezo is mounted)
amplitude1 = [250, 290, 315, 350, 375, 360, 340, 335]; % [mVpp]

vertical_dist2 = [57, 50, 40, 30, 20, 10, 15, 25, 36, 45, 57] * 0.01; % [m]
amplitude2 = [260, 280, 300, 330, 350, 365, 340, 319, 307, 297, 240]; % [mVpp]

dist2 = sqrt(vertical_dist2.^2 + bucket_width^2)

% Plot residuals
subplot(2,1,1)
[Xout, Yout] = prepareCurveData(dist2, 1./amplitude2);
[f1,stat1] = fit(Xout,Yout,'poly1');
plot(f1, Xout, Yout, 'residuals');
xlabel("Distance [m]")
ylabel("Residuals [1/mVpp]")
title("Fit Residuals")

% Plot fit
subplot(2,1,2)
confLev = 0.95;

hold on
plot(dist2, amplitude2,'x');

xplot = 0.2:0.05:10;
yplot = f1(xplot);
plot(xplot, 1./yplot);

p11 = predint(f1,xplot,confLev,'observation','off'); % Gen conf bounds
p21 = predint(f1,xplot,confLev,'functional','off'); % Gen conf bounds

plot(xplot, 1./p21, '-.b') % Upper and lower functional confidence limits
plot(xplot, 1./p11, '--m') % Upper and lower observational confidence limits
legend('Data Points','Best Fit Line','Upper Func. Bound',...
    'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
    'Location', 'best')
hold off

xlabel("Distance [m]")
ylabel("Received Amplitude [mVpp]")
title("Distance vs. Received Voltage")

set(gcf, 'Color', 'w');