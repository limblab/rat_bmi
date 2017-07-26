function data_visual(an_data, data_ch, exclude_ch, data_range)

%if you want to see the raw data...
plot_raw_data = true;
%data_ch = [32:47];
%get indices of channels with good data
idx = find(ismember(an_data.channel, data_ch));
pl_idx = [13:16 12 11 9 10 5 6 8 7 3 4 1 2]; %this way you lay out the channels in the same grid as the array

%TODO: this is kind of messy, deal with it
if plot_raw_data
    figure;
    sep_fact = 10;
    xvals = [data_range]/an_data.freq(1);
    data_plot = an_data.data_vic(data_range, idx) + sep_fact*[1:size(an_data.data_vic(data_range, idx), 2)];
    plot(xvals, data_plot)
    xlabel('Seconds');
    xlim([0 xvals(end)]);
    ylabel('Channel');
    yticks(([1:length(data_ch)])*sep_fact);
    yticklabels(an_data.channel(:, idx));
    ylim([0 (length(data_ch)+1)*sep_fact]);
    set(gca, 'FontSize', 20);
end

% exclude_ch = [39:47]; %channels to exclude from common average calculation
[~, ~, ex_idx] = intersect(exclude_ch, an_data.channel);
ca_idx = setdiff(idx, ex_idx);


temp = an_data.data_vic(data_range,3:end);  % I think these are the good channels

%% subtract the common average, but scaled for each channel
mn = mean(temp,2);  % average signal across all channels
scales = mn\temp;  % this is the weighting of the mean to each channel
temp2 = temp - mn*scales;  % so subtract of the scaled mean for each channel
figure; 
data_plot = temp2 + sep_fact*[1:size(an_data.data_vic(data_range, idx), 2)];
plot(xvals, data_plot);

%% this does something pretty much the same, but using PCA
[coeff, score] = pca(temp);  % do PCA on the data
temp2pca = score(:,2:end)*coeff(:,2:end)';  % reconstruct the data leaving off the first component
figure; 
data_plot = temp2pca + sep_fact*[1:size(an_data.data_vic(data_range, idx), 2)];
plot(xvals, data_plot);


%% here's a quick wonky way of subtracting common average
common_av = mean(an_data.data_vic(data_range, ca_idx)');
new_data = (an_data.data_vic(data_range, idx)'-common_av)';
figure;
data_plot = new_data + sep_fact*[1:size(an_data.data_vic(data_range, idx), 2)];
plot(xvals, data_plot)
xlabel('Seconds');
xlim([xvals(1) xvals(end)]);
ylabel('Channel');
yticks(([1:length(data_ch)])*sep_fact);
yticklabels(an_data.channel(:, idx));
ylim([0 (length(data_ch)+1)*sep_fact]);
set(gca, 'FontSize', 20);
%TODO - add correct scaling for amplitude of LFPs
%yyaxis right;

%% Pablo's common averaging
% epiduralData  is a (#channels * time samples) matrix
epiduralData = an_data.data_vic(data_range, :)'; 
% CAR type 1 : each channel referenced with respect to all channels (including oneself)
% CAR type 2 : each channel referenced with respect to remaining channels (excluding oneself)
inc_channels = setdiff(1:16, exclude_ch)+2; 
%CAR 1 type
    CommonAverage = mean(epiduralData(inc_channels, :),1);
    CAR1 = epiduralData - CommonAverage;
    clear CommonAverage;

%CAR 2 type TODO fix
    exca = epiduralData(inc_channels, :); 
%     CommonAverage = mean(exca(2:end,:),1);
    for i = 1:size(epiduralData, 1) %Any clever way to avoid this for loop?
        ch_idx = find(ismember(inc_channels, i));
        if ~isempty(ch_idx)
            CommonAverage(i, :) = mean(exca([1:ch_idx-1 ch_idx+1:end],:),1);
        else 
            %no common average on other channels
            CommonAverage(i, :) = zeros(1, size(epiduralData, 2)); 
        end
    end
    CAR2 = epiduralData - CommonAverage;

%% Plot a bunch of things for a random (good) individual channel
ch = 4; 
xvals = data_range/1000; 
figure; set(gcf,'Name', 'Raw Channel 2');
plot(xvals, epiduralData(ch, :)); 
xlabel('Seconds'); ylabel('mV???'); 
set(gca, 'FontSize', 24); 
figure; set(gcf,'Name', 'CAR1 Channel 2');
plot(xvals, CAR1(ch, :)); 
figure; set(gcf,'Name', 'CAR2 Channel 2');
plot(xvals, CAR2(ch, :)); 

figure; set(gcf,'Name', 'Power Channel 2');
pwelch(epiduralData(ch, :), [], [], [], 1000); 
figure; set(gcf,'Name', 'All power Channel 2');
pwelch(an_data.data_vic(ch, :), [], [], [], 1000); 


%% spectrogram with and without common av subtracted
figure(10); set(gcf,'Name', 'Subtracted Common Avg');
set(gcf, 'Position', [15 100 1650 850]);
figure(11); set(gcf,'Name', 'Raw Data');
set(gcf, 'Position', [15 100 1650 850]);
for i=1:size(new_data, 2)
    figure(10);
    subplot(4, 4, pl_idx(i));
    spectrogram(new_data(:, i),'yaxis',50);
    title(['Channel ' num2str(an_data.channel(idx(i)))]);
    figure(11);
    subplot(4, 4, pl_idx(i));
    spectrogram(an_data.data_vic(data_range, idx(i)),'yaxis',50);
    title(['Channel ' num2str(an_data.channel(idx(i)))]);
end


%TODO: bandpass filter at diff freqs
