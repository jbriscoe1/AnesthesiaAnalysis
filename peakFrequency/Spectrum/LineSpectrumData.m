%%PSD Data Calculation for Line Spectrum

clc; clear all; close all;

%% ADD PATH
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\PowerSpectrum'));
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\chronux_2_11'));

%% INPUT DATA
dataDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\lfpData';
dataFiles = dir([dataDirectory, '/*.mat']);
saveDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\SpectrumData\PFData\16_30';
%% ITERATE THROUGH SESSIONS
for i = 1:length(dataFiles)
    allSessions(i,1:7) = dataFiles(i).name(1:7);
end
uniqueSessions = unique(allSessions, 'rows');

structures = {'S1', 'PM'};

for j = 1:14 %length(uniqueSessions)
    
    for k = 1:length(structures)
        
        awakeCounter = 0;
        deepAnesCounter = 0;
        rocCounter = 0;
        ropapCounter = 0;

        awakeSpectralData = [];
        deepAnesSpectralData = [];
        rocSpectralData = [];
        ropapSpectralData = [];

        session = uniqueSessions(j,:);
        structure = structures{k};
        selectedFiles = selectFiles(dataFiles, mat2str(session), structure);
        
        if ~isempty(selectedFiles)
            for i = 1:length(selectedFiles)
                
                disp(sprintf('Processing File: %s, %d/%d', session, i, length(selectedFiles)));
                
                %% LOAD DATA
                
                load([dataDirectory, '/', dataFiles(selectedFiles(i)).name]);
                
                  %% CONSTRAIN LFP DATA TO TASK
                if i == 1
                    fs = 1000;
                    firstTime = targetData.DataArray(1,1);
                    lastTime = targetData.DataArray(end,2);
                    timeAxis = 1/1000:1/1000:length(targetData.LFP.data)/1000;
                    lfpDataIndex = find(timeAxis>=firstTime & timeAxis<=lastTime);
                end
                
                %% COMPUTE EPOCH DATA
                bEngage = targetData.behaviorEstimateEngagement(2:end,:);
                bPerform = targetData.behaviorEstimatePerformance(2:end,:);
                
                trialTimes = targetData.DataArray(:,2);
                trialErrors = targetData.DataArray(:,4);
                
                startAnesthesiaTrial = targetData.Anesthesia.starttrial;
                startAnesthesiaTime = targetData.DataArray(startAnesthesiaTrial,1);
                endAnesthesiaTrial = targetData.Anesthesia.endtrial;
                endAnesthesiaTime = targetData.DataArray(endAnesthesiaTrial,1);
                
                     %finds time for awake behavior using bperform within trialTimes
                awakeSearchIndex = find(trialTimes < startAnesthesiaTime);
                awakeIndex = find((bPerform(awakeSearchIndex,4) > .99));
                awakeTime = trialTimes(awakeIndex(5)+awakeSearchIndex(1));
                %determines window after awake time is found %add 60 for one minute window%
                awakeTimeEnd = awakeTime+240;
                [ aTrialD, awakeTimesEnd] = min(abs(trialTimes-awakeTimeEnd));
                awakeTimeEnd = trialTimes(awakeTimesEnd);
                
                %finds the index in lfpDataIndex that corresponds to the window start%
                awakeTimeForLFP = awakeTime*1000;
                awakeTimeEndForLFP = awakeTimeEnd*1000;
                [ awakeDiff, awakeLfpDataIndex] = min(abs(lfpDataIndex-awakeTimeForLFP));
                [ awakeEndDiff, awakeEndLfpDataIndex] = min(abs(lfpDataIndex-awakeTimeEndForLFP));
                
                %creates single variable with epoch of interest%
                awakeLfpEpoch = targetData.LFP.data(awakeLfpDataIndex:awakeEndLfpDataIndex);
                
                   % deep anesthesia epoch %
                 deepAnesSearchIndex = find(trialTimes < endAnesthesiaTime);
                 deepAnesIndex = find(bEngage(deepAnesSearchIndex,4) < .3);
                 deepAnesMiddle = round(length(deepAnesIndex)/2);
                 %     deepAnesTime = trialTimes(deepAnesIndex(end)+deepAnesSearchIndex(1));
                 deepAnesTime = trialTimes(deepAnesIndex(deepAnesMiddle));
                 %     deepAnesTime = trialTimes(deepAnesIndex(end));
                 
                deepAnesTimeEnd = deepAnesTime+240;
                [ deepAnesTrialD, deepAnesTimesEnd] = min(abs(trialTimes-deepAnesTimeEnd));
                deepAnesTimeEnd = trialTimes(deepAnesTimesEnd);
                
                %finds the index in lfpDataIndex that corresponds to the window start%
                deepAnesTimeForLFP = deepAnesTime*1000;
                deepAnesTimeEndForLFP = deepAnesTimeEnd*1000;
                [ deepAnesDiff, deepAnesLfpDataIndex] = min(abs(lfpDataIndex-deepAnesTimeForLFP));
                [ deepAnesEndDiff, deepAnesEndLfpDataIndex] = min(abs(lfpDataIndex-deepAnesTimeEndForLFP));
                
                %creates single variable with epoch of interest%
                deepAnesLfpEpoch = targetData.LFP.data(deepAnesLfpDataIndex:deepAnesEndLfpDataIndex);
                
                 
                %roc epoch%
                rocSearchIndex = find(trialTimes > endAnesthesiaTime);
                rocIndex = find(bEngage(rocSearchIndex,4) > .3);
                if length(rocIndex)==0
                    rocTime = 0;
                else
                    rocTime = trialTimes(rocIndex(1)+rocSearchIndex(1));
                end
                %determines window after roc time is found %add 60 for one minute window%
                rocTimeEnd = rocTime+240;
                [ rocTrialD, rocTimesEnd] = min(abs(trialTimes-rocTimeEnd));
                rocTimeEnd = trialTimes(rocTimesEnd);
                
                %finds the index in lfpDataIndex that corresponds to the window start%
                rocTimeForLFP = rocTime*1000;
                rocTimeEndForLFP = rocTimeEnd*1000;
                [ rocDiff, rocLfpDataIndex] = min(abs(lfpDataIndex-rocTimeForLFP));
                [ rocEndDiff, rocEndLfpDataIndex] = min(abs(lfpDataIndex-rocTimeEndForLFP));
                
                %creates single variable with epoch of interest%
                rocLfpEpoch =targetData.LFP.data(rocLfpDataIndex:rocEndLfpDataIndex);
                                
                %ropap epoch%
                ropapSearchIndex = find(trialTimes > endAnesthesiaTime);
                ropapIndex = find(bPerform(ropapSearchIndex,4) > .9);
                if length(ropapIndex) > 0
                    ropapTime = trialTimes(ropapIndex(1)+ropapSearchIndex(1));
                end
                %determines window after roc time is found %add 60 for one minute window%
                ropapTimeEnd = ropapTime+240;
                [ ropapTrialD, ropapTimesEnd] = min(abs(trialTimes-ropapTimeEnd));
                ropapTimeEnd = trialTimes(ropapTimesEnd);
                
                %finds the index in lfpDataIndex that corresponds to the window start%
                ropapTimeForLFP = ropapTime*1000;
                ropapTimeEndForLFP = ropapTimeEnd*1000;
                [ ropapDiff, ropapLfpDataIndex] = min(abs(lfpDataIndex-ropapTimeForLFP));
                [ ropapEndDiff, ropapEndLfpDataIndex] = min(abs(lfpDataIndex-ropapTimeEndForLFP));
                
                %creates single variable with epoch of interest%
                ropapLfpEpoch = targetData.LFP.data(ropapLfpDataIndex:ropapEndLfpDataIndex);
    
                 %% COMPUTE MULTI-TAPER POWER SPECTRAL DENSITY DATA
                beta = [16 30];
                %awake data%
                params.tapers = [0.25 5];
                params.Fs = 1000;
                params.fpass = beta; %for peakfrequency stats change to desirable frequency, ex. for beat 14-40%
                movingwin = [10, 1];
                [awakeS, awakeT, awakeF] = mtspecgramc(targetData.LFP.data(awakeLfpDataIndex:awakeEndLfpDataIndex),movingwin, params);
                clear awakeDiff awakeEndDiff awakeIndex awakeLfpEpoch awakeSearchIndex awakeTime awakeTimeEnd awakeTimeEndForLFP awakeTimeForLFP awakeTimesEnd awakeTimesEndIndex aTrialD

                awakeS = 10*log10(awakeS);
                awakeCounter = awakeCounter + 1;
                awakeSMean = mean(awakeS, 1);
                awakeSMean = awakeSMean';
                awakeSpectralData = [awakeSpectralData awakeSMean];
                
                  % deep anesthesia data%
                params.tapers = [0.25 5];
                params.Fs = 1000;
                params.fpass = beta;
                movingwin = [10, 1];
                [deepAnesS, deepAnesT, deepAnesF] = mtspecgramc(targetData.LFP.data(deepAnesLfpDataIndex:deepAnesEndLfpDataIndex),movingwin, params);
                 clear deepAnesDiff deepAnesEndDiff deepAnesIndex deepAnesLfpEpoch deepAnesSearchIndex deepAnesTime deepAnesTimeEnd deepAnesTimeEndForLFP deepAnesTimeForLFP deepAnesTimesEnd deepAnesTimesEndIndex deepAnesTrialD
                deepAnesS = 10*log10(deepAnesS);
                deepAnesCounter = deepAnesCounter + 1;
                
                deepAnesSMean = mean(deepAnesS, 1);
                deepAnesSMean = deepAnesSMean';
                deepAnesSpectralData = [deepAnesSpectralData deepAnesSMean];
                               
                %roc data%
                params.tapers = [0.25 5];
                params.Fs = 1000;
                params.fpass = beta;
                movingwin = [10, 1];
                [rocS, rocT, rocF] = mtspecgramc(targetData.LFP.data(rocLfpDataIndex:rocEndLfpDataIndex),movingwin, params);
                clear rocDiff rocEndDiff rocIndex rocLfpEpoch rocSearchIndex rocTime rocTimeEnd rocTimeEndForLFP rocTimeForLFP rocTimesEnd rocTimesEndIndex rocTrialD
                rocS = 10*log10(rocS);        
                rocCounter = rocCounter + 1;
                
                rocSMean = mean(rocS, 1);
                rocSMean = rocSMean';
                rocSpectralData = [rocSpectralData rocSMean];
                
                %ropap data%
                params.tapers = [0.25 5];
                params.Fs = 1000;
                params.fpass = beta;
                movingwin = [10, 1];
                [ropapS, ropapT, ropapF] = mtspecgramc(targetData.LFP.data(ropapLfpDataIndex:ropapEndLfpDataIndex),movingwin, params);
                clear ropapDiff ropapEndDiff ropapIndex ropapLfpEpoch ropapSearchIndex ropapTime ropapTimeEnd ropapTimeEndForLFP ropapTimeForLFP ropapTimesEnd ropapTimesEndIndex ropapTrialD  
                ropapS = 10*log10(ropapS);               
                ropapCounter = ropapCounter + 1;
                
                ropapSMean = mean(ropapS, 1);
                ropapSMean = ropapSMean';
                ropapSpectralData = [ropapSpectralData ropapSMean];               
            end
        end
        
    save([saveDirectory, '\', session, structure], 'awakeSpectralData', 'rocSpectralData', 'ropapSpectralData', 'awakeF', 'rocF', 'ropapF','-v7.3');
    
    clear awakeS awakeCounter awakeSMean awakeSpectralData awakeT awakeF deepAnesS deepAnesCounter deepAnesSMean deepAnesSpectralData deepAnesT deepAnesF rocS rocCounter rocSMean rocSpectralData rocT rocF ropapS ropapCounter ropapSMean ropapSpectralData ropapT ropapF        
    
    end
end