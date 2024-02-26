function [waveform, metadata] = read_h5(filepath)
% filepath = fullfile(dir(filepath).folder, dir(filepath).name);
info = h5info(filepath);
% fileID = H5F.open(filepath,'H5F_ACC_RDONLY','H5P_DEFAULT');

for i = 1:length(info.Groups())
    Group = info.Groups(i);
    switch Group.Name
        case '/Frame'
            FrameGroup = Group;
        case '/Waveforms'
            WaveformsGroup = Group;
    end
end

waveform = [];
metadata = [];
for i = 1:length(WaveformsGroup.Groups())
    Group = WaveformsGroup.Groups(i);
    signal = h5read(filepath, strcat(strcat(Group.Name,'/'), Group.Datasets(1).Name));
    waveform = horzcat(waveform, signal);
    metadata = [metadata Group.Attributes];
end
waveform = waveform';
metadata = metadata';