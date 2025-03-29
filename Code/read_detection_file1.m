function meas = read_detection_file1(model, detectionFilePath)
    % 读取检测文件
    fileID = fopen(detectionFilePath, 'r');
    if fileID == -1
        error('无法打开文件: %s', detectionFilePath);
    end

    try
        % 初始化输出结构
        meas.Z = {}; % 使用cell数组存储每帧的测量值
        meas.clutter = {} ; 
        meas.P_D = {} ; 
        
        % 逐行读取文件内容
        tline = fgetl(fileID);
        while ischar(tline)
            % 分割行内容，第一项是帧号，后面的是量测字符串
            parts = strsplit(tline, ' ');
            frameNumber = str2double(parts{1});
            frameNumber = frameNumber + 1;
            
            % 确保frameNumber是正整数
            if ~isnumeric(frameNumber) || frameNumber <= 0 
                warning('无效的帧号: %s', parts{1});
                tline = fgetl(fileID);
                continue;
            end
            
            % 如果当前帧还没有初始化，则进行初始化
            if length(meas.Z) < frameNumber
                meas.Z(frameNumber) = {[]}; % 初始化为空cell
            end
            
            % 解析量测字符串
            measurements = strsplit(parts{2:end}, ';');
            for i = 1:length(measurements)
                if isempty(measurements{i}), continue; end
                xy = strsplit(measurements{i}, ',');
                if length(xy) >= 2
                    x = str2double(xy{1});
                    y = str2double(xy{2});
                    if isnan(x) || isnan(y)
                        warning('无效的测量值: %s', measurements{i});
                        continue;
                    end
                    % 将新的测量值添加到当前帧的测量列表中
                    meas.Z{frameNumber} = [meas.Z{frameNumber} [x;y]];
                    meas.clutter{frameNumber} = model.lambda_c ; 
                    meas.P_D{frameNumber} = model.P_D ; 
                end
            end
            %meas.Z{frameNumber} = meas.Z{frameNumber}.';
            
            tline = fgetl(fileID);
        end
        meas.Z = meas.Z.';
        
        % 设置K属性为总帧数
        meas.K = length(meas.Z);
        
    catch ME
        fclose(fileID);
        rethrow(ME);
    end
    
    fclose(fileID);
end