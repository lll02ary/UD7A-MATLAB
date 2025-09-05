%======================
% 參照中山大學王振傑，以噴塗換能器模擬阻抗分析，波德圖
%======================
clear; close all;

% ─── 全域字型＆大小預設 ───────────────────────────
set(groot, ...
    'defaultAxesFontName','Times New Roman', ...
    'defaultAxesFontSize',14, ...
    'defaultTextFontName','Times New Roman', ...
    'defaultTextFontSize',14, ...
    'defaultLegendFontName','Times New Roman', ...
    'defaultLegendFontSize',12);

% --- 1. 參數定義 -----------------------------------
% 並聯模型 (parallel model)/串聯等效電路
C0 = 519.01e-12;      % F
C1 = 50.75e-12;      % F
L1 = 901.37e-3;     % H
R1 = 900.72;        % Ω

% --- 2. 頻率掃描範圍 --------------------------------
f   = linspace(20e3, 32e3, 1200);   % Hz
w   = 2*pi*f;                           % rad/s

% --- 3. 計算阻抗 ----------------------------------
% 並聯模型/串聯等效電路：C0 與 (R1 + jωL1 + 1/(jωC1)) 並聯
Z_branch = R1 + 1./(1i*w*C1) + 1i*w*L1;
Z_par    = ( Z_branch .* (1./(1i*w*C0)) ) ./ ( Z_branch + 1./(1i*w*C0) );

% --- 4. 畫圖 --------------------------------------
figure('Position',[100 100 1200 600]);

% (a) 幅值 (dB)
subplot(2,1,1);
plot(f/1e3, abs(Z_par), 'b-', 'LineWidth',2); hold on
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
grid on;
title('Diagram of Impedance (Magnitude)');

% (b) 相位 (deg)
subplot(2,1,2);
plot(f/1e3, angle(Z_par)*180/pi, 'b-', 'LineWidth',2); hold on
xlabel('Frequency (kHz)');
ylabel('Phase (°)');
grid on;
title('Diagram of Impedance (Phase)');

% --- 5. 儲存 Figure --------------------------------
hFig = gcf;   % 取得目前的 figure handle

% 1) 儲存為高解析度 PNG (300 dpi)
print(hFig, 'yi_transducer_diag', '-dpng', '-r300');