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
C0 = 2.372e-9;      % F
C1 = 99.4e-12;      % F
L1 = 310.63e-3;     % H
R1 = 158.57;        % Ω

% 串聯模型 (series model)/並聯等效電路
Cs = 2.4714e-9;     % Fss
C2 = 588.866e-9;   % F
L2 = 503.5e-6;      % H
R2 = 32707;         % Ω

% --- 2. 頻率掃描範圍 --------------------------------
f   = linspace(28e3, 30e3, 2000);   % Hz
w   = 2*pi*f;                           % rad/s

% --- 3. 計算阻抗 ----------------------------------
% 並聯模型/串聯等效電路：C0 與 (R1 + jωL1 + 1/(jωC1)) 並聯
Z_branch = R1 + 1./(1i*w*C1) + 1i*w*L1;
Z_par    = ( Z_branch .* (1./(1i*w*C0)) ) ./ ( Z_branch + 1./(1i*w*C0) );

% 串聯模型/並聯等效電路：Cs串聯{(C2、L2、R2並聯)}
% 支路導納 Y_branch = 1/R1 + 1/(j w L1) + j w C1
% Y_branch = 1./R2 + 1./(1i*w*L2) + 1i*w*C2;
Y_branch = 1./[R1 + 1i*w*L1 + 1./(1i*w*C1)];
% 加上 C0 的導納，再取倒數
Y_ser = Y_branch + 1i*w*Cs;
Z_ser = 1 ./ Y_ser;

% --- 4. 畫圖 --------------------------------------
figure('Position',[100 100 1200 600]);

% (a) 幅值 (dB)
subplot(2,1,1);
plot(f/1e3, 20*log10(abs(Z_par)), 'b-', 'LineWidth',1.5); hold on
plot(f/1e3, 20*log10(abs(Z_ser)), 'g--','LineWidth',1.5);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
legend('Parallel','Series','Location','Best');
grid on;
title('Bode Diagram of Impedance');

% (b) 相位 (deg)
subplot(2,1,2);
plot(f/1e3, angle(Z_par)*180/pi, 'b-', 'LineWidth',1.5); hold on
plot(f/1e3, angle(Z_ser)*180/pi, 'g--','LineWidth',1.5);
xlabel('Frequency (kHz)');
ylabel('Phase (°)');
legend('Parallel','Series','Location','Best');
grid on;

% --- 5. 儲存 Figure --------------------------------
hFig = gcf;   % 取得目前的 figure handle

% 1) 儲存為高解析度 PNG (300 dpi)
print(hFig, 'zen_transducer_bode', '-dpng', '-r300');