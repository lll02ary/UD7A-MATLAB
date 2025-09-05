%======================
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

% --- A. 讀取實測資料 ------------------------------
% Z.CSV 內含 [Frequency(Hz), |Z|(Ω)]
% PHASE.CSV 內含 [Frequency(Hz), Phase(°)]
meas_Z     = readmatrix('Z_transducer.CSV');
meas_phase = readmatrix('PHASE_transducer.CSV');
f_measZ    = meas_Z(:,1);
Z_meas     = meas_Z(:,2);
f_measP    = meas_phase(:,1);
phi_meas   = meas_phase(:,2);

% --- 1. 參數定義 -----------------------------------
%串聯等效電路 / 並聯模型
C0 = 2.822977e-9;      % F
C1 = 117.7164e-12;     % F
L1 = 379.2760e-3;      % H
R1 = 130.4947;         % Ω

%並聯等效電路 / 串聯模型
Cs = 2.9406934e-9;        % Fss
C2 = 73.74927e-9;      % F
L2 = 581.0732e-6;      % H
R2 = 39080;            % Ω

% --- 2. 頻率掃描範圍 --------------------------------
f = linspace(20e3, 32e3, 1200);  % Hz
w = 2*pi*f;                       % rad/s

% --- 3. 計算阻抗 ----------------------------------
Z_branch = R1 + 1./(1i*w*C1) + 1i*w*L1;
Z_par    = ( Z_branch .* (1./(1i*w*C0)) ) ./ ( Z_branch + 1./(1i*w*C0) );

Y_branch = 1./(R1 + 1i*w*L1 + 1./(1i*w*C1));
Y_ser    = Y_branch + 1i*w*Cs;
Z_ser    = 1 ./ Y_ser;

% --- 4. 找最大／最小點 -----------------------------
[pk_max, loc_max] = findpeaks(abs(Z_par), 'MinPeakDistance',50);
f_max   = f(loc_max);
phi_max = angle(Z_par(loc_max))*180/pi;

[pk_min_neg, loc_min] = findpeaks(-abs(Z_par), 'MinPeakDistance',50);
pk_min  = -pk_min_neg;
f_min   = f(loc_min);
phi_min = angle(Z_par(loc_min))*180/pi;

% --- 5. 畫圖（含實測點與自訂 legend） -------------
figure('Position',[100 100 1200 600]);

% (a) 幅值 (Ω)
subplot(2,1,1);
h1 = plot(f/1e3, abs(Z_par),  'b-', 'LineWidth',2); hold on;
h2 = plot(f/1e3, abs(Z_ser),  'g--','LineWidth',2);
h3 = plot(f_max/1e3, pk_max,   'ro','MarkerSize',8,'LineWidth',2);
h4 = plot(f_min/1e3, pk_min,   'ks','MarkerSize',8,'LineWidth',2);
h5 = plot(f_measZ/1e3, Z_meas, 'r--','LineWidth',1);

xlabel('Frequency (kHz)');
ylabel('|Z_{total}| (Ω)');
title('Diagram of Impedance (Magnitude)');
grid on;
legend([h1 h2 h3 h4 h5], ...
    {'Series(模擬)','Parallel(模擬)','fp','fs','Impedance analyzer(實際量測)'}, ...
    'Location','Best');

% 在幅值峰／谷處加註文字
dx_mag  = 0.1;                     % kHz 水平偏移
dy_magP = -max(pk_max)*0.2;        % 峰值文字垂直偏移
dy_magV = max(pk_max)*0.45;        % 谷值文字垂直偏移
for i = 1:length(f_max)
    text( ...
        f_max(i)/1e3+dx_mag+0.2, ...
        pk_max(i)+dy_magP, ...
        sprintf('fp=%.2f kHz\n|Z|=%.1f Ω', ...
                f_max(i)/1e3, pk_max(i)), ...
        'Color','r', 'FontName','Times New Roman', 'FontSize',20, ...
        'HorizontalAlignment','left', 'VerticalAlignment','bottom');
end
for i = 1:length(f_min)
    text( ...
        f_min(i)/1e3-dx_mag, ...
        pk_min(i)+dy_magV, ...
        sprintf('fs=%.2f kHz\n|Z|=%.1f Ω', ...
                f_min(i)/1e3, pk_min(i)), ...
        'Color','k', 'FontName','Times New Roman', 'FontSize',20, ...
        'HorizontalAlignment','right','VerticalAlignment','top');
end
hold off;

% (b) 相位 (°)
subplot(2,1,2);
h6 = plot(f/1e3, angle(Z_par)*180/pi, 'b-', 'LineWidth',2); hold on;
h7 = plot(f/1e3, angle(Z_ser)*180/pi, 'g--','LineWidth',2);
h8 = plot(f_max/1e3, phi_max,          'ro','MarkerSize',8,'LineWidth',2);
h9 = plot(f_min/1e3, phi_min,          'ks','MarkerSize',8,'LineWidth',2);
h10 = plot(f_measP/1e3, phi_meas,      'r--','LineWidth',1);

xlabel('Frequency (kHz)');
ylabel('Phase (°)');
title('Diagram of Impedance (Phase)');
grid on;
legend([h6 h7 h8 h9 h10], ...
    {'Series(模擬)','Parallel(模擬)','fp','fs','Impedance analyzer(實際量測)'}, ...
    'Location','Best');


% --- 6. 在相位峰／谷處加註文字 ----------------------

dx = 0.1;    % kHz
dy = 5;      % 度

for i = 1:length(f_max)
    text( ...
        f_max(i)/1e3 + dx, ...                    % x 偏右 dx
        phi_max(i) + dy, ...                      % y 偏上 dy
        sprintf('fp = %.2fkHz\nφ = %.1f°', ...         % 文字內容
               f_max(i)/1e3, phi_max(i)), ...
        'Color','r', ...
        'FontSize',20, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','bottom' ...
    );
end

for i = 1:length(f_min)
    text( ...
        f_min(i)/1e3 - dx, ...                    % x 偏左 dx
        phi_min(i) + dy, ...                      % y 偏上 dy
        sprintf('fs = %.2fkHz\nφ = %.1f°', ...
               f_min(i)/1e3, phi_min(i)), ...
        'Color','k', ...
        'FontSize',20, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','bottom' ...
    );
end



% --- 7. 儲存 Figure --------------------------------
hFig = gcf;
print(hFig, 'bo_transducer_diag_anay', '-dpng', '-r300');
