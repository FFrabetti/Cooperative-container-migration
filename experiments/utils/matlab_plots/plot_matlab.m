clc;
clear all;
% latency_cm1 = dlmread('latency_exp_cm_2-08-2020.txt');
% latency_cm2 = dlmread('latency_exp_cm_2-09-2020.txt');
% latency_csm1 = dlmread('latency_exp_csm_2-07-2020.txt');
% latency_csm2 = dlmread('latency_exp_csm_2-09-2020.txt');
% latency_tm1 = dlmread('latency_exp_tm_2-09-2020.txt');
% latency_tm2 = dlmread('latency_tm_sl_int_2020-02-09_00-31-39.txt');
% latency_tsm1 = dlmread('latency_exp_tsm_2-08-2020.txt');
% latency_tsm2 = dlmread('latency_exp_tsm_2-09-2020.txt');
% 
% figure
% subplot(1,2,1)
% h1 = cdfplot(latency_tm1(:,2));
% hold on;
% h2 = cdfplot(latency_cm1(:,2));
% % h3 = cdfplot(latency_tsm1(:,2));
% % h4 = cdfplot(latency_csm1(:,2));
% 
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % set( h3, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% xlim([50 150]);
% grid minor;
% xlabel('Response Time (ms)');
% ylabel('CDF');
% title('Application Response Time CDF')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('Traditional SL','SLIM SL','Location','northwest');
% 
% % legend('Traditional SL','SLIM SL','Traditional SF','SLIM SF','Location','northwest');
% 
% subplot(1,2,2)
% % h1 = cdfplot(latency_tm1(:,2));
% % hold on;
% % h2 = cdfplot(latency_cm1(:,2));
% h3 = cdfplot(latency_tsm1(:,2));
% hold on;
% h4 = cdfplot(latency_csm1(:,2));
% hold off;
% 
% set( h3,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % set( h3, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% xlim([50 150]);
% grid minor;
% xlabel('Response Time (ms)');
% ylabel('CDF');
% title('Application Response Time CDF')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('Traditional SF','SLIM SF','Location','northwest');
% 
% 
migr_time_cm1 = dlmread('migr_time_exp_cm_2-08-2020.txt');
migr_time_cm2 = dlmread('migr_time_exp_cm_2-09-2020.txt');
migr_time_csm1 = dlmread('migr_time_exp_csm_2-07-2020.txt');
migr_time_csm2 = dlmread('migr_time_exp_csm_2-09-2020.txt');
migr_time_tm1 = dlmread('migr_time_exp_tm_2-09-2020.txt');
migr_time_tm2 = dlmread('migr_time_tm_sl_int_2020-02-09_00-31-39.txt');
migr_time_tsm1 = dlmread('migr_time_exp_tsm_2-08-2020.txt');
migr_time_tsm2 = dlmread('migr_time_exp_tsm_2-09-2020.txt');

figure
plot(1,1)
h1 = cdfplot(migr_time_tm1(:,2)./1000);
hold on;
h2 = cdfplot(migr_time_cm1(:,2)./1000);
% h3 = cdfplot(migr_time_tsm1(:,2)./1000);
% h4 = cdfplot(migr_time_csm1(:,2)./1000);
% hold off;
% 
set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% set( h3, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % xlim([50 150]);
grid minor;
xlabel('Migration Time (s)');
ylabel('CDF');
title('Migration Time CDF')
set(gca,'FontSize',20, 'FontWeight','bold');
legend('Traditional SL','SLIM SL','Location','northwest');

figure
plot(1,1)
% h1 = cdfplot(migr_time_tm1(:,2)./1000);
% h2 = cdfplot(migr_time_cm1(:,2)./1000);
h3 = cdfplot(migr_time_tsm2(:,2)/1000);
hold on;
h4 = cdfplot(migr_time_csm2(:,2)/1000);
set( h3,'LineStyle',':','LineWidth',3,'MarkerSize',5);
set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% set( h3, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % xlim([50 150]);
grid minor;
xlabel('Migration Time (s)');
ylabel('CDF');
title('Migration Time CDF')
set(gca,'FontSize',20, 'FontWeight','bold');
legend('Traditional SF','SLIM SF','Location','northwest');


load_cm1 = fopen('load_exp_cm_2-08-2020.txt','r');
load_cm1 = textscan(load_cm1,'%d %s %f %f %f %f %f %f %f %f %f');

load_cm2 = fopen('load_exp_cm_2-09-2020.txt','r');
load_cm2 = textscan(load_cm2,'%d %s %f %f %f %f %f %f %f %f %f');

load_csm1 = fopen('load_exp_csm_2-07-2020.txt','r');
load_csm1 = textscan(load_csm1,'%d %s %f %f %f %f %f %f %f %f %f');

load_csm2 = fopen('load_exp_csm_2-09-2020.txt','r');
load_csm2 = textscan(load_csm2,'%d %s %f %f %f %f %f %f %f %f %f');

load_tm1 = fopen('load_exp_tm_2-09-2020.txt','r');
load_tm1 = textscan(load_tm1,'%d %s %f %f %f %f %f %f %f %f %f');

load_tm2 = fopen('load_tm_sl_int_2020-02-09_00-31-39.txt','r');
load_tm2 = textscan(load_tm2,'%d %s %f %f %f %f %f %f %f %f %f');

load_tsm1 = fopen('load_exp_tsm_2-08-2020.txt','r');
load_tsm1 = textscan(load_tsm1,'%d %s %f %f %f %f %f %f %f %f %f');

load_tsm2 = fopen('load_exp_tsm_2-09-2020.txt','r');
load_tsm2 = textscan(load_tsm2,'%d %s %f %f %f %f %f %f %f %f %f');

traffic_cm1 = fopen('traffic_exp_cm_2-08-2020.txt','r');
traffic_cm1 = textscan(traffic_cm1,'%d %s %f %f %f');

traffic_cm2 = fopen('traffic_exp_cm_2-09-2020.txt','r');
traffic_cm2 = textscan(traffic_cm2,'%d %s %f %f %f');

traffic_csm1 = fopen('traffic_exp_csm_2-07-2020.txt','r');
traffic_csm1 = textscan(traffic_csm1,'%d %s %f %f %f');

traffic_csm2 = fopen('traffic_exp_csm_2-09-2020.txt','r');
traffic_csm2 = textscan(traffic_csm2,'%d %s %f %f %f');

traffic_tm1 = fopen('traffic_exp_tm_2-09-2020.txt','r');
traffic_tm1 = textscan(traffic_tm1,'%d %s %f %f %f');

traffic_tm2 = fopen('traffic_tm_sl_int_2020-02-09_00-31-39.txt','r');
traffic_tm2 = textscan(traffic_tm2,'%d %s %f %f %f');

traffic_tsm1 = fopen('traffic_exp_tsm_2-08-2020.txt','r');
traffic_tsm1 = textscan(traffic_tsm1,'%d %s %f %f %f');

traffic_tsm2 = fopen('traffic_exp_tsm_2-09-2020.txt','r');
traffic_tsm2 = textscan(traffic_tsm2,'%d %s %f %f %f');

%%Traffic In and Out
traffic_tm1_dst_in = traffic_tm1{5}(3:6:216);
traffic_tm1_dst_out = traffic_tm1{5}(4:6:216);
traffic_tm1_src_in = traffic_tm1{5}(5:6:216);
traffic_tm1_src_out = traffic_tm1{5}(6:6:216);

traffic_tsm1_dst_in = traffic_tsm1{5}(3:6:216);
traffic_tsm1_dst_out = traffic_tsm1{5}(4:6:216);
traffic_tsm1_src_in = traffic_tsm1{5}(5:6:216);
traffic_tsm1_src_out = traffic_tsm1{5}(6:6:216);

traffic_cm1_dst_in = traffic_cm1{5}(3:10:360);
traffic_cm1_dst_out = traffic_cm1{5}(4:10:360);
traffic_cm1_src_in = traffic_cm1{5}(9:10:360);
traffic_cm1_src_out = traffic_cm1{5}(10:10:360);

traffic_csm1_dst_in = traffic_csm1{5}(3:10:360);
traffic_csm1_dst_out = traffic_csm1{5}(4:10:360);
traffic_csm1_src_in = traffic_csm1{5}(9:10:360);
traffic_csm1_src_out = traffic_csm1{5}(10:10:360);

traffic_tm2_dst_in = traffic_tm2{5}(3:6:216);
traffic_tm2_dst_out = traffic_tm2{5}(4:6:216);
traffic_tm2_src_in = traffic_tm2{5}(5:6:216);
traffic_tm2_src_out = traffic_tm2{5}(6:6:216);

traffic_tsm2_dst_in = traffic_tsm2{5}(3:6:216);
traffic_tsm2_dst_out = traffic_tsm2{5}(4:6:216);
traffic_tsm2_src_in = traffic_tsm2{5}(5:6:216);
traffic_tsm2_src_out = traffic_tsm2{5}(6:6:216);

traffic_cm2_dst_in = traffic_cm2{5}(3:10:360);
traffic_cm2_dst_out = traffic_cm2{5}(4:10:360);
traffic_cm2_src_in = traffic_cm2{5}(9:10:360);
traffic_cm2_src_out = traffic_cm2{5}(10:10:360);

traffic_csm2_dst_in = traffic_csm2{5}(3:10:360);
traffic_csm2_dst_out = traffic_csm2{5}(4:10:360);
traffic_csm2_src_in = traffic_csm2{5}(9:10:360);
traffic_csm2_src_out = traffic_csm2{5}(10:10:360);



% %%Stateless traffic plots
% %Source high load
% %no delay, 1 ms, 5 ms
% traffic_out_sl_src_case1_4_7_10 = [traffic_tm2_src_out(1), traffic_cm2_src_out(1); traffic_tm2_src_out(4), traffic_cm2_src_out(4); traffic_tm2_src_out(7), traffic_cm2_src_out(7); traffic_tm2_src_out(10), traffic_cm2_src_out(10)];
% traffic_out_sl_src_case13_16_19_22 = [traffic_tm2_src_out(13), traffic_cm2_src_out(13); traffic_tm2_src_out(16), traffic_cm2_src_out(16); traffic_tm2_src_out(19), traffic_cm2_src_out(19); traffic_tm2_src_out(22), traffic_cm2_src_out(22)];
% traffic_out_sl_src_case25_28_31_34 = [traffic_tm2_src_out(25), traffic_cm2_src_out(25); traffic_tm2_src_out(28), traffic_cm2_src_out(28); traffic_tm2_src_out(31), traffic_cm2_src_out(31); traffic_tm2_src_out(34), traffic_cm2_src_out(34)];
% 
% figure
% subplot(1,3,1)
% bar(traffic_out_sl_src_case1_4_7_10);
% title('(a) No propagation delay','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. Throughput (KB/s) - Source (OUT)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.15 0.3 0.3 0.3];
% str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(1,3,2)
% bar(traffic_out_sl_src_case13_16_19_22);
% title('(b) 1ms propagation delay','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. Throughput (KB/s) - Source (OUT)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.45 0.3 0.3 0.3];
% str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(1,3,3)
% bar(traffic_out_sl_src_case25_28_31_34);
% title('(c) 5ms propagation delay','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. Throughput (KB/s) - Source (OUT)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.75 0.3 0.3 0.3];
% str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% %%stateful traffic plots
% %Source high load
% %no delay, 1 ms, 5 ms
% traffic_out_sf_src_case1_4_7_10 = [traffic_tsm2_src_out(1), traffic_csm2_src_out(1); traffic_tsm2_src_out(4), traffic_csm2_src_out(4); traffic_tsm2_src_out(7), traffic_csm2_src_out(7); traffic_tsm2_src_out(10), traffic_csm2_src_out(10)];
% traffic_out_sf_src_case13_16_19_22 = [traffic_tsm2_src_out(13), traffic_csm2_src_out(13); traffic_tsm2_src_out(16), traffic_csm2_src_out(16); traffic_tsm2_src_out(19), traffic_csm2_src_out(19); traffic_tsm2_src_out(22), traffic_csm2_src_out(22)];
% traffic_out_sf_src_case25_28_31_34 = [traffic_tsm2_src_out(25), traffic_csm2_src_out(25); traffic_tsm2_src_out(28), traffic_csm2_src_out(28); traffic_tsm2_src_out(31), traffic_csm2_src_out(31); traffic_tsm2_src_out(34), traffic_csm2_src_out(34)];
% 
% figure
% subplot(1,3,1)
% bar(traffic_out_sf_src_case1_4_7_10);
% title('(a) No propagation delay','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. Throughput (KB/s) - Source (OUT)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','SLIM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.15 0.3 0.3 0.3];
% str = {'Layer size=10MB','State change=10%','BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST',};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(1,3,2)
% bar(traffic_out_sf_src_case13_16_19_22);
% title('(b) 1ms propagation delay','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. Throughput (KB/s) - Source (OUT)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','SLIM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.45 0.3 0.3 0.3];
% str = {'Layer size=10MB','State change=10%','BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(1,3,3)
% bar(traffic_out_sf_src_case25_28_31_34);
% title('(c) 5ms propagation delay','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. Throughput (KB/s) - Source (OUT)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','SLIM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.75 0.3 0.3 0.3];
% str = {'Layer size=10MB','State change=10%','BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;

%%Load values
load_tm1_dst = load_tm1{8}(2:3:108);
load_cm1_dst = load_cm1{8}(2:3:180);
load_tm1_src = load_tm1{8}(3:3:108);
load_cm1_src = load_cm1{8}(5:6:180);

load_tsm1_dst = load_tsm1{8}(2:3:108);
load_csm1_dst = load_csm1{8}(2:3:180);
load_tsm1_src = load_tsm1{8}(3:3:108);
load_csm1_src = load_csm1{8}(5:6:180);

load_tm2_dst = load_tm2{8}(2:3:108);
load_cm2_dst = load_cm2{8}(2:3:180);
load_tm2_src = load_tm2{8}(3:3:108);
load_cm2_src = load_cm2{8}(5:6:180);

load_tsm2_dst = load_tsm2{8}(2:3:108);
load_csm2_dst = load_csm2{8}(2:3:180);
load_tsm2_src = load_tsm2{8}(3:3:108);
load_csm2_src = load_csm2{8}(5:6:180);


% %%Stateless load plots
% %Plotting for SRC and DST
% %For different load values
% load_src_case1_4_7_10 = [load_tm2_src(1), load_cm2_src(1); load_tm2_src(4), load_cm2_src(4); load_tm2_src(7), load_cm2_src(7); load_tm2_src(10), load_cm2_src(10)];
% load_src_case2_5_8_11 = [load_tm2_src(2), load_cm2_src(2); load_tm2_src(5), load_cm2_src(5); load_tm2_src(8), load_cm2_src(8); load_tm2_src(11), load_cm2_src(11)];
% load_src_case3_6_9_12 = [load_tm2_src(3), load_cm2_src(3); load_tm2_src(6), load_cm2_src(6); load_tm2_src(9), load_cm2_src(9); load_tm2_src(12), load_cm2_src(12)];
% 
% figure
% subplot(2,3,1)
% bar((100-load_src_case1_4_7_10)./100);
% title('(a) Load SRC>DST','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. SRC Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(2,3,2)
% bar((100-load_src_case2_5_8_11)./100);
% title('(b) Load SRC<DST','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. SRC Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% % dim = [0.45 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(2,3,3)
% bar((100-load_src_case3_6_9_12)./100);
% title('(c) Load SRC=DST','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. SRC Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% % dim = [0.75 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% load_dst_case1_4_7_10 = [load_tm2_dst(1), load_cm2_dst(1); load_tm2_dst(4), load_cm2_dst(4); load_tm2_dst(7), load_cm2_dst(7); load_tm2_dst(10), load_cm2_dst(10)];
% load_dst_case2_5_8_11 = [load_tm2_dst(2), load_cm2_dst(2); load_tm2_dst(5), load_cm2_dst(5); load_tm2_dst(8), load_cm2_dst(8); load_tm2_dst(11), load_cm2_dst(11)];
% load_dst_case3_6_9_12 = [load_tm2_dst(3), load_cm2_dst(3); load_tm2_dst(6), load_cm2_dst(6); load_tm2_dst(9), load_cm2_dst(9); load_tm2_dst(12), load_cm2_dst(12)];
% 
% subplot(2,3,4)
% bar((100-load_dst_case1_4_7_10)./100);
% title('(d) Load SRC>DST','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. DST Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','dst-DST=942','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(2,3,5)
% bar((100-load_dst_case2_5_8_11)./100);
% title('(e) Load SRC<DST','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. DST Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% % dim = [0.45 0.3 0.3 0.3];
% % str = {'BW (Mbps):','dst-DST=100','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(2,3,6)
% bar((100-load_dst_case3_6_9_12)./100);
% title('(f) Load SRC=DST','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. DST Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','SLIM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% % dim = [0.75 0.3 0.3 0.3];
% % str = {'BW (Mbps):','dst-DST=100','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;

%%Stateful load plots
%Plotting for SRC and DST
%For different load values
load_src_sf_case1_4_7_10 = [load_tsm2_src(1), load_csm2_src(1); load_tsm2_src(4), load_csm2_src(4); load_tsm2_src(7), load_csm2_src(7); load_tsm2_src(10), load_csm2_src(10)];
load_src_sf_case2_5_8_11 = [load_tsm2_src(2), load_csm2_src(2); load_tsm2_src(5), load_csm2_src(5); load_tsm2_src(8), load_csm2_src(8); load_tsm2_src(11), load_csm2_src(11)];
load_src_sf_case3_6_9_12 = [load_tsm2_src(3), load_csm2_src(3); load_tsm2_src(6), load_csm2_src(6); load_tsm2_src(9), load_csm2_src(9); load_tsm2_src(12), load_csm2_src(12)];

figure
subplot(2,3,1)
bar((100-load_src_sf_case1_4_7_10)./100);
title('(a) Load SRC>DST','FontSize',20, 'FontWeight','bold');
xlabel('Volume Size (MB)');
ylabel('Avg. SRC Load');
set(gca,'FontSize', 20, 'FontWeight','bold');
legend('TM-SF','SLIM-SF','Location','northwest');
set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.15 0.3 0.3 0.3];
% str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
grid minor;
subplot(2,3,2)
bar((100-load_src_sf_case2_5_8_11)./100);
title('(b) Load SRC<DST','FontSize',20, 'FontWeight','bold');
xlabel('Volume Size (MB)');
ylabel('Avg. SRC Load');
set(gca,'FontSize', 20, 'FontWeight','bold');
legend('TM-SF','SLIM-SF','Location','northwest');
set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.45 0.3 0.3 0.3];
% str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
grid minor;
subplot(2,3,3)
bar((100-load_src_sf_case3_6_9_12)./100);
title('(c) Load SRC=DST','FontSize',20, 'FontWeight','bold');
xlabel('Volume Size (MB)');
ylabel('Avg. SRC Load');
set(gca,'FontSize', 20, 'FontWeight','bold');
legend('TM-SF','SLIM-SF','Location','northwest');
set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.75 0.3 0.3 0.3];
% str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
grid minor;

load_dst_sf_case1_4_7_10 = [load_tsm2_dst(1), load_csm2_dst(1); load_tsm2_dst(4), load_csm2_dst(4); load_tsm2_dst(7), load_csm2_dst(7); load_tsm2_dst(10), load_csm2_dst(10)];
load_dst_sf_case2_5_8_11 = [load_tsm2_dst(2), load_csm2_dst(2); load_tsm2_dst(5), load_csm2_dst(5); load_tsm2_dst(8), load_csm2_dst(8); load_tsm2_dst(11), load_csm2_dst(11)];
load_dst_sf_case3_6_9_12 = [load_tsm2_dst(3), load_csm2_dst(3); load_tsm2_dst(6), load_csm2_dst(6); load_tsm2_dst(9), load_csm2_dst(9); load_tsm2_dst(12), load_csm2_dst(12)];

subplot(2,3,4)
bar((100-load_dst_sf_case1_4_7_10)./100);
title('(d) Load SRC>DST','FontSize',20, 'FontWeight','bold');
xlabel('Volume Size (MB)');
ylabel('Avg. DST Load');
set(gca,'FontSize', 20, 'FontWeight','bold');
legend('TM-SF','SLIM-SF','Location','northwest');
set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.15 0.3 0.3 0.3];
% str = {'BW (Mbps):','dst-DST=942','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
grid minor;
subplot(2,3,5)
bar((100-load_dst_sf_case2_5_8_11)./100);
title('(e) Load SRC<DST','FontSize',20, 'FontWeight','bold');
xlabel('Volume Size (MB)');
ylabel('Avg. DST Load');
set(gca,'FontSize', 20, 'FontWeight','bold');
legend('TM-SF','SLIM-SF','Location','northwest');
set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.45 0.3 0.3 0.3];
% str = {'BW (Mbps):','dst-DST=100','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
grid minor;
subplot(2,3,6)
bar((100-load_dst_sf_case3_6_9_12)./100);
title('(f) Load SRC=DST','FontSize',20, 'FontWeight','bold');
xlabel('Volume Size (MB)');
ylabel('Avg. DST Load');
set(gca,'FontSize', 20, 'FontWeight','bold');
legend('TM-SF','SLIM-SF','Location','northwest');
set(gca, 'XTickLabel', {'0.01' '1' '10' '100'})
% dim = [0.75 0.3 0.3 0.3];
% str = {'BW (Mbps):','dst-DST=100','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
grid minor;




