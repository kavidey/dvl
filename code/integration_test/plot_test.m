clear
clf

T = readtable("data/sonar_015");
data = table2array(T);

total_samples = size(data);
total_samples = total_samples(1)/3

sample_to_plot = 12;

teensy_conversion = 3.3/2^10;
time_conversion = 1e-6;

tiledlayout(2,1)

nexttile
plot(data(3*sample_to_plot+1, :)*time_conversion, data(3*sample_to_plot+2, :)*teensy_conversion)
ylim([0 3.3])

nexttile
plot(data(3*sample_to_plot+1, :)*time_conversion, data(3*sample_to_plot+3, :)*teensy_conversion)
ylim([0 3.3])