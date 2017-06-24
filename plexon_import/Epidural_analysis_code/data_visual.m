function data_visual(an_data, data_ch, exclude_ch, data_range)

%if you want to see the raw data...
plot_raw_data = true;
%data_ch = [32:47];
%get indices of channels with good data
idx = find(ismember(an_data.channel, data_ch));

%TODO: this is kind of messy, deal with it
if plot_raw_data
    sep_fact = 10;
    xvals = [1:size(an_data.data, 1)]/an_data.freq(1);
    data_plot = an_data.data(:, idx) + sep_fact*[1:size(an_data.data(:, idx), 2)];
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

%here's a quick wonky way of subtracting common average
common_av = mean(an_data.data(:, ca_idx)');
new_data = (an_data.data(:, idx)'-common_av)';
figure;
data_plot = new_data + sep_fact*[1:size(an_data.data(:, idx), 2)];
plot(xvals, data_plot)
xlabel('Seconds');
xlim([0 xvals(end)]); 
ylabel('Channel');
yticks(([1:length(data_ch)])*sep_fact);
yticklabels(an_data.channel(:, idx));
ylim([0 (length(data_ch)+1)*sep_fact]);
set(gca, 'FontSize', 20);
%TODO - add correct scaling for amplitude of LFPs
yyaxis right;

%TODO: spectrogram with and without common av subtracted
figure(10); set(gcf,'Name', 'Subtracted Common Avg'); 
set(gcf, 'Position', [15 100 1650 850]); 
figure(11); set(gcf,'Name', 'Raw Data');
set(gcf, 'Position', [15 100 1650 850]);
for i=1:size(new_data, 2)
    figure(10); 
    subplot(4, 4, i);
    spectrogram(new_data(data_range, i),'yaxis',50); 
    title(['Channel ' num2str(an_data.channel(idx(i)))]);
    figure(11); 
    subplot(4, 4, i); 
    spectrogram(an_data.data(data_range, idx(i)),'yaxis',50); 
    title(['Channel ' num2str(an_data.channel(idx(i)))]); 
end
 

%TODO: bandpass filter at diff freqs
