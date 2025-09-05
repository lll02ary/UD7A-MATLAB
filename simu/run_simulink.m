% run_transducer.m
% 先清除舊圖、舊參數
clear; close all;

% 全域字型＆大小預設
set(groot, ...
    'defaultAxesFontName','Times New Roman', ...
    'defaultAxesFontSize',20, ...
    'defaultTextFontName','Times New Roman', ...
    'defaultTextFontSize',20, ...
    'defaultLegendFontName','Times New Roman', ...
    'defaultLegendFontSize',12);

% 1. 開模型、設定 StopTime
simModel = 'simulink_transducer';
open_system(simModel);
set_param(simModel,'StopTime','10');

% 2. 指定 Impedance Measurement Block 路徑
impBlock = [simModel '/Impedance Measurement'];

% 3. 設定頻率座標為對數、範圍從 28kHz 到 30kHz
set_param(impBlock, 'FrequencyAxisScaling', 'logarithmic');
set_param(impBlock, 'FrequencyRange', '[28000 30000]');

% 4. Run 模擬
sim(simModel);

% 模擬結束後，圖就會自動用上面設定的 Times New Roman
