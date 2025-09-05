%===============================
% 總阻抗模擬＆實測疊圖
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
w   = 2*pi*f;                      % rad/s

% --- 3. 計算總阻抗 Ztotal -------------------------
Zs     = R1 + 1j*w*L1 + 1./(1j*w*C1);
Zt     = ( (1./(1j*w*C0)) .* Zs ) ./ ( (1./(1j*w*C0)) + Zs );
Zb     = 1j*w*Lk2 + Zt;
ZA     = (1j*w*Lm .* Zb) ./ (1j*w*Lm + Zb);
Ztotal = 1j*w*Lk1 + ZA;

% --- 4. 讀取實測資料 --------------------------------
% Z_load.CSV: [freq_Hz, Z_meas_Ohm]
% PHASE_load.CSV: [freq_Hz, phase_meas_deg]
dataZ      = readmatrix('Z_load.CSV');
f_meas     = dataZ(:,1);
Z_meas     = dataZ(:,2);

dataP      = readmatrix('PHASE_load.CSV');
fP_meas    = dataP(:,1);
phi_meas   = dataP(:,2);

% --- 5. 繪製波德圖 & 疊上實測點 --------------------
figure('Position',[100 100 1200 600]);

% (a) 幅值 (線性 Ω)
ax1 = subplot(2,1,1);
plot(f/1e3, abs(Ztotal), 'b-', 'LineWidth',2); hold on;
plot(f_meas/1e3, Z_meas, 'r--','LineWidth',2);
grid on; hold off;
xlabel('Frequency (kHz)');
ylabel('|Z_{total}| (Ω)');
title('Diagram of Impedance (Magnitude)');
legend('Series(模擬)','Impedance analyzer(實際量測)','Location','Best');

% (b) 相位 (°)
ax2 = subplot(2,1,2);
plot(f/1e3, angle(Ztotal)*180/pi, 'b-', 'LineWidth',2); hold on;
plot(fP_meas/1e3, phi_meas, 'r--', 'LineWidth',2);
grid on; hold off;
xlabel('Frequency (kHz)');
ylabel('Phase (°)');
title('Diagram of Impedance (Phase)');
legend('Series(模擬)','Impedance analyzer(實際量測)','Location','Best');

% --- 6. 儲存 Figure --------------------------------
hFig = gcf;
print(hFig, 'bo_load_diag_anay', '-dpng', '-r300');
