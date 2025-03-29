function truth = extract_truth(filepath)
% Read ground truth from a text file and generate the corresponding structure.
%
% Inputs:
%   filepath - string or character vector specifying the path to the text file.

% Initialize the truth structure
truth.K = 0; % To be determined by the number of frames in the file
truth.X = {}; % Ground truth for states of targets
truth.N = []; % Ground truth for number of targets per frame
truth.L = {}; % Ground truth for labels of targets (k,i)
truth.track_list = {}; % Absolute index target identities (plotting)
truth.total_tracks = 0; % Total number of appearing tracks

% Open the file for reading
fid = fopen(filepath, 'r');
if fid == -1
    error('Cannot open file: %s', filepath);
end

% Read the file line by line and process each line
while ~feof(fid)
    line = fgetl(fid);
    if isempty(line) || line(1) == '%' % Skip empty lines and comments
        continue;
    end
    
    % Split the line into frame number and target data
    delimiter = ' ';
    delimiterPos = find(line == delimiter, 1);
    if delimiterPos
    % 提取分割后的两部分
        part1 = line(1:delimiterPos-1);
        part2 = line(delimiterPos+1:end);
    end
    % 如果需要结果作为单元数组
    parts = {part1, part2};
   
    frameNumber = str2double(parts{1})+1;
    
    % Ensure the frame number is an integer
    if ~isinteger(frameNumber)
        %warning('Frame number is not an integer. Rounding to nearest integer.');
        frameNumber = round(frameNumber);
    end
    
    % Update the maximum frame number
    truth.K = max(truth.K, frameNumber);
    
    % Process target data
    targetData = strsplit(parts{2}, ' '); % Split target data by semicolon
    for i = 1:length(targetData)-1 % Ignore the last empty element after the final semicolon
        targetInfo = strsplit(targetData{i}, ';'); % Split target info by comma
        target_info = strsplit(targetInfo{1}, ',');
        xTruePos = str2double(target_info{1});
        yTruePos = str2double(target_info{2});
        targetLabel = str2double(targetInfo{2})+1;
        
        % Add the target state and label to the appropriate frame
        if i == 1
            truth.X{frameNumber} = [xTruePos; yTruePos];
            truth.L{frameNumber} = targetLabel;
            truth.track_list{frameNumber} = targetLabel;
            truth.N(frameNumber) = 1;
        else
            truth.X{frameNumber} = [truth.X{frameNumber}, [xTruePos; yTruePos]];
            truth.L{frameNumber} = [truth.L{frameNumber}; targetLabel];
            truth.N(frameNumber) = truth.N(frameNumber) + 1;
            if ~ismember(targetLabel, truth.track_list{frameNumber})
                truth.track_list{frameNumber} = [truth.track_list{frameNumber}, targetLabel];
            end
        end
        
    end
end
truth.N = truth.N.';
truth.X = truth.X.';
truth.track_list = truth.track_list.';
truth.L = truth.L.';

fclose(fid);

% % Initialize structures with correct sizes based on maximum frame number
% truth.X = cell(truth.K, 1);
% truth.L = cell(truth.K, 1);
% truth.track_list = cell(truth.K, 1);
% truth.N = zeros(truth.K, 1);

% Reprocess the collected data to ensure proper indexing
% for k = 1:truth.K
%     if ~isempty(truth.X{k})
%         % Ensure all cells are initialized
%         if length(truth.X{k}) ~= 2*numel(truth.L{k})
%             %warning('Mismatch between the number of positions and labels in frame %d.', k);
%         end
%     end
% end

% Calculate total number of distinct tracks
allLabels = vertcat(truth.L{:});
[~, ~, ic] = unique(allLabels, 'rows');
truth.total_tracks = numel(unique(ic));

% Resize N to match K if necessary
if length(truth.N) < truth.K
    truth.N = [truth.N; zeros(truth.K-length(truth.N), 1)];
end
end