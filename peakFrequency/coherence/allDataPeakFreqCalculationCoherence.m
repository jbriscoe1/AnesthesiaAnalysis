%%peak frequency statistics on all sessions %%

clc; clear all; close all;

%% ADD PATH
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\Coherence\PeakFrequency'));
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\chronux_2_11'));

%% Input Files
coherenceDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\coherogramData\groupCoherenceData\16to40Hz\AllSessions\S1S1\';
coherenceDataFiles = dir([coherenceDirectory, '/*.mat']);
%% Save Folder
saveDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Statistics\peakFrequency\Coherence\AllSessionsbyAnimal\16removedto30';

%% ITERATE THROUGH SESSIONS
% for i = 1:length(coherenceDataFiles)
%     allSessions(i,1:7) = coherenceDataFiles(i).name(1:7);
% end
% uniqueSessions = unique(allSessions, 'rows');

awakeFreqList = [];
rocFreqList = [];
ropapFreqList = [];
channelsRemovedArtifact = [];
channelsRemovedNoise = [];
rocChannelCount = [];

for k = 1:length(coherenceDataFiles)
    
%     session = uniqueSessions(k,:);
    disp(sprintf('Processing File: %s, %d/%d', coherenceDataFiles(k).name, k, length(coherenceDataFiles)));
    
    %% LOAD DATA
    load([coherenceDirectory, '\', coherenceDataFiles(k).name]);
    
    %%Averqage Coherence Data
%     meanAwakeCoherenceData = mean(awakeCoherenceData, 2);
%     meanRocCoherenceData = mean(rocCoherenceData, 2);
%     meanRopapCoherenceData = mean(ropapCoherenceData, 2);
    
    %% CALCULATE PEAK FREQUENCY
    for rr = 1:size(awakeCoherenceData, 2)
        [awakePeakFreq(rr), awakeIndexPeakFreq(rr)] = max(awakeCoherenceData(:,rr));
        awakePeakFreq(rr) = awakef(awakeIndexPeakFreq(:,rr));
%         [awakePeakFreq, awakeIndexPeakFreq] = max(meanAwakeCoherenceData);
%         awakePeakFreq = awakef(awakeIndexPeakFreq);
        awakePeakFreq = awakePeakFreq(awakePeakFreq >=16 & awakePeakFreq<=30);         
    end
    awakePeakFreq = awakePeakFreq';
    
    for rr = 1:size(rocCoherenceData, 2)
        [rocPeakFreq(rr), rocIndexPeakFreq(rr)] = max(rocCoherenceData(:,rr));
        rocPeakFreq = rocf(rocIndexPeakFreq);
%         [rocPeakFreq, rocIndexPeakFreq] = max(meanRocCoherenceData);
%         rocPeakFreq = rocf(rocIndexPeakFreq);
        sixteenHzArtifact = sum(rocPeakFreq >16 & rocPeakFreq <17);
        overThirtyHzNoise = sum(rocPeakFreq >30);
        rocPeakFreq = rocPeakFreq(rocPeakFreq >=17 & rocPeakFreq<=30);         
    end
    rocPeakFreq = rocPeakFreq';
    channelCount = size(rocCoherenceData, 2);
    
    for rr = 1:size(ropapCoherenceData, 2)
        [ropapPeakFreq(rr), ropapIndexPeakFreq(rr)] = max(ropapCoherenceData(:,rr));
        ropapPeakFreq(rr) = ropapf(ropapIndexPeakFreq(:,rr));
%         [ropapPeakFreq, ropapIndexPeakFreq] = max(meanRopapCoherenceData);
%         ropapPeakFreq = ropapf(ropapIndexPeakFreq);
        ropapPeakFreq = ropapPeakFreq(ropapPeakFreq >=16 & ropapPeakFreq<=30);
    end
    ropapPeakFreq = ropapPeakFreq';
    
    %% CREATE TABLE OF DATA
    awakeFreqList = [awakeFreqList; awakePeakFreq];
    rocFreqList = [rocFreqList; rocPeakFreq];
    ropapFreqList = [ropapFreqList; ropapPeakFreq];
    channelsRemovedArtifact = [channelsRemovedArtifact sixteenHzArtifact];
    channelsRemovedNoise = [channelsRemovedNoise overThirtyHzNoise];
    rocChannelCount = [rocChannelCount channelCount];
    
    clear awakePeakFreq awakeSpectralData awakeIndexPeakFreq rocPeakFreq rocSpectralData rocIndexPeakFreq ropapPeakFreq ropapSpectralData ropapIndexPeakFreq sixteenHzArtifact overThirtyTwoHzNoise channelCount

end

    sumRemovedChannelsArtifact = sum(channelsRemovedArtifact,2);
    sumRemovedChannelNoise = sum(channelsRemovedNoise, 2);
    
    save([saveDirectory, '\', coherenceDataFiles(k).name(1), coherenceDataFiles(k).name(9:12),'17to30'], 'awakeFreqList', 'rocFreqList', 'ropapFreqList', '-v7.3');
    saveFileName = [coherenceDataFiles(k).name(9:12), 'ArtifactSum.xls'];
    
    xlswrite([saveDirectory, '\', saveFileName], channelsRemovedArtifact, 'sheet1', 'A1');
    xlswrite([saveDirectory, '\', saveFileName], sumRemovedChannelsArtifact, 'sheet1', 'A2');
    xlswrite([saveDirectory, '\', saveFileName], channelsRemovedNoise, 'sheet1', 'A3');
    xlswrite([saveDirectory, '\', saveFileName], sumRemovedChannelNoise, 'sheet1', 'A4');
    xlswrite([saveDirectory, '\', saveFileName], rocChannelCount, 'sheet1', 'A6');


    
%     
%     for k = 1:length(coherenceDataFiles)
%     
%      load([coherenceDirectory, '\', coherenceDataFiles(k).name]);
%      
%      figure; 
%      plot(awakef, mean(awakeCoherenceData, 2));
%      leftIndex = find(awakef > 17);
%      rightIndex = find(awakef > 30);
%     [a,awakeIndex] = max(mean(awakeCoherenceData, 2));
%     (leftIndex(1):rightIndex(1));
%      hold on;
%      plot(awakef(awakeIndex), a, 'ro', 'linewidth', 2);     
%      hold off;
%         
%      clear a awakeIndex awakeCoherenceData awakef leftIndex rightIndex 
%      
%     end
    
    
    
    
    
    
    
    
    