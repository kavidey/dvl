clear
clf

T = readtable("data/datalog12");
data = table2array(T);

hold on
% data(1,:) = data(1,:)*1e-6; % convert from microseconds to seconds
data(1,:) = 1:length(data)
data(2:end, :) = data(2:end,:) * 1/2^10;
plot(data(1,:), data(2,:), "DisplayName", "A0");
plot(data(1,:), data(3,:), "DisplayName", "A1");

legend()

% xlabel("Time [s]")
xlabel("Sample No.")
ylabel("Voltage [V]")

set(gcf, "Color", "w")
hold off