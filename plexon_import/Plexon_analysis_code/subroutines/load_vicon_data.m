function [vicondata] = load_vicon_data(date)

vicontrials = dir('*.system');

ratmarkers = {'hip_top';'hip_center';'hip_bottom';'knee';'heel';'foot';'toe';'shoulder';'elbow';'hand';'back'; 'tibia';'femur'};

for trialind = 1:length(vicontrials)
    
    if trialind <10
        filename = dir([date '0' num2str(trialind) '.csv']);
    else
        filename = dir([date num2str(trialind) '.csv']);
    end
    if ~isempty(filename)
        
        fid = fopen(filename.name);
        filestring  = textscan(fid,'%s', 'Delimiter',',','EmptyValue',NaN);
        filestrings = filestring{1};
        fclose all;
        
        fid = fopen(filename.name);
        data = dlmread(filename.name,',',5,0);
        data(data == 0) = NaN;
        fclose all;
        
        nummarkers = (length(data(1,:))-2)/3;
        trials(trialind).rat.markernames = [];
        trials(trialind).obstacle.markernames = [];
        trials(trialind).frames =  data(:,1);
        
        for markerind = 1:nummarkers
            
            name = filestrings{3*(markerind-1)+5};
            index = strfind(name,':');
            markername = [name(1:index(1)-1) '_' name(index(1)+1:end)];
            
            if ~isempty(strfind(markername,'treadmill'))
                for ind = 1:4
                    if ~isempty(strfind(markername,num2str(ind)))
                        treadmillx = data(:,3*(markerind-1)+3);
                        treadmilly = data(:,3*(markerind-1)+4);
                        treadmillz = data(:,3*(markerind-1)+5);
                        % figure;plot(treadmillx,'.')
                        trials(trialind).treadmill.markerpos(ind,1:3) = [mean(treadmillx(~isnan(treadmillx))) mean(treadmilly(~isnan(treadmilly))) mean(treadmillz(~isnan(treadmillz)))];
                    end
                end
            elseif ~isempty(strfind(markername,'rat'))
                for ind = 1:length(ratmarkers)
                    ratmarkername = ratmarkers{ind};
                    if ~isempty(strfind(markername,ratmarkername))
                        datamatrix = [(data(:,3*(markerind-1)+3)) (data(:,3*(markerind-1)+4)) (data(:,3*(markerind-1)+5))];
                        trials(trialind).rat.(ratmarkername) = datamatrix;
                        trials(trialind).rat.markernames{end+1} = ratmarkername;
                    end
                end
            elseif ~isempty(strfind(markername,'obstacle'))
                for ind = 1:4
                    if ~isempty(strfind(markername,num2str(ind)))
                        obstaclename = ['obstacle' num2str(ind)];
                        datamatrix = [(data(:,3*(markerind-1)+3)) (data(:,3*(markerind-1)+4)) (data(:,3*(markerind-1)+5))];
                        trials(trialind).obstacle.(obstaclename) = datamatrix;
                        trials(trialind).obstacle.markernames{end+1} = obstaclename;
                        %
                        %                     figure;
                        %                     subplot(1,1,1)
                        %                     plot(datamatrix(:,1))
                        %
                        %                     subplot(3,1,2)
                        %                     plot(datamatrix(:,2))
                        %
                        %                     subplot(3,1,3)
                        %                     plot(datamatrix(:,3))
                    end
                end
            end
        end
    end
      clear data treadmillmarkerpos
end

vicondata.trials = trials;

