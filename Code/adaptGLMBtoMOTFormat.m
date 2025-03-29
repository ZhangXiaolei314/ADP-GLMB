function result = adaptGLMBtoMOTFormat(glmbEst)
% Adapt the GLMB filter estimates to the format required by evaluateMOT
% without directly depending on meas data for frame count.
% Initialize result structure based on the number of frames in est.X
numFrames = length(glmbEst.X); % Determine the number of frames from est.X
result = repmat(struct('trackerData', struct('idxTracks', [], 'target', [])), 1, numFrames);

% Loop over each frame
for k = 1:numFrames
    % Prepare idxTracks and targets for current frame
    idxTracks = [];
    targets = {};

    % If there are no estimates for this frame, continue to the next one
    if isempty(glmbEst.X{k})
        continue;
    end
 
    % Process each track in the current frame
    for bidx = 1:size(glmbEst.X{k}, 2)
        m = glmbEst.X{k}(:, bidx); % Extract the state vector for the current track
        
        % Create a target structure with bbox field. Assuming m contains:
        % [x_center, y_center, width, height] or similar representation.
        % Adjust the indices as necessary to match your state vector format.
        targetStruct = struct('bbox', [m(1), m(3)]);

        % Append to idxTracks and targets
        idxTracks = [idxTracks; bidx];
        targets{end+1} = targetStruct;
    end

    % Assign idxTracks and targets to the current frame's trackerData
    targets = targets.';
    result(k).trackerData.idxTracks = idxTracks;
    result(k).trackerData.target = targets;
end
end