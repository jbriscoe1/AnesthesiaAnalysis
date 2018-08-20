clc; clear all; close all;

%% Input Files
dataDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Statistics\peakFrequency\Spectrum\S1';
dataFiles = dir([dataDirectory, '/*.mat']);

saveDirectory = '\\rfa01.research.partners.org\MGH-ISHIZAWA\Jessica\propofolAnalysis\Statistics\peakFrequency\Spectrum\S1';

%% Iterate Through Sessions
for i = 1:length(dataFiles)
    
    %% Load Data
    load([dataDirectory, '\', dataFiles(i).name]);
    
    %% Format Data Groups
    pFData = [awakeFreqList; rocFreqList; ropapFreqList];
    group = [repmat({'Awake'},length(awakeFreqList), 1);  repmat({'ROC'},length(rocFreqList), 1); repmat({'ROPAP'},length(ropapFreqList), 1)];
    tTestData = [saveDirectory, '\', dataFiles(i).name(1:4), 'SpectrumStats.xls'];
    
    %% Perform KW or ANOVA based on distribution
    if kstest(ropapFreqList) == 0; kstest(rocFreqList) == 0;
        %run ANOVA and tukey -- multiple comparisons test%
        disp('normally distributed, will run ANOVA');
        [anovaP,anovaTable, anovaStats] = anova1(pFData, group, 'off');
        xlswrite(tTestData, anovaP, 'ANOVA'); xlswrite(tTestData, anovaTable, 'ANOVA', 'A2'); xlswrite(tTestData, anovaStats.n, 'ANOVA', 'A7'); xlswrite(tTestData, anovaStats.means, 'ANOVA', 'A8'); xlswrite(tTestData, anovaStats.df, 'ANOVA', 'A9');
        [c,~,~,gnames] = multcompare(anovaStats);
        [gnames(c(:,1)), gnames(c(:,2)), num2cell(c(:,3:6))]
        xlswrite(tTestData, [gnames(c(:,1)), gnames(c(:,2)), num2cell(c(:,3:6))], 'ANOVA', 'A10');

    else
        %run KW and Dunn's
        disp('not normally distributed, will run KW');
        [kwP, kwTable, kwStats] = kruskalwallis(pFData, group, 'off');
        xlswrite(tTestData, kwP, 'KruskalWallis'); xlswrite(tTestData, kwTable, 'KruskalWallis', 'A2'); xlswrite(tTestData, kwStats.n, 'KruskalWallis', 'A7'); xlswrite(tTestData, kwStats.meanranks, 'KruskalWallis', 'A8'); xlswrite(tTestData, kwStats.sumt, 'KruskalWallis', 'A9');
        [c,~,~,gnames] = multcompare(kwStats,  'CType', 'dunn-sidak');
        [gnames(c(:,1)), gnames(c(:,2)), num2cell(c(:,3:6))];
        xlswrite(tTestData, [gnames(c(:,1)), gnames(c(:,2)), num2cell(c(:,3:6))], 'KruskalWallis', 'A10')    
                
        [ksH, ksP] = kstest(awakeFreqList);
        xlswrite(tTestData, ksP, 'KS')
    end
    
    %% Mean and Standard Error Calculation
    
    awakeMean = mean(awakeFreqList);
    awakeSEM = std(awakeFreqList)/sqrt(length(awakeFreqList));
    rocMean = mean(rocFreqList);
    rocSEM = std(rocFreqList)/sqrt(length(rocFreqList));
    ropapMean = mean(ropapFreqList);
    ropapSEM = std(ropapFreqList)/sqrt(length(ropapFreqList));
    
    if kstest(awakeFreqList) == 0
        xlswrite(tTestData, [awakeMean, awakeSEM, rocMean, rocSEM, ropapMean, ropapSEM], 'ANOVA', 'A14');
    else
        xlswrite(tTestData, [awakeMean, awakeSEM, rocMean, rocSEM, ropapMean, ropapSEM], 'KruskalWallis', 'A14');
    end
    
    %% plot peak frequency%
    %box plot%
    boxplotcolors = [1 0 0;0.5412 0.1686 0.8863;1 .5 0];
    figure
    ax = axes;
    boxplot(pFData, group, 'whisker', 2, 'Symbol','k+','labels', {'Awake', 'ROC', 'ROPAP'},'colors', boxplotcolors);
    hold on
    % ax.YLim = [14  35];
    title('Peak Frequency');
    xlabel('Behavior');
    ylabel('Frequency');
    set(gca, 'fontsize', 14);
    set(findobj(gca,'type','line'),'linew',1.5)
    % removeOutliers = findobj(gca,'tag','Outliers');
    % delete(removeOutliers)
    % print([saveDirectory, '\', dataFiles(i).name(1:7), 'PFBoxPlotNoOutliers'], '-djpeg', '-r1500');
    print([saveDirectory, '\', dataFiles(i).name(1:4), 'PFBoxPlot'], '-djpeg', '-r1500');
    
    
    %Jitter Plot%
    y = 5*ones(length(awakeFreqList),1)';
    yy = 7*ones(length(rocFreqList),1)';
    yyy = 9*ones(length(ropapFreqList),1)';
    figure
    scatter(y, awakeFreqList, 'r','filled','jitter', 'on', 'jitterAmount', 1);
    hold on
    scatter(yy,rocFreqList,  40, [0.5412 0.1686 0.8863],'filled', 'jitter', 'on', 'jitterAmount', 1);
    scatter(yyy, ropapFreqList,  40, [1 .5 0],'filled', 'jitter', 'on', 'jitterAmount', 1);
    set(gca, 'xlim', [4 10]);
    set(gca, 'xticklabel', {'','Awake','','ROC','','ROPAP'});
    set(gca, 'ylim', [0 40]);
    legend('\color{red} Awake','\color[rgb]{0.5412, 0.1686, 0.8863} ROC','\color[rgb]{1, .5, 0} ROPAP', 'Location','NorthEast');
    legend('boxoff');
    title('Peak Frequencies');
    ylabel('Peak Frequency'); xlabel('Behavior');
    set(gca, 'fontsize', 14);
    print([saveDirectory, '\', dataFiles(i).name(1:4), 'PFJitterPlot'], '-djpeg', '-r1500');
    
    clear tTestData awakeData rocData ropapData awakeS1PMMean awakeSEM rocS1PMMean rocSEM ropapS1PMMean ropapSEM anovaData anovaP anovaTable anovaStats
    
end