function [waveform, t] = read_h5(filepath)
% filepath = 'data/test1.h5'
% filepath = fullfile(dir(filepath).folder, dir(filepath).name);
info = h5info(filepath);
% fileID = H5F.open(filepath,'H5F_ACC_RDONLY','H5P_DEFAULT');

for i = 1:length(info.Groups())
    Group = info.Groups(i);
    switch Group.Name
        case '/Trace'
            TraceGroup = Group;
    end
end

for i = 1:length(TraceGroup.Groups())
    Group = TraceGroup.Groups(i);
    switch Group.Name
        case '/Trace/Dependent'
            DependentGroup = Group;
        case '/Trace/Independent'
            IndependentGroup = Group;
        case '/Trace/metadata'
            MetadataGroup = Group;
    end
end

for i = 1:length(IndependentGroup.Groups())
    Group = IndependentGroup.Groups(i);
    GroupName = h5read(filepath, sprintf('/Trace/Independent/%i/metadata/displayName', i-1));
    switch GroupName
        case 'Time'
            t = h5read(filepath, sprintf('/Trace/Independent/%i/Data', i-1));
    end
end

waveform = [];
for i = 1:length(DependentGroup.Groups())
    Group = DependentGroup.Groups(i);
    signal = h5read(filepath, strcat(Group.Name, "/Data"));
    waveform = horzcat(waveform, signal);
end
waveform = waveform';