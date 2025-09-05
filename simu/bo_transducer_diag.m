%======================
% 參照清華大學游翼，以換能器模擬阻抗分析，阻抗相位特性曲線
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
C0 = 2.822977e-9;      % F
C1 = 117.7164e-12;     % F
L1 = 379.2760e-3;      % H
R1 = 130.4947;         % Ω

% 串聯模型 (series model)/並聯等效電路
Cs = 2.9406934e-9;        % Fss
C2 = 73.74927e-9;      % F
L2 = 581.0732e-6;      % H
R2 = 39080;            % Ω

% --- 2. 頻率掃描範圍 --------------------------------
f = linspace(20e3, 32e3, 1200);  % Hz
w = 2*pi*f;                       % rad/s

% --- 3. 計算阻抗 ----------------------------------
% 並聯模型/串聯等效電路：C0 與 (R1 + jωL1 + 1/(jωC1)) 並聯
Z_branch = R1 + 1./(1i*w*C1) + 1i*w*L1;
Z_par    = ( Z_branch .* (1./(1i*w*C0)) ) ./ ( Z_branch + 1./(1i*w*C0) );

% 串聯模型/並聯等效電路：Cs 串聯 { (C2、L2、R2 並聯) }
Y_branch = 1./(R1 + 1i*w*L1 + 1./(1i*w*C1));
Y_ser    = Y_branch + 1i*w*Cs;
Z_ser    = 1 ./ Y_ser;

% --- 4. 找最大/最小點 -----------------------------
[pk_par_max, loc_par_max] = findpeaks(abs(Z_par), 'MinPeakDistance',50);
f_par_max   = f(loc_par_max);
phi_par_max = angle(Z_par(loc_par_max)) *180/pi;

[pk_par_min_neg, loc_par_min] = findpeaks(-abs(Z_par), 'MinPeakDistance',50);
pk_par_min  = -pk_par_min_neg;
f_par_min   = f(loc_par_min);
phi_par_min = angle(Z_par(loc_par_min)) *180/pi;

% --- 5. 畫圖（含標示 + 自訂 legend） -------------
figure('Position',[100 100 1200 600]);

% (a) 幅值 (Ω)
subplot(2,1,1);
h1 = plot(f/1e3, abs(Z_par),  'b-', 'LineWidth',2); hold on;
h2 = plot(f/1e3, abs(Z_ser),  'g--','LineWidth',2);
h3 = plot(f_par_max/1e3, pk_par_max, 'ro','MarkerSize',8,'LineWidth',2);
h4 = plot(f_par_min/1e3, pk_par_min, 'ks','MarkerSize',8,'LineWidth',2);
xlabel('Frequency (kHz)');
ylabel('Impedance magnitude (Ω)');
grid on;
title('Diagram of Impedance (Magnitude)');
legend([h1 h2 h3 h4], {'Series','Parallel','fp','fs'}, 'Location','Best');

% 在幅值子圖加文字（如需要）
amaxdx = 0.2; amaxdy = 3000;
for i = 1:length(f_par_max)
    text(f_par_max(i)/1e3 + amaxdx, pk_par_max(i) - amaxdy, ...
        sprintf('f= %.2fkHz\n φ= %.1f°', f_par_max(i)/1e3, phi_par_max(i)), ...
        'Color','r','FontSize',15, ...
        'HorizontalAlignment','left','VerticalAlignment','bottom');
end
amindx = 0.3; amindy = 2000;
for i = 1:length(f_par_min)
    text( ...
        f_par_min(i)/1e3 - amindx, pk_par_min(i) + amindy, ...
        sprintf('f= %.2fkHz\n φ= %.1f°', f_par_min(i)/1e3, phi_par_min(i)), ...
        'Color','k','FontSize',15, ...
        'HorizontalAlignment','center','VerticalAlignment','bottom');
end

% (b) 相位 (deg)
subplot(2,1,2);
h5 = plot(f/1e3, angle(Z_par)*180/pi, 'b-', 'LineWidth',2); hold on;
h6 = plot(f/1e3, angle(Z_ser)*180/pi, 'g--','LineWidth',2);
h7 = plot(f_par_max/1e3, phi_par_max, 'ro','MarkerSize',8,'LineWidth',2);
h8 = plot(f_par_min/1e3, phi_par_min, 'ks','MarkerSize',8,'LineWidth',2);
xlabel('Frequency (kHz)');
ylabel('Phase (°)');
grid on;
title('Diagram of Impedance (Phase)');
legend([h5 h6 h7 h8], {'Series','Parallel','fp','fs'}, 'Location','Best');

% 在相位子圖加文字
pmaxdx = 0.3;
for i = 1:length(f_par_max)
    text(f_par_max(i)/1e3 + pmaxdx, phi_par_max(i), ...
        sprintf('f= %.2fkHz\n \\phi= %.1f°', f_par_max(i)/1e3, phi_par_max(i)), ...
        'Color','r', ...
        'FontSize',15, ...
        'HorizontalAlignment','left', ...   % 水平靠右（文字在標記的左邊）
        'VerticalAlignment','middle');      % 垂直置中
end
pmindx = 0.3;
for i = 1:length(f_par_min)
    text(f_par_min(i)/1e3 - pmindx, phi_par_min(i), ...
        sprintf('f= %.2fkHz\n \\phi= %.1f°', f_par_min(i)/1e3, phi_par_min(i)), ...
        'Color','k', ...
        'FontSize',15, ...
        'HorizontalAlignment','right', ...   % 水平靠右（文字在標記的左邊）
        'VerticalAlignment','middle');      % 垂直置中
end

% --- 6. 儲存 Figure --------------------------------
hFig = gcf;
print(hFig, 'bo_transducer_diag', '-dpng', '-r300');
