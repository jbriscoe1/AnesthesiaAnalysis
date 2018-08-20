
function [selectedFiles] = selectFiles(dataFiles, session, structure)

s1 = [1:16];
s2 = [17:32];
pm = [33:48];

for i = 1:length(dataFiles)
%     channelList(i,1) = str2num(dataFiles(i).name(9:10));
  channelList(i,1) = str2num(dataFiles(i).name(19:20));
end

if structure == 'S1'
    structureIndex = ismember(channelList, s1);
elseif structure == 'S2'
    structureIndex = ismember(channelList, s2);
elseif structure == 'PM'
    structureIndex = ismember(channelList, pm);
end

for i = 1:length(dataFiles)
    if isequal(mat2str(dataFiles(i).name(1:7)), session)
        sessionIndex(i,1) = 1;
    else
        sessionIndex(i,1) = 0;
    end
end

selectedFiles = find((sessionIndex + structureIndex)==2);
