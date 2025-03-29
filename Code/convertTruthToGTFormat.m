function gt = convertTruthToGTFormat(truth)
% Convert the output of extract_truth to a format suitable for evaluateMOT

% Initialize the gt cell array with the correct number of frames
numFrames = truth.K;
gt = cell(numFrames, 1);

% Loop over each frame and populate the gt structure
for k = 1:numFrames
    if ~isempty(truth.X{k}) && ~isempty(truth.L{k})
        % Extract positions and labels for the current frame
        xTruePos = truth.X{k}(1, :);
        yTruePos = truth.X{k}(2, :);
        targetLabels = truth.L{k};

        % Create bounding boxes from position data (assuming point targets)
        % For simplicity, we assume each target is represented by a point,
        % and we create a small bounding box around it.
        % Adjust the size of the bounding box as necessary.
        %bboxSize = 3; % Example bounding box size
        bboxes = [targetLabels(:), ...
                  xTruePos(:) , ...
                  yTruePos(:) ];

        % Assign the bboxes to the current frame in gt
        gt{k} = bboxes;
    end
end
end