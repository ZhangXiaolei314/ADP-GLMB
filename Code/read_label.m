function meas = read_label(detectionFilePath)
    % 读取检测文件
    fileID = fopen(detectionFilePath, 'r');
    if fileID == -1
        error('无法打开文件: %s', detectionFilePath);
    end

    try
        % 初始化输出结构
        meas = []; % 使用cell数组存储每帧的测量值
        
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
            

            if length(meas) < frameNumber
                meas = [meas 0]; % 初始化为空cell
            end
            
            % 解析量测字符串
            measurements = parts(2:end-1);
            for i = 1:length(measurements)

                    tttp = strsplit(measurements{i}, ';');
                    y = str2double(tttp{2});

                if y == -1
                meas(frameNumber) = meas(frameNumber)+1;
                end
            end



            
            tline = fgetl(fileID);
        end
    catch ME
        fclose(fileID);
        rethrow(ME);
    end
    
    fclose(fileID);
end