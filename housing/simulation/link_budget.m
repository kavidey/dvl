%%% Using the Friis equation to estimate link buget %%%

% Power into the piezo
% This is assuming a 12 V battery, doubled to 24 V with a boost converter, then doubled again using an H-Bridge Driver
Pt = 48 * 0.1; % 48 V * 0.1 A = 4.8 W

f = 750e3; % [Hz] Frequency
c = 1500; % [m/s] Speed of sound in seawater http://www.dosits.org/tutorials/sciencetutorial/speed/
lambda = c/f; % [m] Wavelength

% Efficiency of converting electrical power into mechanical power (Electromechanical coupling coefficient)
Kp = 0.51; % [%] From piezo datasheet (https://www.steminc.com/PZT/en/piezo-ceramic-disc-20x27mm-s-750-khz)
diameter = 0.02; %[m]
%% Find acoustic Reflection and Transmission Coefficients (http://hyperphysics.phy-astr.gsu.edu/hbase/Sound/refltrans.html)
Rp = @(Z1, Z2) (Z2-Z1)/(Z1 + Z2); % Acoustic Reflection Coefficient
Tp = @(Z1, Z2) (2*Z2)/(Z1 + Z2); % Acoustic Transmission Coefficient

dB_to_Gain = @(dB) 10.^(dB/20);

% Water absorption math (basically it doesn't make a difference)
% http://resource.npl.co.uk/acoustics/techguides/seaabsorption/ (750 kHz, 15 C, 10 m)
alpha = 210; % [dB/km] Water Absorption 
alpha = 1 / dB_to_Gain(alpha/1e3); % [/m] (divide by 1 because its attenuating)

% Acoustic Impedances
Z_water = 1.48; % [MRayl]
Z_ocean_floor = (1750 * 1700) * 1e-6; % [MRayl] (https://link.springer.com/article/10.1007/BF00163476, https://pubmed.ncbi.nlm.nih.gov/24744686/)

%% Antenna Gain
beam_width = asin(1.2 * c/(diameter*f));
antenna_gain = 2 / (1-cos(beam_width/2));
%% Calculate Power vs. Distance
Gt = antenna_gain; % [] Transmit Gain
Gr = antenna_gain; % [] Recieve Gain

d = 0.5:0.1:10; % [m] Test loss from distances 0.5-10 m

transmit_loss = Gt .* (lambda./(4.*pi.*d)).^2 .* Kp;
% Accordign to e80 lectures this should be close to 1
% reflect_loss = Rp(Z_water, Z_ocean_floor); 0.33
reflect_loss = 1;
recieve_loss = Gr .* (lambda./(4.*pi.*d)).^2 .* Kp;
Pr = Pt .* transmit_loss .* reflect_loss .* recieve_loss;

clf
plot(d,  Gr .* (lambda./(4.*pi.*d)).^2 .* Kp);
xlabel("Distance [m]")
ylabel("Recieved Power [W]");
xlim([0,11]);
set(gca, 'YScale', 'log');
set(gcf, "Color", "w");
grid on
