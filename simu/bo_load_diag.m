%===============================
%===============================
clear; close all;

% ─── 全域字型 & 大小 預設 ───────────────────────────
set(groot, ...
    'defaultAxesFontName','Times New Roman', ...
    'defaultAxesFontSize',14, ...
    'defaultTextFontName','Times New Roman', ...
    'defaultTextFontSize',14, ...
    'defaultLegendFontName','Times New Roman', ...
    'defaultLegendFontSize',12);

% --- 1. 參數定義 ------------------------------------
Lk1 = 0.069e-3;      % H, 原邊漏感
Lk2 = 0.514e-3;      % H, 次邊漏感
Lm  = 1.032e-3;      % H, 磁化電感
R1  = 130.4947;      % Ω, 換能器等效電阻
L1  = 379.2760e-3;   % H, 換能器等效電感
C1  = 117.7164e-12;  % F, 換能器等效串聯電容
C0  = 2.822977e-9;   % F, 換能器平行電容

% --- 2. 頻率掃描範圍 --------------------------------
f   = linspace(20e3, 32e3, 1200);  % Hz
w   = 2*pi*f;                     % rad/s

% --- 3. 計算總阻抗 Ztotal -------------------------
% 3.1 換能器等效阻抗 Zt
Zs    = R1 + 1j*w*L1 + 1./(1j*w*C1);
Zt    = ( (1./(1j*w*C0)) .* Zs ) ./ ( (1./(1j*w*C0)) + Zs );

% 3.2 反射至原邊的支路阻抗 Zb
Zb    = 1j*w*Lk2 + Zt;

% 3.3 並聯磁化支路阻抗 ZA
ZA    = (1j*w*Lm .* Zb) ./ (1j*w*Lm + Zb);

% 3.4 加上原邊漏感 Lk1 得到總阻抗
Ztotal = 1j*w*Lk1 + ZA;

% --- 4. 繪製波德圖 --------------------------------
figure('Position',[100 100 1200 600]);

% (a) 幅值 (線性 Ω)
subplot(2,1,1);
plot(f/1e3, abs(Ztotal), 'LineWidth',1.5);
grid on; hold off;
xlabel('Frequency (kHz)');
ylabel('|Z_{total}| (Ω)');
title('Diagram of Impedance (Magnitude)');

% (b) 相位 (°)
subplot(2,1,2);
plot(f/1e3, angle(Ztotal)*180/pi, 'LineWidth',1.5);
grid on; hold off;
xlabel('Frequency (kHz)');
ylabel('Phase (°)');
title('Diagram of Impedance (Phase)');

% --- 5. 儲存 Figure --------------------------------
hFig = gcf;
print(hFig, 'bo_load_diag', '-dpng', '-r300');
