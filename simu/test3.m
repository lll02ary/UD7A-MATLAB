%===============================
%     兩組實測資料疊圖比對
%===============================
clear; close all;

% ─── 字型預設 ─────────────────────────────
set(groot, ...
    'defaultAxesFontName','Times New Roman', ...
    'defaultAxesFontSize',14, ...
    'defaultTextFontName','Times New Roman', ...
    'defaultTextFontSize',14, ...
    'defaultLegendFontName','Times New Roman', ...
    'defaultLegendFontSize',12);

% --- 1. 讀取CSV資料 -------------------------------
ZC = readmatrix('ZC.CSV', 'NumHeaderLines', 3);
OC = readmatrix('OC.CSV', 'NumHeaderLines', 3);
ZL = readmatrix('Z_load.CSV', 'NumHeaderLines', 3);
PL = readmatrix('PHASE_load.CSV', 'NumHeaderLines', 3);

% --- 2. 提取資料欄位 ------------------------------
f1 = ZC(:,1);        % 頻率 (Hz)
Zmag1 = ZC(:,2);     % 第一組阻抗
Phase1 = OC(:,2);    % 第一組相位

f2 = ZL(:,1);        % 頻率 (Hz)
Zmag2 = ZL(:,2);     % 第二組阻抗
Phase2 = PL(:,2);    % 第二組相位

% --- 3. 繪圖：阻抗幅值比較 ------------------------
figure('Position',[100 100 1200 600]);

subplot(2,1,1);
plot(f1/1e3, Zmag1, 'b-', 'LineWidth',2); hold on;
plot(f2/1e3, Zmag2, 'r--', 'LineWidth',2);
grid on;
xlabel('Frequency (kHz)');
ylabel('|Z| (Ω)');
title('Impedance Magnitude Comparison');
legend('原始資料 ZC','補償後 Z\_load','Location','Best');

% --- 4. 繪圖：相位比較 ----------------------------
subplot(2,1,2);
plot(f1/1e3, Phase1, 'b-', 'LineWidth',2); hold on;
plot(f2/1e3, Phase2, 'r--', 'LineWidth',2);
grid on;
xlabel('Frequency (kHz)');
ylabel('Phase (°)');
title('Impedance Phase Comparison');
legend('原始資料 OC','補償後 PHASE\_load','Location','Best');

% --- 5. 儲存圖片 -----------------------------------
print(gcf, 'impedance_dual_compare', '-dpng', '-r300');
