function ClearMOT = evaluateMOT(groundtruth, result, dist, dispON)

%% Comparison Functions
CompFunctionName = 'VOCscore';

%% Initialize metrics
idswitch = 0;
truepos = 0;
falseneg = 0;
falsepos = 0;
distances = 0;
totalGT = 0;
matchedFrames = zeros(1, max(cellfun(@(x) max(x(:, 1)), groundtruth, 'UniformOutput', true))); % Tracking each GT ID

%% Determine the number of frames to evaluate
numFrames = min(length(groundtruth), length(result));
prevMapping = [];

for i = 1:numFrames
    %% Extract data
    idxTracks = result(i).trackerData.idxTracks;
    target = result(i).trackerData.target;
    bboxes = groundtruth{i};

    %% Update total GT count
    totalGT = totalGT + size(bboxes, 1);

    %% Initialize distance matrix
    score = inf(size(bboxes, 1), length(idxTracks));

    %% Distance computation
    for b = 1:size(bboxes, 1)
        for l = 1:length(idxTracks)
            tt = idxTracks(l);
            distance = mydistance(bboxes(b, :), target(tt), CompFunctionName);
            score(b, l) = distance;
        end
    end

    %% Perform association using greedy matching
    Ass = GreedyAssociation(score, dist);

    %% Update counts and distances
    currentMapping = zeros(size(bboxes, 1), 2); % Current frame GT-to-tracker mapping
    for r = 1:numel(Ass)
        [b, l] = ind2sub(size(Ass), r);
        if Ass(b, l) == 1
            truepos = truepos + 1;
            distances = distances + score(b, l);
            currentMapping(b, :) = [bboxes(b, 1), idxTracks(l)];
        end
    end

    %% Update false negatives and false positives
    falseneg = falseneg + (size(bboxes, 1) - sum(currentMapping(:, 2) > 0));
    falsepos = falsepos + (length(idxTracks) - sum(currentMapping(:, 2) > 0));

    %% Calculate ID switches
    if ~isempty(prevMapping)
        for m = 1:size(currentMapping, 1)
            if currentMapping(m, 2) > 0
                prevIdx = find(prevMapping(:, 1) == currentMapping(m, 1));
                if ~isempty(prevIdx) && currentMapping(m, 2) ~= prevMapping(prevIdx, 2)
                    idswitch = idswitch + 1;
                end
            end
        end
    end

    %% Update matched frames
    for j = 1:size(currentMapping, 1)
        if currentMapping(j, 2) > 0
            matchedFrames(currentMapping(j, 1)) = matchedFrames(currentMapping(j, 1)) + 1;
        end
    end

    %% Save mapping for next frame
    prevMapping = currentMapping;
end

%% Calculate MT, PT, ML
MT = sum(matchedFrames > 0.8 * numFrames);
PT = sum(matchedFrames > 0.2 * numFrames & matchedFrames <= 0.8 * numFrames);
ML = sum(matchedFrames <= 0.2 * numFrames);

%% Calculate ID metrics
IDP = truepos / max((truepos + idswitch), 1);
IDR = truepos / max(totalGT, 1);
IDF1 = 2 * (IDP * IDR) / max((IDP + IDR), 1);

%% Calculate MOTA and MOTP
if truepos > 0
    MOTP = distances / truepos;
else
    MOTP = NaN;
end
MOTA = 1 - ((falseneg + falsepos + idswitch) / max(totalGT, 1));

%% Output metrics
ClearMOT.TP = truepos;
ClearMOT.FN = falseneg;
ClearMOT.FP = falsepos;
ClearMOT.IDSW = idswitch;
ClearMOT.MOTP = MOTP;
ClearMOT.MOTA = MOTA;
ClearMOT.IDF1 = IDF1;
ClearMOT.IDP = IDP;
ClearMOT.IDR = IDR;
ClearMOT.MT = MT;
ClearMOT.PT = PT;
ClearMOT.ML = ML;

%% Display results
if dispON
    disp('------ ::RESULTS:: ---------');
    disp(['IDF1 = ', num2str(IDF1)]);
    disp(['IDP = ', num2str(IDP)]);
    disp(['IDR = ', num2str(IDR)]);
    disp(['MOTP = ', num2str(ClearMOT.MOTP)]);
    disp(['MOTA = ', num2str(ClearMOT.MOTA)]);
    disp(['MT = ', num2str(MT)]);
    disp(['PT = ', num2str(PT)]);
    disp(['ML = ', num2str(ML)]);
    disp(['FP = ', num2str(falsepos)]);
    disp(['FN = ', num2str(falseneg)]);
    disp(['IDs = ', num2str(idswitch)]);
    disp('----------------------------');
end
end

function dist = mydistance(bboxesDetect, target, typeComp)
if strcmp('VOCscore', typeComp)
    xtlA = bboxesDetect(2);
    ytlA = bboxesDetect(3);
    xtlT = target{1,1}.bbox(1);
    ytlT = target{1,1}.bbox(2);
    dist = sqrt((xtlT - xtlA)^2 + (ytlT - ytlA)^2);
else
    dist = inf; % Default fallback
end
end