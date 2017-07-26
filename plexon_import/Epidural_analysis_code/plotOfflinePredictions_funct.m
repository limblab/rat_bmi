
% Plot Wiener Decoder Results:

function plotOfflinePredictions_funct(an_data, originalData, data_dir, varargin)

kinData = originalData;
PredData = an_data.wiener_offlinePredictions;
vaf = an_data.wiener_offlinePredictions.mfxval.ave_vaf;

%% Plot offline predictions

numPredSignals = size(kinData,2);
 for i = 1:numPredSignals
    %Plot both Actual and Predicted signals
    figure; set(gcf, 'color', 'white');
    plot(an_data.timeframe,kinData(:,i),'k');
    hold on; plot(PredData.timeframe,PredData.preddatabin(:,i),'r');
    title(PredData.outnames{i});
    xlabel('Seconds(s)'); ylabel('mm');
    legend('Actual',['Predicted (vaf= ' num2str(vaf(i),3) ')']);
 end

 %% Bar plot vaf 
 
 plot_vaf = vaf; plot_vaf(vaf<0) = 0; 
 figure; bar(plot_vaf, 'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
 set(gca,'xtick',1:length(plot_vaf));
 set(gca, 'XTickLabel', PredData.outnames); xtickangle(90);
 set(gcf, 'color', 'white');
 ylabel('VAF');
 title('VAF of predicted kinematics')
 
 %% Plot individual markers:
 
 range = 600:800;
 marker = 25; % 13kneeX, 19heelX, 25toeX
 
 figure; set(gcf, 'color', 'white');
 plot(an_data.timeframe(range),kinData(range,marker),'k');
 hold on; plot(PredData.timeframe(range),PredData.preddatabin(range,marker),'r');
 title(PredData.outnames{marker});
 xlabel('Seconds(s)'); ylabel('mm'); xlim([range(1)*0.05 range(end)*0.05]);
 legend('Actual',['Predicted (vaf= ' num2str(vaf(marker),3) ')']);
 
 %% Save all figures
 % Uncomment to save all open figures into a PDF. REALLY SLOW!!
 
% resultsFolder = [data_dir 'Results\'];
% if exist(resultsFolder, 'dir') ~= 7 %If results folder doesn't exist:
%     mkdir (resultsFolder);
% end
% 
% % Get handles to all figures;
% figHandles = get(groot, 'Children');
% for i = 1:length(figHandles)
%     figureName {i} = [resultsFolder rat_name '_' num2str(i) '.pdf'];
%     saveas(figHandles(i), [resultsFolder rat_name '_' num2str(i)], 'png');
%     saveas(figHandles(i), figureName{i}, 'pdf');
% end
% 
% append_pdfs([resultsFolder rat_name '_OfflinePredictionsSummary.pdf'], figureName {:})
% 
% % Delete pdfs after having appended them:
% for i = 1:length(figureName)
%     delete(figureName {i});
% end
  
 
end