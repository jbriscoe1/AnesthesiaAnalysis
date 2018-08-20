%%peak frequency statistics on all sessions %%

clc; clear all; close all;

%% ADD PATH
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\PowerSpectrum'));
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\chronux_2_11'));

%% Input Files
spectrumDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\SpectrumData\PFData\14to40HzWindow\Ewok\PM';
spectrumDataFiles = dir([spectrumDirectory, '/*.mat']);

%%Save Folder
saveFileName = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Statistics\peakFrequency\Spectrum\pmSecondPeakOnly';

%% ITERATE THROUGH SESSIONS
for i = 1:length(spectrumDataFiles)
    allSessions(i,1:7) = spectrumDataFiles(i).name(1:7);
end
uniqueSessions = unique(allSessions, 'rows');

awakeFreqList = [];
rocFreqList = [];
ropapFreqList = [];
channelsRemovedArtifact = [];
channelsRemovedNoise = [];

for j = 1:length(uniqueSessions)
    
    session = uniqueSessions(j,:);
    disp(sprintf('Processing File: %s, %d/%d', session, j, length(uniqueSessions)));
    
    %% LOAD DATA
    load([spectrumDirectory, '\', spectrumDataFiles(j).name]);

    %% CALCULATE PEAK FREQUENCY
    for rr = 1:size(awakeSpectralData, 2)
        secondPeakAwake = find(awakeF >24 & awakeF <32);     
        [awakePeakFreq(rr), awakeIndexPeakFreq(rr)] = max(awakeSpectralData(secondPeakAwake,rr));
%       [awakePeakFreq(rr), awakeIndexPeakFreq(rr)] = max(awakeSpectralData(:,rr));
        awakePeakFreq(rr) = awakeF(secondPeakAwake(1)+awakeIndexPeakFreq(:,rr));
        awakePeakFreq = awakePeakFreq(awakePeakFreq >=16 & awakePeakFreq<=32);         
    end
    awakePeakFreq = awakePeakFreq';
    
    for rr = 1:size(rocSpectralData, 2)
        [rocPeakFreq(rr), rocIndexPeakFreq(rr)] = max(rocSpectralData(:,rr));
        rocPeakFreq = rocF(rocIndexPeakFreq);
        sixteenHzArtifact = sum(rocPeakFreq >16 & rocPeakFreq <17);
        overThirtyFiveHzNoise = sum(rocPeakFreq >35);
        rocPeakFreq = rocPeakFreq(rocPeakFreq >=17 & rocPeakFreq<=32);         
    end
    rocPeakFreq = rocPeakFreq';
    
    for rr = 1:size(ropapSpectralData, 2)
        secondPeakRopap = find(ropapF >24 & ropapF <32);
        [ropapPeakFreq(rr), ropapIndexPeakFreq(rr)] = max(ropapSpectralData(secondPeakRopap,rr));
%       [ropapPeakFreq(rr), ropapIndexPeakFreq(rr)] = max(ropapSpectralData(:,rr));
        ropapPeakFreq(rr) = ropapF(secondPeakRopap(1)+ropapIndexPeakFreq(:,rr));
        ropapPeakFreq = ropapPeakFreq(ropapPeakFreq >=16 & ropapPeakFreq<=32);
    end
    ropapPeakFreq = ropapPeakFreq';
    
    %% CREATE TABLE OF DATA
    awakeFreqList = [awakeFreqList; awakePeakFreq];
    rocFreqList = [rocFreqList; rocPeakFreq];
    ropapFreqList = [ropapFreqList; ropapPeakFreq];
    
    channelsRemovedArtifact = [channelsRemovedArtifact sixteenHzArtifact];
    channelsRemovedNoise = [channelsRemovedNoise overThirtyFiveHzNoise];
    
    clear secondPeakAwake secondPeakRopap awakePeakFreq awakeSpectralData awakeIndexPeakFreq rocPeakFreq rocSpectralData rocIndexPeakFreq ropapPeakFreq ropapSpectralData ropapIndexPeakFreq

end

    sumRemovedChannelsArtifact = sum(channelsRemovedArtifact,2);
    sumRemovedChannelNoise = sum(channelsRemovedNoise, 2);
    save([saveFileName, '\', spectrumDataFiles(j).name(1), '-', spectrumDataFiles(j).name(8:9)], 'awakeFreqList', 'rocFreqList', 'ropapFreqList', '-v7.3');
    excelFileName = [spectrumDataFiles(j).name(1), '-', spectrumDataFiles(j).name(8:9),'ArtifactSum.xls'];
    xlswrite([saveFileName, '\', excelFileName], channelsRemovedArtifact, 'sheet1', 'A1');
    xlswrite([saveFileName, '\', excelFileName], sumRemovedChannelsArtifact, 'sheet1', 'A2');
    xlswrite([saveFileName, '\', excelFileName], channelsRemovedNoise, 'sheet1', 'A3');
    xlswrite([saveFileName, '\', excelFileName], sumRemovedChannelNoise, 'sheet1', 'A4');
