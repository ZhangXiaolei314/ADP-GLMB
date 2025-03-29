% 步骤1：生成示例虚警数据（假设有三个高斯成分）
rng(0); % 设定随机种子以保证可重复性
mu1 = [200, 500]; sigma1 = [600 0; 0 900]; % 第一个高斯成分
mu2 = [70, 60]; sigma2 = [4 0; 0 4]; % 第二个高斯成分
mu3 = [100, 20]; sigma3 = [6 0; 0 6]; % 第三个高斯成分
data1 = mvnrnd(mu1, sigma1, 50); % 生成100个样本
% data2 = mvnrnd(mu2, sigma2, 2); % 生成150个样本
% data3 = mvnrnd(mu3, sigma3, 2); % 生成50个样本
false_alarms = [data1]; % 合并虚警数据
false_alarms = [219 432;461 705; 664 137; 747 477;429 636; 740 356; 411 682; ];
% false_alarms = [799 575;603 531;605 335;];
false_alarms = [ 823 886; 295 409; -351 39; 709 359; 687 123; 591 1389; 612 306; 714 495; 462 1031; 221 546; 333 856; 450 291; ];
% false_alarms = [ 401,429;  545,349;  419,665;  468,427;  551,674;  718,576;  405,665;  442,741;  841,437;  ];
% 步骤2：设置GMM成分数并拟合模型
K = 1; % 高斯成分数量，根据实际数据调整
gmm = fitgmdist(false_alarms, K, 'Replicates', 5); % 重复拟合5次以避免局部最优

% 步骤3：生成图像网格（假设图像尺寸为0-120像素）
x = 1:1024; y = 1:1024;
[xgrid, ygrid] = meshgrid(x, y);
X = [xgrid(:), ygrid(:)]; % 网格点坐标

% 步骤4：计算每个网格点的概率密度
prob = pdf(gmm, X); % 计算概率密度
prob_map = reshape(prob, size(xgrid)); % 转换为网格矩阵
prob_map_normalized = prob_map / sum(prob_map(:));

% 步骤5：可视化结果
figure;
surf(xgrid, ygrid, prob_map, 'EdgeColor', 'none');
title('虚警概率密度分布（多高斯模型）');
xlabel('X像素坐标'); ylabel('Y像素坐标'); zlabel('概率密度');
colorbar;

% 可选：叠加显示虚警样本点
hold on;
plot3(false_alarms(:,1), false_alarms(:,2), zeros(size(false_alarms,1),1), 'r.');
hold off;
view(2); % 俯视视角
