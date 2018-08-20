%% COMPUTING BEHAVIOR EPOCHS
clc; clear all; close all;

%% ADD PATH
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\Coherence'));
addpath(genpath('\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\Code\chronux_2_11'));

%% SET PARAMETERS
dataDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\lfpData\dataForBehaviorCalculation';
dataFiles = dir([dataDirectory, '/*.mat']);
saveDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Data\behaviorEpochData\';
%%
%Need to figure out how to take the first channel of each session and save
%it to a file and then use that to find find the behavior epochs for that
%session

%Or try to figure out how to only load and iterate through "uniqueSessions"
%== to dataFiles

%% ITERATE THROUGH SESSIONS
for j = 1:length(dataFiles)
    
    load([dataDirectory, '/', dataFiles(j).name]);
    
    %% CONSTRAIN LFP DATA TO TASK
    if j == 1
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
    
    % -- awake epoch%
    %finds time for awake behavior using bperform within trialTimes
    awakeSearchIndex = find(trialTimes < startAnesthesiaTime);
    awakeIndex = find((bPerform(awakeSearchIndex,4) > .99));
    awakeTime = trialTimes(awakeIndex(1)+awakeSearchIndex(1));
    %determines window after awake time is found %add 60 for one minute window%
    awakeTimeEnd = awakeTime+240;
    [ aTrialD, awakeTimesEnd] = min(abs(trialTimes-awakeTimeEnd));
    awakeTimeEnd = trialTimes(awakeTimesEnd);
    %finds the index in lfpDataIndex that corresponds to the window start%
    awakeTimeForLFP = awakeTime*1000;
    awakeTimeEndForLFP = awakeTimeEnd*1000;
    [ awakeDiff, awakeLfpDataIndex] = min(abs(lfpDataIndex-awakeTimeForLFP));
    [ awakeEndDiff, awakeEndLfpDataIndex] = min(abs(lfpDataIndex-awakeTimeEndForLFP));
    %creates single variable with LFP data at epoch of interest%
    awakeLfpEpoch = awakeLfpDataIndex:awakeEndLfpDataIndex;

    % -- deep anesthesia epoch %
    deepAnesSearchIndex = find(trialTimes < endAnesthesiaTime);
    deepAnesIndex = find(bEngage(deepAnesSearchIndex,4) < .3);
    % deepAnesTime = trialTimes(deepAnesIndex(end)+deepAnesSearchIndex(1));
    % deepAnesTime = trialTimes(deepAnesIndex(end));
    deepAnesMiddle = round(length(deepAnesIndex)/2);
    deepAnesTime = trialTimes(deepAnesIndex(deepAnesMiddle));
    deepAnesTimeEnd = deepAnesTime+240;
    [ deepAnesTrialD, deepAnesTimesEnd] = min(abs(trialTimes-deepAnesTimeEnd));
    deepAnesTimeEnd = trialTimes(deepAnesTimesEnd);
    %finds the index in lfpDataIndex that corresponds to the window start%
    deepAnesTimeForLFP = deepAnesTime*1000;
    deepAnesTimeEndForLFP = deepAnesTimeEnd*1000;
    [ deepAnesDiff, deepAnesLfpDataIndex] = min(abs(lfpDataIndex-deepAnesTimeForLFP));
    [ deepAnesEndDiff, deepAnesEndLfpDataIndex] = min(abs(lfpDataIndex-deepAnesTimeEndForLFP));
    %creates single variable with LFP data at epoch of interest%
    deepAnesLfpEpoch = deepAnesLfpDataIndex:deepAnesEndLfpDataIndex;
    
    % -- roc epoch%
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
    %creates single variable with LFP data at epoch of interest%
    rocLfpEpoch = rocLfpDataIndex:rocEndLfpDataIndex;

    % -- ropap epoch%
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
    %creates single variable with LFP data at epoch of interest%
    ropapLfpEpoch = ropapLfpDataIndex:ropapEndLfpDataIndex;
    
    save([saveDirectory, '\', dataFiles(j).name(1:7)], 'awakeLfpEpoch', 'deepAnesLfpEpoch','rocLfpEpoch', 'ropapLfpEpoch', '-v7.3');

clear firstTime lastTime timeAxis bEngage bPerform trialTimes trialErrors startAnesthesiaTrial startAnesthesiaTime endAnesthesiaTime endAnesthesiaTrial 
clear awakeDiff awakeEndDiff awakeIndex awakeLfpEpoch awakeSearchIndex awakeTime awakeTimeEnd awakeTimeEndForLFP awakeTimeForLFP awakeTimesEnd awakeTimesEndIndex aTrialD
clear deepAnesLfpEpoch deepAnesDiff deepAnesEndDiff deepAnesIndex deepAnesLfpEpoch deepAnesSearchIndex deepAnesTime deepAnesTimeEnd deepAnesTimeEndForLFP deepAnesTimeForLFP deepAnesTimesEnd deepAnesTimesEndIndex deepAnesTrialD
clear rocLfpEpoch rocDiff rocEndDiff rocIndex rocLfpEpoch rocSearchIndex rocTime rocTimeEnd rocTimeEndForLFP rocTimeForLFP rocTimesEnd rocTimesEndIndex rocTrialD
clear ropapLfpEpoch ropapDiff ropapEndDiff ropapIndex ropapLfpEpoch ropapSearchIndex ropapTime ropapTimeEnd ropapTimeEndForLFP ropapTimeForLFP ropapTimesEnd ropapTimesEndIndex ropapTrialD  

end

