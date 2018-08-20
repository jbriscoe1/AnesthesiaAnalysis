%% Line Coherence Data Calculation

clc; clear all; close all;

%% ADD PATH
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\Coherence'));
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\chronux_2_11'));

%% SET PARAMETERS
dataDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\lfpData';
dataFiles = dir([dataDirectory, '/*.mat']);
behaviorDataDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\behaviorEpochData';
behaviorFiles = dir([behaviorDataDirectory, '/*.mat']);
saveDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\coherogramData\groupCoherenceData\16to40Hz\S1PM\';

%% ITERATE THROUGH SESSIONS
for i = 1:length(dataFiles)
    allSessions(i,1:7) = dataFiles(i).name(1:7);
end
uniqueSessions = unique(allSessions, 'rows');
source = 'S1';
reference = 'PM';

for j = 1:length(uniqueSessions)
    
    session = uniqueSessions(j,:);
    sourceFiles = selectFiles(dataFiles, mat2str(session), source);
    referenceFiles = selectFiles(dataFiles, mat2str(session), reference);
    disp(sprintf('Processing File: %s, %d/%d', session, j, length(uniqueSessions)));
    
    awakeCounter = 0;
    deepAnesCounter = 0;
    rocCounter = 0;
    ropapCounter = 0;
    
    awakeCoherenceData = [];
    deepAnesCoherenceData = [];
    rocCoherenceData = [];
    ropapCoherenceData = [];
    
     if ~isempty(sourceFiles) | (referenceFiles)
        for i = 1:length(sourceFiles)
            
            for ii = 1:length(referenceFiles)
                
                if isequal(i, ii)
                    continue
                end
                tic;
                
                %% LOAD DATA
                sourceData = load([dataDirectory, '/', dataFiles(sourceFiles(i)).name]);
                referenceData = load([dataDirectory, '/', dataFiles(referenceFiles(ii)).name]);
                behaviorData = load([behaviorDataDirectory, '\', behaviorFiles(j).name]);                           
                
                %% COMPUTE MULTI-TAPER COHEROGRAM
                params.tapers = [5 9];
                params.Fs = 1000;
                params.fpass = [16 40];
                params.pad = 0;
                movingwin = [200, 5];
                
                %awake coherence data%
                [awakeC, awakephi, awakeS12, awakeS1, awakeS2, awaket, awakef] = cohgramc((sourceData.targetData.LFP.data(behaviorData.awakeLfpEpoch)), (referenceData.targetData.LFP.data(behaviorData.awakeLfpEpoch)), movingwin, params);                
                awakeCMean = mean(awakeC, 1);
                awakeCMean = awakeCMean';
                awakeCoherenceData = [awakeCoherenceData awakeCMean];               
                awakeCounter = awakeCounter + 1;
                clear awakeLfpEpoch awakeC awakephi awakeS12 awakeS1 awakeS2 awaket awakeCMean

                % deep anesthesia data %
                [deepAnesC, deepAnesphi, deepAnesS12, deepAnesS1, deepAnesS2, deepAnest, deepAnesf] = cohgramc((sourceData.targetData.LFP.data(behaviorData.deepAnesLfpEpoch)), (referenceData.targetData.LFP.data(behaviorData.deepAnesLfpEpoch)),movingwin, params);
                deepAnesCMean = mean(deepAnesC, 1);
                deepAnesCMean = deepAnesCMean';
                deepAnesCoherenceData = [deepAnesCoherenceData deepAnesCMean];      
                deepAnesCounter = deepAnesCounter + 1;
                clear deepAnesC deepAnesphi deepAnesS12 deepAnesS1 deepAnesS2 deepAnest deepAnesCMean
            
                %roc coherence data%
                [rocC, rocphi, rocS12, rocS1, rocS2, roct, rocf] = cohgramc((sourceData.targetData.LFP.data(behaviorData.rocLfpEpoch)), (referenceData.targetData.LFP.data(behaviorData.rocLfpEpoch)), movingwin, params);
                rocCounter = rocCounter + 1;
                rocCMean = mean(rocC, 1);
                rocCMean = rocCMean';
                rocCoherenceData = [rocCoherenceData rocCMean];
                clear rocC rocphi rocS12 rocS1 rocS2 roct rocCMean
                
                %ropap coherence data%
                [ropapC, ropapphi, ropapS12, ropapS1, ropapS2, ropapt, ropapf] = cohgramc((sourceData.targetData.LFP.data(behaviorData.ropapLfpEpoch)), (referenceData.targetData.LFP.data(behaviorData.ropapLfpEpoch)), movingwin, params);
                ropapCMean = mean(ropapC, 1);
                ropapCMean = ropapCMean';
                ropapCoherenceData = [ropapCoherenceData ropapCMean];
                ropapCounter = ropapCounter + 1;
                clear ropapC ropapphi ropapS12 ropapS1 ropapS2 ropapt ropapCMean
                
            end
        end
    end
    
    fileNameCoherenceData = [session, '-', source, reference];
    save([saveDirectory, '\', fileNameCoherenceData], 'awakeCoherenceData', 'rocCoherenceData', 'ropapCoherenceData', 'awakef', 'rocf', 'ropapf', '-v7.3');
end


% 
% 
% figure;
% for i = 1:42; 
%     foo = awakeCoherenceData(:,i);
%     bar = smooth(awakeCoherenceData(:,i),500);
%     
%     subplot(2,1,1);
%     plot(awakef, foo); 
%     [a,b] = max(foo);
%     hold on;
%     plot(awakef(b), a, 'ro', 'linewidth', 2);
%     hold off;
%     
%     subplot(2,1,2);
%     plot(awakef, bar); 
%     leftIndex = find(awakef > 17);
%     rightIndex = find(awakef > 35);
%     [a,b] = max(bar(leftIndex(1):rightIndex(1)));
%     hold on;
%     plot(awakef(b), a, 'ro', 'linewidth', 2);
%     hold off;
%     
%     pause(2);
%     clf
% end


%                 %% CONSTRAIN LFP DATA TO TASK
%                 if i == 1
%                     fs = 1000;
%                     firstTime = sourceData.targetData.DataArray(1,1);
%                     lastTime = sourceData.targetData.DataArray(end,2);
%                     timeAxis = 1/1000:1/1000:length(sourceData.targetData.LFP.data)/1000;
%                     lfpDataIndex = find(timeAxis>=firstTime & timeAxis<=lastTime);
%                 end
%                 
%                 %% COMPUTE EPOCH DATA
%                 targetData = sourceData.targetData;
%                 bEngage = targetData.behaviorEstimateEngagement(2:end,:);
%                 bPerform = targetData.behaviorEstimatePerformance(2:end,:);
%                 
%                 trialTimes = targetData.DataArray(:,2);
%                 trialErrors = targetData.DataArray(:,4);
%                 
%                 startAnesthesiaTrial = targetData.Anesthesia.starttrial;
%                 startAnesthesiaTime = targetData.DataArray(startAnesthesiaTrial,1);
%                 endAnesthesiaTrial = targetData.Anesthesia.endtrial;
%                 endAnesthesiaTime = targetData.DataArray(endAnesthesiaTrial,1);
%                                 
%                 % -- awake epoch%
%                 %finds time for awake behavior using bperform within trialTimes
%                 awakeSearchIndex = find(trialTimes < startAnesthesiaTime);
%                 awakeIndex = find((bPerform(awakeSearchIndex,4) > .99));
%                 awakeTime = trialTimes(awakeIndex(1)+awakeSearchIndex(1));
%                 %determines window after awake time is found %add 60 for one minute window%
%                 awakeTimeEnd = awakeTime+240;
%                 [ aTrialD, awakeTimesEnd] = min(abs(trialTimes-awakeTimeEnd));
%                 awakeTimeEnd = trialTimes(awakeTimesEnd);
%                 
%                 %finds the index in lfpDataIndex that corresponds to the window start%
%                 awakeTimeForLFP = awakeTime*1000;
%                 awakeTimeEndForLFP = awakeTimeEnd*1000;
%                 [ awakeDiff, awakeLfpDataIndex] = min(abs(lfpDataIndex-awakeTimeForLFP));
%                 [ awakeEndDiff, awakeEndLfpDataIndex] = min(abs(lfpDataIndex-awakeTimeEndForLFP));
%                 
%                 %creates single variable with LFP data at epoch of interest%
%                 awakeLfpEpochSource = sourceData.targetData.LFP.data(awakeLfpDataIndex:awakeEndLfpDataIndex);
%                 awakeLfpEpochReference = referenceData.targetData.LFP.data(awakeLfpDataIndex:awakeEndLfpDataIndex);
%                 
%                  % -- deep anesthesia epoch %
%                 deepAnesSearchIndex = find(trialTimes < endAnesthesiaTime);
%                 deepAnesIndex = find(bEngage(deepAnesSearchIndex,4) < .3);
%                 % deepAnesTime = trialTimes(deepAnesIndex(end)+deepAnesSearchIndex(1));
%                 % deepAnesTime = trialTimes(deepAnesIndex(end));
%                 deepAnesMiddle = round(length(deepAnesIndex)/2);
%                 deepAnesTime = trialTimes(deepAnesIndex(deepAnesMiddle));
%                 
%                 deepAnesTimeEnd = deepAnesTime+240;
%                 [ deepAnesTrialD, deepAnesTimesEnd] = min(abs(trialTimes-deepAnesTimeEnd));
%                 deepAnesTimeEnd = trialTimes(deepAnesTimesEnd);
%                 
%                 %finds the index in lfpDataIndex that corresponds to the window start%
%                 deepAnesTimeForLFP = deepAnesTime*1000;
%                 deepAnesTimeEndForLFP = deepAnesTimeEnd*1000;
%                 [ deepAnesDiff, deepAnesLfpDataIndex] = min(abs(lfpDataIndex-deepAnesTimeForLFP));
%                 [ deepAnesEndDiff, deepAnesEndLfpDataIndex] = min(abs(lfpDataIndex-deepAnesTimeEndForLFP));
%                 
%                 %creates single variable with LFP data at epoch of interest%
%                 deepAnesLfpEpoch = targetData.LFP.data(deepAnesLfpDataIndex:deepAnesEndLfpDataIndex);
%                                 
%                 % -- roc epoch%
%                 rocSearchIndex = find(trialTimes > endAnesthesiaTime);
%                 rocIndex = find(bEngage(rocSearchIndex,4) > .3);
%                 if length(rocIndex)==0
%                     rocTime = 0;
%                 else
%                     rocTime = trialTimes(rocIndex(1)+rocSearchIndex(1));
%                 end
%                 %determines window after roc time is found %add 60 for one minute window%
%                 rocTimeEnd = rocTime+240;
%                 [ rocTrialD, rocTimesEnd] = min(abs(trialTimes-rocTimeEnd));
%                 rocTimeEnd = trialTimes(rocTimesEnd);
%                 
%                 %finds the index in lfpDataIndex that corresponds to the window start%
%                 rocTimeForLFP = rocTime*1000;
%                 rocTimeEndForLFP = rocTimeEnd*1000;
%                 [ rocDiff, rocLfpDataIndex] = min(abs(lfpDataIndex-rocTimeForLFP));
%                 [ rocEndDiff, rocEndLfpDataIndex] = min(abs(lfpDataIndex-rocTimeEndForLFP));
%                 
%                 %creates single variable with LFP data at epoch of interest%
%                 rocLfpEpoch = sourceData.targetData.LFP.data(rocLfpDataIndex:rocEndLfpDataIndex);
%                 
%                 % -- ropap epoch%
%                 ropapSearchIndex = find(trialTimes > endAnesthesiaTime);
%                 ropapIndex = find(bPerform(ropapSearchIndex,4) > .9);
%                 if length(ropapIndex) > 0
%                     ropapTime = trialTimes(ropapIndex(1)+ropapSearchIndex(1));
%                 end
%                 %determines window after roc time is found %add 60 for one minute window%
%                 ropapTimeEnd = ropapTime+240;
%                 [ ropapTrialD, ropapTimesEnd] = min(abs(trialTimes-ropapTimeEnd));
%                 ropapTimeEnd = trialTimes(ropapTimesEnd);
%                 
%                 %finds the index in lfpDataIndex that corresponds to the window start%
%                 ropapTimeForLFP = ropapTime*1000;
%                 ropapTimeEndForLFP = ropapTimeEnd*1000;
%                 [ ropapDiff, ropapLfpDataIndex] = min(abs(lfpDataIndex-ropapTimeForLFP));
%                 [ ropapEndDiff, ropapEndLfpDataIndex] = min(abs(lfpDataIndex-ropapTimeEndForLFP));
%                 
%                 %creates single variable with LFP data at epoch of interest%
%                 ropapLfpEpoch = sourceData.targetData.LFP.data(ropapLfpDataIndex:ropapEndLfpDataIndex);









