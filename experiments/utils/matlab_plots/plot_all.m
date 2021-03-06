clc;
clear all;

% %% Migration Time
% migr_time_tm1 = dlmread('migrtime_tm1.txt');
% migr_time_cm1 = dlmread('migrtime_cm1.txt');
% migr_time_tsm1 = dlmread('migrtime_tsm4.txt');
% migr_time_csm1 = dlmread('migrtime_csm4.txt');
% 
% %100KB, all cases
% migr_time_tm1_case1_13_25 = (migr_time_tm1(1,2) + migr_time_tm1(2,2) + migr_time_tm1(3,2) +  migr_time_tm1(13,2) + migr_time_tm1(14,2) + migr_time_tm1(15,2) + migr_time_tm1(25,2) + migr_time_tm1(26,2) + migr_time_tm1(27,2))/9; 
% migr_time_cm1_case1_13_25 = (migr_time_cm1(1,2) + migr_time_cm1(2,2) + migr_time_cm1(3,2) +  migr_time_cm1(13,2) + migr_time_cm1(14,2) + migr_time_cm1(15,2) + migr_time_cm1(25,2) + migr_time_cm1(26,2) + migr_time_cm1(27,2))/9; 
% migr_time_tsm1_case1_13_25 = (migr_time_tsm1(1,2) + migr_time_tsm1(2,2) + migr_time_tsm1(3,2) +  migr_time_tsm1(13,2) + migr_time_tsm1(14,2) + migr_time_tsm1(15,2) + migr_time_tsm1(25,2) + migr_time_tsm1(26,2) + migr_time_tsm1(27,2))/9; 
% migr_time_csm1_case1_13_25 = (migr_time_csm1(1,2) + migr_time_csm1(2,2) + migr_time_csm1(3,2) +  migr_time_csm1(13,2) + migr_time_csm1(14,2) + migr_time_csm1(15,2) + migr_time_csm1(25,2) + migr_time_csm1(26,2) + migr_time_csm1(27,2))/9; 
% 
% %1 MB, all cases
% migr_time_tm1_case4_16_28 = (migr_time_tm1(4,2) + migr_time_tm1(5,2) + migr_time_tm1(6,2) +  migr_time_tm1(16,2) + migr_time_tm1(17,2) + migr_time_tm1(18,2) + migr_time_tm1(28,2) + migr_time_tm1(29,2) + migr_time_tm1(30,2))/9; 
% migr_time_cm1_case4_16_28 = (migr_time_cm1(4,2) + migr_time_cm1(5,2) + migr_time_cm1(6,2) +  migr_time_cm1(16,2) + migr_time_cm1(17,2) + migr_time_cm1(18,2) + migr_time_cm1(28,2) + migr_time_cm1(29,2) + migr_time_cm1(30,2))/9; 
% migr_time_tsm1_case4_16_28 = (migr_time_tsm1(4,2) + migr_time_tsm1(5,2) + migr_time_tsm1(6,2) +  migr_time_tsm1(16,2) + migr_time_tsm1(17,2) + migr_time_tsm1(18,2) + migr_time_tsm1(28,2) + migr_time_tsm1(29,2) + migr_time_tsm1(30,2))/9; 
% migr_time_csm1_case4_16_28 = (migr_time_csm1(4,2) + migr_time_csm1(5,2) + migr_time_csm1(6,2) +  migr_time_csm1(16,2) + migr_time_csm1(17,2) + migr_time_csm1(18,2) + migr_time_csm1(28,2) + migr_time_csm1(29,2) + migr_time_csm1(30,2))/9; 
% 
% %10 MB, all cases
% migr_time_tm1_case7_19_31 = (migr_time_tm1(7,2) + migr_time_tm1(8,2) + migr_time_tm1(9,2) +  migr_time_tm1(19,2) + migr_time_tm1(20,2) + migr_time_tm1(21,2) + migr_time_tm1(31,2) + migr_time_tm1(32,2) + migr_time_tm1(33,2))/9; 
% migr_time_cm1_case7_19_31 = (migr_time_cm1(7,2) + migr_time_cm1(8,2) + migr_time_cm1(9,2) +  migr_time_cm1(19,2) + migr_time_cm1(20,2) + migr_time_cm1(21,2) + migr_time_cm1(31,2) + migr_time_cm1(32,2) + migr_time_cm1(33,2))/9; 
% migr_time_tsm1_case7_19_31 = (migr_time_tsm1(7,2) + migr_time_tsm1(8,2) + migr_time_tsm1(9,2) +  migr_time_tsm1(19,2) + migr_time_tsm1(20,2) + migr_time_tsm1(21,2) + migr_time_tsm1(31,2) + migr_time_tsm1(32,2) + migr_time_tsm1(33,2))/9; 
% migr_time_csm1_case7_19_31 = (migr_time_csm1(7,2) + migr_time_csm1(8,2) + migr_time_csm1(9,2) +  migr_time_csm1(19,2) + migr_time_csm1(20,2) + migr_time_csm1(21,2) + migr_time_csm1(31,2) + migr_time_csm1(32,2) + migr_time_csm1(33,2))/9; 
% 
% %100 MB, all cases
% migr_time_tm1_case10_22_34 = (migr_time_tm1(10,2) + migr_time_tm1(11,2) + migr_time_tm1(12,2) +  migr_time_tm1(22,2) + migr_time_tm1(23,2) + migr_time_tm1(24,2) + migr_time_tm1(34,2) + migr_time_tm1(35,2) + migr_time_tm1(36,2))/9; 
% migr_time_cm1_case10_22_34 = (migr_time_cm1(10,2) + migr_time_cm1(11,2) + migr_time_cm1(12,2) +  migr_time_cm1(22,2) + migr_time_cm1(23,2) + migr_time_cm1(24,2) + migr_time_cm1(34,2) + migr_time_cm1(35,2) + migr_time_cm1(36,2))/9; 
% migr_time_tsm1_case10_22_34 = (migr_time_tsm1(10,2) + migr_time_tsm1(11,2) + migr_time_tsm1(12,2) +  migr_time_tsm1(22,2) + migr_time_tsm1(23,2) + migr_time_tsm1(24,2) + migr_time_tsm1(34,2) + migr_time_tsm1(35,2) + migr_time_tsm1(36,2))/9; 
% migr_time_csm1_case10_22_34 = (migr_time_csm1(10,2) + migr_time_csm1(11,2) + migr_time_csm1(12,2) +  migr_time_csm1(22,2) + migr_time_csm1(23,2) + migr_time_csm1(24,2) + migr_time_csm1(34,2) + migr_time_csm1(35,2) + migr_time_csm1(36,2))/9; 
% 
% migr_time_sl = [migr_time_tm1_case1_13_25, migr_time_cm1_case1_13_25; migr_time_tm1_case4_16_28, migr_time_cm1_case4_16_28; migr_time_tm1_case7_19_31, migr_time_cm1_case7_19_31; migr_time_tm1_case10_22_34, migr_time_cm1_case10_22_34];
% migr_time_sf = [migr_time_tsm1_case1_13_25, migr_time_csm1_case1_13_25; migr_time_tsm1_case4_16_28, migr_time_csm1_case4_16_28; migr_time_tsm1_case7_19_31, migr_time_csm1_case7_19_31; migr_time_tsm1_case10_22_34, migr_time_csm1_case10_22_34];
% 
% figure;
% subplot(1,2,1)
% bar(migr_time_sl/1000);
% title('(a) Stateless Application','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Average Migraiton Time (s)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% %dim = [0.75 0.3 0.3 0.3];
% %str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% %annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% subplot(1,2,2)
% bar(migr_time_sf/1000);
% title('(a) Stateful Application','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Average Migraiton Time (s)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% %dim = [0.75 0.3 0.3 0.3];
% %str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% %annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% %Comparison plot for 100MB layer and src>dst and src<dst
% figure;
% h1 = cdfplot(migr_time_tm1(10:3:36,2)/1000); 
% hold on; 
% h2 = cdfplot(migr_time_cm1(10:3:36,2)/1000);
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % xlim([50 150]);
% grid minor;
% xlabel('Migration Time (s)');
% ylabel('CDF');
% title('Stateless, Layer Size=100MB, Load SRC>DST')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% 
% figure;
% h1 = cdfplot(migr_time_tm1(11:3:36,2)/1000); 
% hold on; 
% h2 = cdfplot(migr_time_cm1(11:3:36,2)/1000);
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % xlim([50 150]);
% grid minor;
% xlabel('Migration Time (s)');
% ylabel('CDF');
% title('Stateless, Layer Size=100MB, Load SRC<DST')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% 
% figure;
% h1 = cdfplot(migr_time_tsm1(10:3:36,2)/1000); 
% hold on; 
% h2 = cdfplot(migr_time_csm1(10:3:36,2)/1000);
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % xlim([50 150]);
% grid minor;
% xlabel('Migration Time (s)');
% ylabel('CDF');
% title('Stateful, Volume Size=100MB, Load SRC>DST')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% 
% figure;
% h1 = cdfplot(migr_time_tsm1(11:3:36,2)/1000); 
% hold on; 
% h2 = cdfplot(migr_time_csm1(11:3:36,2)/1000);
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % xlim([50 150]);
% grid minor;
% xlabel('Migration Time (s)');
% ylabel('CDF');
% title('Stateful, Volume Size=100MB, Load SRC<DST')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');

% 
% %% Load Plots
% load_tm1 = fopen('load_tm1.txt','r');
% load_tm1 = textscan(load_tm1,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_cm1 = fopen('load_cm1.txt','r');
% load_cm1 = textscan(load_cm1,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_tsm1 = fopen('load_tsm4.txt','r');
% load_tsm1 = textscan(load_tsm1,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_csm1 = fopen('load_csm4.txt','r');
% load_csm1 = textscan(load_csm1,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% %Load for different layer size
% % %Load values
% load_tm1_dst = load_tm1{8}(2:3:108);
% load_cm1_dst = load_cm1{8}(2:5:180);
% load_tm1_src = load_tm1{8}(3:3:108);
% load_cm1_src = load_cm1{8}(5:5:180);
% 
% load_tsm1_dst = load_tsm1{8}(2:3:108);
% load_csm1_dst = load_csm1{8}(2:5:180);
% load_tsm1_src = load_tsm1{8}(3:3:108);
% load_csm1_src = load_csm1{8}(5:5:180);
% 
% %Stateless load plots
% %Plotting for SRC and DST
% %For different load values
% load_src_case1_4_7_10 = [load_tm1_src(1), load_cm1_src(1); load_tm1_src(4), load_cm1_src(4); load_tm1_src(7), load_cm1_src(7); load_tm1_src(10), load_cm1_src(10)];
% load_src_case2_5_8_11 = [load_tm1_src(2), load_cm1_src(2); load_tm1_src(5), load_cm1_src(5); load_tm1_src(8), load_cm1_src(8); load_tm1_src(11), load_cm1_src(11)];
% load_src_case3_6_9_12 = [load_tm1_src(3), load_cm1_src(3); load_tm1_src(6), load_cm1_src(6); load_tm1_src(9), load_cm1_src(9); load_tm1_src(12), load_cm1_src(12)];
% 
% figure
% subplot(2,3,1)
% bar((100-load_src_case1_4_7_10)./100);
% title('(a) Load SRC>DST','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. SRC Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.75 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% load_dst_case1_4_7_10 = [load_tm1_dst(1), load_cm1_dst(1); load_tm1_dst(4), load_cm1_dst(4); load_tm1_dst(7), load_cm1_dst(7); load_tm1_dst(10), load_cm1_dst(10)];
% load_dst_case2_5_8_11 = [load_tm1_dst(2), load_cm1_dst(2); load_tm1_dst(5), load_cm1_dst(5); load_tm1_dst(8), load_cm1_dst(8); load_tm1_dst(11), load_cm1_dst(11)];
% load_dst_case3_6_9_12 = [load_tm1_dst(3), load_cm1_dst(3); load_tm1_dst(6), load_cm1_dst(6); load_tm1_dst(9), load_cm1_dst(9); load_tm1_dst(12), load_cm1_dst(12)];
% 
% subplot(2,3,4)
% bar((100-load_dst_case1_4_7_10)./100);
% title('(d) Load SRC>DST','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Avg. DST Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.75 0.3 0.3 0.3];
% % str = {'BW (Mbps):','dst-DST=100','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% %Stateful load plots
% %Plotting for SRC and DST
% % For different load values
% load_src_sf_case1_4_7_10 = [load_tsm1_src(1), load_csm1_src(1); load_tsm1_src(4), load_csm1_src(4); load_tsm1_src(7), load_csm1_src(7); load_tsm1_src(10), load_csm1_src(10)];
% load_src_sf_case2_5_8_11 = [load_tsm1_src(2), load_csm1_src(2); load_tsm1_src(5), load_csm1_src(5); load_tsm1_src(8), load_csm1_src(8); load_tsm1_src(11), load_csm1_src(11)];
% load_src_sf_case3_6_9_12 = [load_tsm1_src(3), load_csm1_src(3); load_tsm1_src(6), load_csm1_src(6); load_tsm1_src(9), load_csm1_src(9); load_tsm1_src(12), load_csm1_src(12)];
% 
% figure
% subplot(2,3,1)
% bar((100-load_src_sf_case1_4_7_10)./100);
% title('(a) Load SRC>DST','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. SRC Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(2,3,2)
% bar((100-load_src_sf_case2_5_8_11)./100);
% title('(b) Load SRC<DST','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. SRC Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.45 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(2,3,3)
% bar((100-load_src_sf_case3_6_9_12)./100);
% title('(c) Load SRC=DST','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. SRC Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.75 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% load_dst_sf_case1_4_7_10 = [load_tsm1_dst(1), load_csm1_dst(1); load_tsm1_dst(4), load_csm1_dst(4); load_tsm1_dst(7), load_csm1_dst(7); load_tsm1_dst(10), load_csm1_dst(10)];
% load_dst_sf_case2_5_8_11 = [load_tsm1_dst(2), load_csm1_dst(2); load_tsm1_dst(5), load_csm1_dst(5); load_tsm1_dst(8), load_csm1_dst(8); load_tsm1_dst(11), load_csm1_dst(11)];
% load_dst_sf_case3_6_9_12 = [load_tsm1_dst(3), load_csm1_dst(3); load_tsm1_dst(6), load_csm1_dst(6); load_tsm1_dst(9), load_csm1_dst(9); load_tsm1_dst(12), load_csm1_dst(12)];
% 
% subplot(2,3,4)
% bar((100-load_dst_sf_case1_4_7_10)./100);
% title('(d) Load SRC>DST','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. DST Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','dst-DST=942','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(2,3,5)
% bar((100-load_dst_sf_case2_5_8_11)./100);
% title('(e) Load SRC<DST','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. DST Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.45 0.3 0.3 0.3];
% % str = {'BW (Mbps):','dst-DST=100','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% subplot(2,3,6)
% bar((100-load_dst_sf_case3_6_9_12)./100);
% title('(f) Load SRC=DST','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Avg. DST Load');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.75 0.3 0.3 0.3];
% % str = {'BW (Mbps):','dst-DST=100','dst-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: dst>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;

%% Traffic Plots
traffic_tm1 = fopen('traffic_tm1.txt','r');
traffic_tm1 = textscan(traffic_tm1,'%d %s %f %f %f %f %f %f');

traffic_cm1 = fopen('traffic_cm1.txt','r');
traffic_cm1 = textscan(traffic_cm1,'%d %s %f %f %f %f %f %f');


traffic_tsm1 = fopen('traffic_tsm4.txt','r');
traffic_tsm1 = textscan(traffic_tsm1,'%d %s %f %f %f %f %f %f');

traffic_csm1 = fopen('traffic_csm4.txt','r');
traffic_csm1 = textscan(traffic_csm1,'%d %s %f %f %f %f %f %f');

% Traffic In and Out
traffic_tm1_dst_in = traffic_tm1{8}(3:6:216);
traffic_cm1_dst_in = traffic_cm1{8}(3:10:360);

traffic_tm1_src_out = traffic_tm1{8}(6:6:216);
traffic_cm1_src_out = traffic_cm1{8}(10:10:360);
traffic_cm1_n1_out = traffic_cm1{8}(6:10:360);
traffic_cm1_n2_out = traffic_cm1{8}(8:10:360);

traffic_cm1_out = (traffic_cm1_src_out + traffic_cm1_n1_out + traffic_cm1_n2_out)/3;

traffic_tsm1_dst_in = traffic_tsm1{8}(3:6:216);
traffic_csm1_dst_in = traffic_csm1{8}(3:10:360);

traffic_tsm1_src_out = traffic_tsm1{8}(6:6:216);
traffic_csm1_src_out = traffic_csm1{8}(10:10:360);
traffic_csm1_n1_out = traffic_csm1{8}(6:10:360);
traffic_csm1_n2_out = traffic_csm1{8}(8:10:360);

traffic_csm1_out = (traffic_csm1_src_out + traffic_csm1_n1_out + traffic_csm1_n2_out)/3;

%Stateless traffic plots
%no delay
traffic_tm1_dst_in_case1_2_3 = (traffic_tm1_dst_in(1) + traffic_tm1_dst_in(2) + traffic_tm1_dst_in(3))/3; 
traffic_tm1_dst_in_case4_5_6 = (traffic_tm1_dst_in(4) + traffic_tm1_dst_in(5) + traffic_tm1_dst_in(6))/3; 
traffic_tm1_dst_in_case7_8_9 = (traffic_tm1_dst_in(7) + traffic_tm1_dst_in(8) + traffic_tm1_dst_in(9))/3; 
traffic_tm1_dst_in_case10_11_12 = (traffic_tm1_dst_in(10) + traffic_tm1_dst_in(11) + traffic_tm1_dst_in(12))/3; 

traffic_cm1_dst_in_case1_2_3 = (traffic_cm1_dst_in(1) + traffic_cm1_dst_in(2) + traffic_cm1_dst_in(3))/3; 
traffic_cm1_dst_in_case4_5_6 = (traffic_cm1_dst_in(4) + traffic_cm1_dst_in(5) + traffic_cm1_dst_in(6))/3; 
traffic_cm1_dst_in_case7_8_9 = (traffic_cm1_dst_in(7) + traffic_cm1_dst_in(8) + traffic_cm1_dst_in(9))/3; 
traffic_cm1_dst_in_case10_11_12 = (traffic_cm1_dst_in(10) + traffic_cm1_dst_in(11) + traffic_cm1_dst_in(12))/3; 

traffic_in_sl = [traffic_tm1_dst_in_case1_2_3, traffic_cm1_dst_in_case1_2_3; traffic_tm1_dst_in_case4_5_6, traffic_cm1_dst_in_case4_5_6; traffic_tm1_dst_in_case7_8_9, traffic_cm1_dst_in_case7_8_9; traffic_tm1_dst_in_case10_11_12, traffic_cm1_dst_in_case10_11_12];

traffic_tm1_src_out_case1_2_3 = (traffic_tm1_src_out(1) + traffic_tm1_src_out(2) + traffic_tm1_src_out(3))/3; 
traffic_tm1_src_out_case4_5_6 = (traffic_tm1_src_out(4) + traffic_tm1_src_out(5) + traffic_tm1_src_out(6))/3; 
traffic_tm1_src_out_case7_8_9 = (traffic_tm1_src_out(7) + traffic_tm1_src_out(8) + traffic_tm1_src_out(9))/3; 
traffic_tm1_src_out_case10_11_12 = (traffic_tm1_src_out(10) + traffic_tm1_src_out(11) + traffic_tm1_src_out(12))/3; 

traffic_cm1_out_case1_2_3 = (traffic_cm1_out(1) + traffic_cm1_out(2) + traffic_cm1_out(3))/3; 
traffic_cm1_out_case4_5_6 = (traffic_cm1_out(4) + traffic_cm1_out(5) + traffic_cm1_out(6))/3; 
traffic_cm1_out_case7_8_9 = (traffic_cm1_out(7) + traffic_cm1_out(8) + traffic_cm1_out(9))/3; 
traffic_cm1_out_case10_11_12 = (traffic_cm1_out(10) + traffic_cm1_out(11) + traffic_cm1_out(12))/3; 

traffic_out_sl = [traffic_tm1_src_out_case1_2_3, traffic_cm1_out_case1_2_3; traffic_tm1_src_out_case4_5_6, traffic_cm1_out_case4_5_6; traffic_tm1_src_out_case7_8_9, traffic_cm1_out_case7_8_9; traffic_tm1_src_out_case10_11_12, traffic_cm1_out_case10_11_12];

% figure;
% subplot(1,2,1)
% bar(traffic_in_sl);
% title('(a) Traffic IN; Stateless Application','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Incoming traffic/channel (KB/s)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% subplot(1,2,2)
% bar(traffic_out_sl);
% title('(b) Traffic OUT; Stateless Application','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Outgoing traffic/channel (KB/s)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;


%Stateful traffic plots
%no delay
traffic_tsm1_dst_in_case1_2_3 = (traffic_tsm1_dst_in(1) + traffic_tsm1_dst_in(2) + traffic_tsm1_dst_in(3))/3; 
traffic_tsm1_dst_in_case4_5_6 = (traffic_tsm1_dst_in(4) + traffic_tsm1_dst_in(5) + traffic_tsm1_dst_in(6))/3; 
traffic_tsm1_dst_in_case7_8_9 = (traffic_tsm1_dst_in(7) + traffic_tsm1_dst_in(8) + traffic_tsm1_dst_in(9))/3; 
traffic_tsm1_dst_in_case10_11_12 = (traffic_tsm1_dst_in(10) + traffic_tsm1_dst_in(11) + traffic_tsm1_dst_in(12))/3; 

traffic_csm1_dst_in_case1_2_3 = (traffic_csm1_dst_in(1) + traffic_csm1_dst_in(2) + traffic_csm1_dst_in(3))/3; 
traffic_csm1_dst_in_case4_5_6 = (traffic_csm1_dst_in(4) + traffic_csm1_dst_in(5) + traffic_csm1_dst_in(6))/3; 
traffic_csm1_dst_in_case7_8_9 = (traffic_csm1_dst_in(7) + traffic_csm1_dst_in(8) + traffic_csm1_dst_in(9))/3; 
traffic_csm1_dst_in_case10_11_12 = (traffic_csm1_dst_in(10) + traffic_csm1_dst_in(11) + traffic_csm1_dst_in(12))/3; 

traffic_in_sf = [traffic_tsm1_dst_in_case1_2_3, traffic_csm1_dst_in_case1_2_3; traffic_tsm1_dst_in_case4_5_6, traffic_csm1_dst_in_case4_5_6; traffic_tsm1_dst_in_case7_8_9, traffic_csm1_dst_in_case7_8_9; traffic_tsm1_dst_in_case10_11_12, traffic_csm1_dst_in_case10_11_12];

traffic_tsm1_src_out_case1_2_3 = (traffic_tsm1_src_out(1) + traffic_tsm1_src_out(2) + traffic_tsm1_src_out(3))/3; 
traffic_tsm1_src_out_case4_5_6 = (traffic_tsm1_src_out(4) + traffic_tsm1_src_out(5) + traffic_tsm1_src_out(6))/3; 
traffic_tsm1_src_out_case7_8_9 = (traffic_tsm1_src_out(7) + traffic_tsm1_src_out(8) + traffic_tsm1_src_out(9))/3; 
traffic_tsm1_src_out_case10_11_12 = (traffic_tsm1_src_out(10) + traffic_tsm1_src_out(11) + traffic_tsm1_src_out(12))/3; 

traffic_csm1_out_case1_2_3 = (traffic_csm1_out(1) + traffic_csm1_out(2) + traffic_csm1_out(3))/3; 
traffic_csm1_out_case4_5_6 = (traffic_csm1_out(4) + traffic_csm1_out(5) + traffic_csm1_out(6))/3; 
traffic_csm1_out_case7_8_9 = (traffic_csm1_out(7) + traffic_csm1_out(8) + traffic_csm1_out(9))/3; 
traffic_csm1_out_case10_11_12 = (traffic_csm1_out(10) + traffic_csm1_out(11) + traffic_csm1_out(12))/3; 

traffic_out_sf = [traffic_tsm1_src_out_case1_2_3, traffic_csm1_out_case1_2_3; traffic_tsm1_src_out_case4_5_6, traffic_csm1_out_case4_5_6; traffic_tsm1_src_out_case7_8_9, traffic_csm1_out_case7_8_9; traffic_tsm1_src_out_case10_11_12, traffic_csm1_out_case10_11_12];

% figure;
% subplot(1,2,1)
% bar(traffic_in_sf./1000);
% title('(a) Traffic IN; Stateful Application','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Incoming traffic/channel (MB/s)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northeast');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% subplot(1,2,2)
% bar(traffic_out_sf./1000);
% title('(b) Traffic OUT; Stateful Application','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Outgoing traffic/channel (MB/s)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northeast');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% 
% Traffic Plots for per link traffic utilization
% % Use traffic out from src, node1 and node2
% % total traffic = src*num_link + node1 + node2
% traffic_tm1 = fopen('traffic_tm1.txt','r');
% traffic_tm1 = textscan(traffic_tm1,'%d %s %f %f %f %f %f %f');
% 
% traffic_cm1 = fopen('traffic_cm1.txt','r');
% traffic_cm1 = textscan(traffic_cm1,'%d %s %f %f %f %f %f %f');
% 
% 
% traffic_tsm1 = fopen('traffic_tsm4.txt','r');
% traffic_tsm1 = textscan(traffic_tsm1,'%d %s %f %f %f %f %f %f');
% 
% traffic_csm1 = fopen('traffic_csm4.txt','r');
% traffic_csm1 = textscan(traffic_csm1,'%d %s %f %f %f %f %f %f');
% 
% %%Traffic Out from all is equal to traffic in at dst
% %%Number of links between src and dst = 2 
% traffic_tm1_src_out = 2*traffic_tm1{7}(6:6:216);
% traffic_cm1_src_out = 2*traffic_cm1{7}(10:10:360);
% traffic_cm1_n1_out = traffic_cm1{7}(6:10:360);
% traffic_cm1_n2_out = traffic_cm1{7}(8:10:360);
%  
% traffic_cm1_out = (traffic_cm1_src_out + traffic_cm1_n1_out + traffic_cm1_n2_out);
%  
% %Stateless traffic plots
% %no delay
% traffic_tm1_dst_in_case1_2_3 = (traffic_tm1_src_out(1) + traffic_tm1_src_out(2) + traffic_tm1_src_out(3))/3; 
% traffic_tm1_dst_in_case4_5_6 = (traffic_tm1_src_out(4) + traffic_tm1_src_out(5) + traffic_tm1_src_out(6))/3; 
% traffic_tm1_dst_in_case7_8_9 = (traffic_tm1_src_out(7) + traffic_tm1_src_out(8) + traffic_tm1_src_out(9))/3; 
% traffic_tm1_dst_in_case10_11_12 = (traffic_tm1_src_out(10) + traffic_tm1_src_out(11) + traffic_tm1_src_out(12))/3; 
% 
% traffic_cm1_dst_in_case1_2_3 = (traffic_cm1_out(1) + traffic_cm1_out(2) + traffic_cm1_out(3))/3; 
% traffic_cm1_dst_in_case4_5_6 = (traffic_cm1_out(4) + traffic_cm1_out(5) + traffic_cm1_out(6))/3; 
% traffic_cm1_dst_in_case7_8_9 = (traffic_cm1_out(7) + traffic_cm1_out(8) + traffic_cm1_out(9))/3; 
% traffic_cm1_dst_in_case10_11_12 = (traffic_cm1_out(10) + traffic_cm1_out(11) + traffic_cm1_out(12))/3; 
% 
% traffic_in_sl = [traffic_tm1_dst_in_case1_2_3, traffic_cm1_dst_in_case1_2_3; traffic_tm1_dst_in_case4_5_6, traffic_cm1_dst_in_case4_5_6; traffic_tm1_dst_in_case7_8_9, traffic_cm1_dst_in_case7_8_9; traffic_tm1_dst_in_case10_11_12, traffic_cm1_dst_in_case10_11_12];
% 
% traffic_tsm1_src_out = 2*traffic_tsm1{7}(6:6:216);
% traffic_csm1_src_out = 2*traffic_csm1{7}(10:10:360);
% traffic_csm1_n1_out = traffic_csm1{7}(6:10:360);
% traffic_csm1_n2_out = traffic_csm1{7}(8:10:360);
%  
% traffic_csm1_out = (traffic_csm1_src_out + traffic_csm1_n1_out + traffic_csm1_n2_out);
% 
% %Stateless traffic plots
% %no delay
% traffic_tsm1_dst_in_case1_2_3 = (traffic_tsm1_src_out(1) + traffic_tsm1_src_out(2) + traffic_tsm1_src_out(3))/3; 
% traffic_tsm1_dst_in_case4_5_6 = (traffic_tsm1_src_out(4) + traffic_tsm1_src_out(5) + traffic_tsm1_src_out(6))/3; 
% traffic_tsm1_dst_in_case7_8_9 = (traffic_tsm1_src_out(7) + traffic_tsm1_src_out(8) + traffic_tsm1_src_out(9))/3; 
% traffic_tsm1_dst_in_case10_11_12 = (traffic_tsm1_src_out(10) + traffic_tsm1_src_out(11) + traffic_tsm1_src_out(12))/3; 
% 
% traffic_csm1_dst_in_case1_2_3 = (traffic_csm1_out(1) + traffic_csm1_out(2) + traffic_csm1_out(3))/3; 
% traffic_csm1_dst_in_case4_5_6 = (traffic_csm1_out(4) + traffic_csm1_out(5) + traffic_csm1_out(6))/3; 
% traffic_csm1_dst_in_case7_8_9 = (traffic_csm1_out(7) + traffic_csm1_out(8) + traffic_csm1_out(9))/3; 
% traffic_csm1_dst_in_case10_11_12 = (traffic_csm1_out(10) + traffic_csm1_out(11) + traffic_csm1_out(12))/3; 
% 
% traffic_in_sf = [traffic_tsm1_dst_in_case1_2_3, traffic_csm1_dst_in_case1_2_3; traffic_tsm1_dst_in_case4_5_6, traffic_csm1_dst_in_case4_5_6; traffic_tsm1_dst_in_case7_8_9, traffic_csm1_dst_in_case7_8_9; traffic_tsm1_dst_in_case10_11_12, traffic_csm1_dst_in_case10_11_12];

% figure;
% subplot(1,2,1)
% bar(traffic_in_sl./1000);
% title('(a) DST Traffic IN; Stateless Application','FontSize',20, 'FontWeight','bold');
% xlabel('Layer Size (MB)');
% ylabel('Total traffic/link (MB)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% subplot(1,2,2)
% bar(traffic_in_sf./1000);
% title('(b) DST Traffic IN; Stateful Application','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Total traffic/link (MB)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','southwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% %Stateful traffic plots
% %no delay
% traffic_tsm1_dst_in_case1_2_3 = (traffic_tsm1_dst_in(1) + traffic_tsm1_dst_in(2) + traffic_tsm1_dst_in(3))/3; 
% traffic_tsm1_dst_in_case4_5_6 = (traffic_tsm1_dst_in(4) + traffic_tsm1_dst_in(5) + traffic_tsm1_dst_in(6))/3; 
% traffic_tsm1_dst_in_case7_8_9 = (traffic_tsm1_dst_in(7) + traffic_tsm1_dst_in(8) + traffic_tsm1_dst_in(9))/3; 
% traffic_tsm1_dst_in_case10_11_12 = (traffic_tsm1_dst_in(10) + traffic_tsm1_dst_in(11) + traffic_tsm1_dst_in(12))/3; 
% 
% traffic_csm1_dst_in_case1_2_3 = (traffic_csm1_dst_in(1) + traffic_csm1_dst_in(2) + traffic_csm1_dst_in(3))/3; 
% traffic_csm1_dst_in_case4_5_6 = (traffic_csm1_dst_in(4) + traffic_csm1_dst_in(5) + traffic_csm1_dst_in(6))/3; 
% traffic_csm1_dst_in_case7_8_9 = (traffic_csm1_dst_in(7) + traffic_csm1_dst_in(8) + traffic_csm1_dst_in(9))/3; 
% traffic_csm1_dst_in_case10_11_12 = (traffic_csm1_dst_in(10) + traffic_csm1_dst_in(11) + traffic_csm1_dst_in(12))/3; 
% 
% traffic_in_sf = [traffic_tsm1_dst_in_case1_2_3, traffic_csm1_dst_in_case1_2_3; traffic_tsm1_dst_in_case4_5_6, traffic_csm1_dst_in_case4_5_6; traffic_tsm1_dst_in_case7_8_9, traffic_csm1_dst_in_case7_8_9; traffic_tsm1_dst_in_case10_11_12, traffic_csm1_dst_in_case10_11_12];
% 
% traffic_tsm1_src_out_case1_2_3 = (traffic_tsm1_src_out(1) + traffic_tsm1_src_out(2) + traffic_tsm1_src_out(3))/3; 
% traffic_tsm1_src_out_case4_5_6 = (traffic_tsm1_src_out(4) + traffic_tsm1_src_out(5) + traffic_tsm1_src_out(6))/3; 
% traffic_tsm1_src_out_case7_8_9 = (traffic_tsm1_src_out(7) + traffic_tsm1_src_out(8) + traffic_tsm1_src_out(9))/3; 
% traffic_tsm1_src_out_case10_11_12 = (traffic_tsm1_src_out(10) + traffic_tsm1_src_out(11) + traffic_tsm1_src_out(12))/3; 
% 
% traffic_csm1_out_case1_2_3 = (traffic_csm1_out(1) + traffic_csm1_out(2) + traffic_csm1_out(3))/3; 
% traffic_csm1_out_case4_5_6 = (traffic_csm1_out(4) + traffic_csm1_out(5) + traffic_csm1_out(6))/3; 
% traffic_csm1_out_case7_8_9 = (traffic_csm1_out(7) + traffic_csm1_out(8) + traffic_csm1_out(9))/3; 
% traffic_csm1_out_case10_11_12 = (traffic_csm1_out(10) + traffic_csm1_out(11) + traffic_csm1_out(12))/3; 
% 
% traffic_out_sf = [traffic_tsm1_src_out_case1_2_3, traffic_csm1_out_case1_2_3; traffic_tsm1_src_out_case4_5_6, traffic_csm1_out_case4_5_6; traffic_tsm1_src_out_case7_8_9, traffic_csm1_out_case7_8_9; traffic_tsm1_src_out_case10_11_12, traffic_csm1_out_case10_11_12];
% 
% figure;
% subplot(1,2,1)
% bar(traffic_in_sf./1000);
% title('(a) Traffic IN; Stateful Application','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Incoming traffic/channel (MB/s)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','southeast');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% subplot(1,2,2)
% bar(traffic_out_sf./1000);
% title('(b) Traffic OUT; Stateful Application','FontSize',20, 'FontWeight','bold');
% xlabel('Volume Size (MB)');
% ylabel('Outgoing traffic/channel (MB/s)');
% set(gca,'FontSize', 20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','southeast');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% % dim = [0.15 0.3 0.3 0.3];
% % str = {'BW (Mbps):','SRC-DST=942','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% % annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;


%% Latency Plots
 for k=1:36
    latency_tm_before{k}=dlmread(sprintf('tm1_latency/before_trafficgencl.log.%d.txt',k-1));
    latency_tm_after{k}=dlmread(sprintf('tm1_latency/after_trafficgencl.log.%d.txt',k-1));
    latency_cm_before{k}=dlmread(sprintf('cm1_latency/before_trafficgencl.log.%d.txt',k-1));
    latency_cm_after{k}=dlmread(sprintf('cm1_latency/after_trafficgencl.log.%d.txt',k-1));
    latency_tsm_before{k}=dlmread(sprintf('tsm1_latency/before_trafficgencl.log.%d.txt',k-1));
    latency_tsm_after{k}=dlmread(sprintf('tsm1_latency/after_trafficgencl.log.%d.txt',k-1));
    latency_csm_before{k}=dlmread(sprintf('csm1_latency/before_trafficgencl.log.%d.txt',k-1));
    latency_csm_after{k}=dlmread(sprintf('csm1_latency/after_trafficgencl.log.%d.txt',k-1));
 end

%Compare latency CDF for load src>dst
latency_tm_case25_28_31_34 = [latency_tm_before{25}(2:end,2)' latency_tm_before{28}(2:end,2)' latency_tm_before{31}(2:end,2)' latency_tm_before{34}(2:end,2)' latency_tm_after{25}(2:end,2)' latency_tm_after{28}(2:end,2)' latency_tm_after{31}(2:end,2)' latency_tm_after{34}(2:end,2)' ];
latency_cm_case25_28_31_34 = [latency_cm_before{25}(2:end,2)' latency_cm_before{28}(2:end,2)' latency_cm_before{31}(2:end,2)' latency_cm_before{34}(2:end,2)' latency_cm_after{25}(2:end,2)' latency_cm_after{28}(2:end,2)' latency_cm_after{31}(2:end,2)' latency_cm_after{34}(2:end,2)'];
latency_tsm_case25_28_31_34 = [latency_tsm_before{25}(2:end,2)' latency_tsm_before{28}(2:end,2)' latency_tsm_before{31}(2:end,2)' latency_tsm_before{34}(2:end,2)' latency_tsm_after{25}(2:end,2)' latency_tsm_after{28}(2:end,2)' latency_tsm_after{31}(2:end,2)' latency_tsm_after{34}(2:end,2)'];
latency_csm_case25_28_31_34 = [latency_csm_before{25}(2:end,2)' latency_csm_before{28}(2:end,2)' latency_csm_before{31}(2:end,2)' latency_csm_before{34}(2:end,2)' latency_csm_after{25}(2:end,2)' latency_csm_after{28}(2:end,2)' latency_csm_after{31}(2:end,2)' latency_csm_after{34}(2:end,2)'];

% figure;
% h1 = cdfplot(latency_tm_case25_28_31_34);
% hold on;
% h2 = cdfplot(latency_cm_case25_28_31_34);
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% grid minor;
% xlabel('Application Latency (ms)');
% ylabel('CDF');
% xlim([0 150]);
% title('Stateless Applicaiton; Load SRC > DST')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% 
% figure;
% h1 = cdfplot(latency_tsm_case25_28_31_34);
% hold on;
% h2 = cdfplot(latency_csm_case25_28_31_34);
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% grid minor;
% xlabel('Application Latency (ms)');
% ylabel('CDF');
% xlim([0 150]);
% title('Stateful Applicaiton; Load SRC > DST')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');

%Bar plot for average latency
latency_tm_100KB = [latency_tm_before{1}(2:end,2)' latency_tm_before{2}(2:end,2)' latency_tm_before{3}(2:end,2)' latency_tm_before{13}(2:end,2)' latency_tm_before{14}(2:end,2)' latency_tm_before{15}(2:end,2)' latency_tm_before{25}(2:end,2)' latency_tm_before{26}(2:end,2)' latency_tm_before{27}(2:end,2)' latency_tm_after{1}(2:end,2)' latency_tm_after{2}(2:end,2)' latency_tm_after{3}(2:end,2)' latency_tm_after{13}(2:end,2)' latency_tm_after{14}(2:end,2)' latency_tm_after{15}(2:end,2)' latency_tm_after{25}(2:end,2)' latency_tm_after{26}(2:end,2)' latency_tm_after{27}(2:end,2)'];
latency_cm_100KB = [latency_cm_before{1}(2:end,2)' latency_cm_before{2}(2:end,2)' latency_cm_before{3}(2:end,2)' latency_cm_before{13}(2:end,2)' latency_cm_before{14}(2:end,2)' latency_cm_before{15}(2:end,2)' latency_cm_before{25}(2:end,2)' latency_cm_before{26}(2:end,2)' latency_cm_before{27}(2:end,2)' latency_cm_after{1}(2:end,2)' latency_cm_after{2}(2:end,2)' latency_cm_after{3}(2:end,2)' latency_cm_after{13}(2:end,2)' latency_cm_after{14}(2:end,2)' latency_cm_after{15}(2:end,2)' latency_cm_after{25}(2:end,2)' latency_cm_after{26}(2:end,2)' latency_cm_after{27}(2:end,2)'];
latency_tsm_100KB = [latency_tsm_before{1}(2:end,2)' latency_tsm_before{2}(2:end,2)' latency_tsm_before{3}(2:end,2)' latency_tsm_before{13}(2:end,2)' latency_tsm_before{14}(2:end,2)' latency_tsm_before{15}(2:end,2)' latency_tsm_before{25}(2:end,2)' latency_tsm_before{26}(2:end,2)' latency_tsm_before{27}(2:end,2)' latency_tsm_after{1}(2:end,2)' latency_tsm_after{2}(2:end,2)' latency_tsm_after{3}(2:end,2)' latency_tsm_after{13}(2:end,2)' latency_tsm_after{14}(2:end,2)' latency_tsm_after{15}(2:end,2)' latency_tsm_after{25}(2:end,2)' latency_tsm_after{26}(2:end,2)' latency_tsm_after{27}(2:end,2)'];
latency_csm_100KB = [latency_csm_before{1}(2:end,2)' latency_csm_before{2}(2:end,2)' latency_csm_before{3}(2:end,2)' latency_csm_before{13}(2:end,2)' latency_csm_before{14}(2:end,2)' latency_csm_before{15}(2:end,2)' latency_csm_before{25}(2:end,2)' latency_csm_before{26}(2:end,2)' latency_csm_before{27}(2:end,2)' latency_csm_after{1}(2:end,2)' latency_csm_after{2}(2:end,2)' latency_csm_after{3}(2:end,2)' latency_csm_after{13}(2:end,2)' latency_csm_after{14}(2:end,2)' latency_csm_after{15}(2:end,2)' latency_csm_after{25}(2:end,2)' latency_csm_after{26}(2:end,2)' latency_csm_after{27}(2:end,2)'];

latency_tm_1MB = [latency_tm_before{4}(2:end,2)' latency_tm_before{5}(2:end,2)' latency_tm_before{6}(2:end,2)' latency_tm_before{16}(2:end,2)' latency_tm_before{17}(2:end,2)' latency_tm_before{18}(2:end,2)' latency_tm_before{28}(2:end,2)' latency_tm_before{29}(2:end,2)' latency_tm_before{30}(2:end,2)' latency_tm_after{4}(2:end,2)' latency_tm_after{5}(2:end,2)' latency_tm_after{6}(2:end,2)' latency_tm_after{16}(2:end,2)' latency_tm_after{17}(2:end,2)' latency_tm_after{18}(2:end,2)' latency_tm_after{28}(2:end,2)' latency_tm_after{29}(2:end,2)' latency_tm_after{30}(2:end,2)'];
latency_cm_1MB = [latency_cm_before{4}(2:end,2)' latency_cm_before{5}(2:end,2)' latency_cm_before{6}(2:end,2)' latency_cm_before{16}(2:end,2)' latency_cm_before{17}(2:end,2)' latency_cm_before{18}(2:end,2)' latency_cm_before{28}(2:end,2)' latency_cm_before{29}(2:end,2)' latency_cm_before{30}(2:end,2)' latency_cm_after{4}(2:end,2)' latency_cm_after{5}(2:end,2)' latency_cm_after{6}(2:end,2)' latency_cm_after{16}(2:end,2)' latency_cm_after{17}(2:end,2)' latency_cm_after{18}(2:end,2)' latency_cm_after{28}(2:end,2)' latency_cm_after{29}(2:end,2)' latency_cm_after{30}(2:end,2)'];
latency_tsm_1MB = [latency_tsm_before{4}(2:end,2)' latency_tsm_before{5}(2:end,2)' latency_tsm_before{6}(2:end,2)' latency_tsm_before{16}(2:end,2)' latency_tsm_before{17}(2:end,2)' latency_tsm_before{18}(2:end,2)' latency_tsm_before{28}(2:end,2)' latency_tsm_before{29}(2:end,2)' latency_tsm_before{30}(2:end,2)' latency_tsm_after{4}(2:end,2)' latency_tsm_after{5}(2:end,2)' latency_tsm_after{6}(2:end,2)' latency_tsm_after{16}(2:end,2)' latency_tsm_after{17}(2:end,2)' latency_tsm_after{18}(2:end,2)' latency_tsm_after{28}(2:end,2)' latency_tsm_after{29}(2:end,2)' latency_tsm_after{30}(2:end,2)'];
latency_csm_1MB = [latency_csm_before{4}(2:end,2)' latency_csm_before{5}(2:end,2)' latency_csm_before{6}(2:end,2)' latency_csm_before{16}(2:end,2)' latency_csm_before{17}(2:end,2)' latency_csm_before{18}(2:end,2)' latency_csm_before{28}(2:end,2)' latency_csm_before{29}(2:end,2)' latency_csm_before{30}(2:end,2)' latency_csm_after{4}(2:end,2)' latency_csm_after{5}(2:end,2)' latency_csm_after{6}(2:end,2)' latency_csm_after{16}(2:end,2)' latency_csm_after{17}(2:end,2)' latency_csm_after{18}(2:end,2)' latency_csm_after{28}(2:end,2)' latency_csm_after{29}(2:end,2)' latency_csm_after{30}(2:end,2)'];

latency_tm_10MB = [latency_tm_before{7}(2:end,2)' latency_tm_before{8}(2:end,2)' latency_tm_before{9}(2:end,2)' latency_tm_before{19}(2:end,2)' latency_tm_before{20}(2:end,2)' latency_tm_before{21}(2:end,2)' latency_tm_before{31}(2:end,2)' latency_tm_before{32}(2:end,2)' latency_tm_before{33}(2:end,2)' latency_tm_after{7}(2:end,2)' latency_tm_after{8}(2:end,2)' latency_tm_after{9}(2:end,2)' latency_tm_after{19}(2:end,2)' latency_tm_after{20}(2:end,2)' latency_tm_after{21}(2:end,2)' latency_tm_after{31}(2:end,2)' latency_tm_after{32}(2:end,2)' latency_tm_after{33}(2:end,2)'];
latency_cm_10MB = [latency_cm_before{7}(2:end,2)' latency_cm_before{8}(2:end,2)' latency_cm_before{9}(2:end,2)' latency_cm_before{19}(2:end,2)' latency_cm_before{20}(2:end,2)' latency_cm_before{21}(2:end,2)' latency_cm_before{31}(2:end,2)' latency_cm_before{32}(2:end,2)' latency_cm_before{33}(2:end,2)' latency_cm_after{7}(2:end,2)' latency_cm_after{8}(2:end,2)' latency_cm_after{9}(2:end,2)' latency_cm_after{19}(2:end,2)' latency_cm_after{20}(2:end,2)' latency_cm_after{21}(2:end,2)' latency_cm_after{31}(2:end,2)' latency_cm_after{32}(2:end,2)' latency_cm_after{33}(2:end,2)'];
latency_tsm_10MB = [latency_tsm_before{7}(2:end,2)' latency_tsm_before{8}(2:end,2)' latency_tsm_before{9}(2:end,2)' latency_tsm_before{19}(2:end,2)' latency_tsm_before{20}(2:end,2)' latency_tsm_before{21}(2:end,2)' latency_tsm_before{31}(2:end,2)' latency_tsm_before{32}(2:end,2)' latency_tsm_before{33}(2:end,2)' latency_tsm_after{7}(2:end,2)' latency_tsm_after{8}(2:end,2)' latency_tsm_after{9}(2:end,2)' latency_tsm_after{19}(2:end,2)' latency_tsm_after{20}(2:end,2)' latency_tsm_after{21}(2:end,2)' latency_tsm_after{31}(2:end,2)' latency_tsm_after{32}(2:end,2)' latency_tsm_after{33}(2:end,2)'];
latency_csm_10MB = [latency_csm_before{7}(2:end,2)' latency_csm_before{8}(2:end,2)' latency_csm_before{9}(2:end,2)' latency_csm_before{19}(2:end,2)' latency_csm_before{20}(2:end,2)' latency_csm_before{21}(2:end,2)' latency_csm_before{31}(2:end,2)' latency_csm_before{32}(2:end,2)' latency_csm_before{33}(2:end,2)' latency_csm_after{7}(2:end,2)' latency_csm_after{8}(2:end,2)' latency_csm_after{9}(2:end,2)' latency_csm_after{19}(2:end,2)' latency_csm_after{20}(2:end,2)' latency_csm_after{21}(2:end,2)' latency_csm_after{31}(2:end,2)' latency_csm_after{32}(2:end,2)' latency_csm_after{33}(2:end,2)'];

latency_tm_100MB = [latency_tm_before{10}(2:end,2)' latency_tm_before{11}(2:end,2)' latency_tm_before{12}(2:end,2)' latency_tm_before{19}(2:end,2)' latency_tm_before{23}(2:end,2)' latency_tm_before{24}(2:end,2)' latency_tm_before{34}(2:end,2)' latency_tm_before{35}(2:end,2)' latency_tm_before{36}(2:end,2)' latency_tm_after{10}(2:end,2)' latency_tm_after{11}(2:end,2)' latency_tm_after{12}(2:end,2)' latency_tm_after{19}(2:end,2)' latency_tm_after{23}(2:end,2)' latency_tm_after{24}(2:end,2)' latency_tm_after{34}(2:end,2)' latency_tm_after{35}(2:end,2)' latency_tm_after{36}(2:end,2)'];
latency_cm_100MB = [latency_cm_before{10}(2:end,2)' latency_cm_before{11}(2:end,2)' latency_cm_before{12}(2:end,2)' latency_cm_before{19}(2:end,2)' latency_cm_before{23}(2:end,2)' latency_cm_before{24}(2:end,2)' latency_cm_before{34}(2:end,2)' latency_cm_before{35}(2:end,2)' latency_cm_before{36}(2:end,2)' latency_cm_after{10}(2:end,2)' latency_cm_after{11}(2:end,2)' latency_cm_after{12}(2:end,2)' latency_cm_after{19}(2:end,2)' latency_cm_after{23}(2:end,2)' latency_cm_after{24}(2:end,2)' latency_cm_after{34}(2:end,2)' latency_cm_after{35}(2:end,2)' latency_cm_after{36}(2:end,2)'];
latency_tsm_100MB = [latency_tsm_before{10}(2:end,2)' latency_tsm_before{11}(2:end,2)' latency_tsm_before{12}(2:end,2)' latency_tsm_before{19}(2:end,2)' latency_tsm_before{23}(2:end,2)' latency_tsm_before{24}(2:end,2)' latency_tsm_before{34}(2:end,2)' latency_tsm_before{35}(2:end,2)' latency_tsm_before{36}(2:end,2)' latency_tsm_after{10}(2:end,2)' latency_tsm_after{11}(2:end,2)' latency_tsm_after{12}(2:end,2)' latency_tsm_after{19}(2:end,2)' latency_tsm_after{23}(2:end,2)' latency_tsm_after{24}(2:end,2)' latency_tsm_after{34}(2:end,2)' latency_tsm_after{35}(2:end,2)' latency_tsm_after{36}(2:end,2)'];
latency_csm_100MB = [latency_csm_before{10}(2:end,2)' latency_csm_before{11}(2:end,2)' latency_csm_before{12}(2:end,2)' latency_csm_before{19}(2:end,2)' latency_csm_before{23}(2:end,2)' latency_csm_before{24}(2:end,2)' latency_csm_before{34}(2:end,2)' latency_csm_before{35}(2:end,2)' latency_csm_before{36}(2:end,2)' latency_csm_after{10}(2:end,2)' latency_csm_after{11}(2:end,2)' latency_csm_after{12}(2:end,2)' latency_csm_after{19}(2:end,2)' latency_csm_after{23}(2:end,2)' latency_csm_after{24}(2:end,2)' latency_csm_after{34}(2:end,2)' latency_csm_after{35}(2:end,2)' latency_csm_after{36}(2:end,2)'];

latency_sl_allsize = [mean(latency_tm_100KB), mean(latency_cm_100KB); mean(latency_tm_1MB), mean(latency_cm_1MB); mean(latency_tm_10MB), mean(latency_cm_10MB); mean(latency_tm_100MB), mean(latency_cm_100MB)];
latency_sf_allsize = [mean(latency_tsm_100KB), mean(latency_csm_100KB); mean(latency_tsm_1MB), mean(latency_csm_1MB); mean(latency_tsm_10MB), mean(latency_csm_10MB); mean(latency_tsm_100MB), mean(latency_csm_100MB)];

figure;
subplot(1,2,1);
bar(latency_sl_allsize);
title('(a) Stateless Application','FontSize',20, 'FontWeight','bold');
xlabel('Layer Size (MB)');
ylabel('Average System Latency (ms)');
set(gca,'FontSize', 20, 'FontWeight','bold');
legend('TM-SL','CM-SL','Location','northwest');
set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
ylim([0 120])
%dim = [0.75 0.3 0.3 0.3];
%str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
%annotation('textbox',dim,'String',str,'FitBoxToText','on');
grid minor;


subplot(1,2,2);
bar(latency_sf_allsize);
title('(b) Stateful Application','FontSize',20, 'FontWeight','bold');
xlabel('Layer Size (MB)');
ylabel('Average System Latency (ms)');
set(gca,'FontSize', 20, 'FontWeight','bold');
legend('TM-SL','CM-SL','Location','northwest');
set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
%dim = [0.75 0.3 0.3 0.3];
%str = {'BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
%annotation('textbox',dim,'String',str,'FitBoxToText','on');
grid minor;



% %Compare latency CDF for load src<dst
% latency_tm_case2_5_8_11 = [latency_tm_before{2}(:,2)' latency_tm_before{5}(:,2)' latency_tm_before{8}(:,2)' latency_tm_before{11}(:,2)'];
% latency_cm_case2_5_8_11 = [latency_cm_before{2}(:,2)' latency_cm_before{5}(:,2)' latency_cm_before{8}(:,2)' latency_cm_before{11}(:,2)'];
% latency_tsm_case2_5_8_11 = [latency_tsm_before{2}(:,2)' latency_tsm_before{5}(:,2)' latency_tsm_before{8}(:,2)' latency_tsm_before{11}(:,2)'];
% latency_csm_case2_5_8_11 = [latency_csm_before{2}(:,2)' latency_csm_before{5}(:,2)' latency_csm_before{8}(:,2)' latency_csm_before{11}(:,2)'];
% 
% figure;
% h1 = cdfplot(latency_tm_case2_5_8_11);
% hold on;
% h2 = cdfplot(latency_cm_case2_5_8_11);
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% grid minor;
% xlabel('Application Latency (ms)');
% ylabel('CDF');
% title('Stateless Applicaiton; Load SRC<DST')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('TM-SL','CM-SL','Location','northwest');
% 
% figure;
% h1 = cdfplot(latency_tsm_case2_5_8_11);
% hold on;
% h2 = cdfplot(latency_csm_case2_5_8_11);
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% grid minor;
% xlabel('Application Latency (ms)');
% ylabel('CDF');
% title('Stateful Applicaiton; Load SRC<DST')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('TM-SF','CM-SF','Location','northwest');
% 

%% OLD Plotting
% load_cm1 = fopen('load_exp_cm_2-08-2020.txt','r');
% load_cm1 = textscan(load_cm1,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_cm2 = fopen('load_exp_cm_2-09-2020.txt','r');
% load_cm2 = textscan(load_cm2,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_csm1 = fopen('load_exp_csm_2-07-2020.txt','r');
% load_csm1 = textscan(load_csm1,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_csm2 = fopen('load_exp_csm_2-09-2020.txt','r');
% load_csm2 = textscan(load_csm2,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_tm1 = fopen('load_exp_tm_2-09-2020.txt','r');
% load_tm1 = textscan(load_tm1,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_tm2 = fopen('load_tm_sl_int_2020-02-09_00-31-39.txt','r');
% load_tm2 = textscan(load_tm2,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_tsm1 = fopen('load_exp_tsm_2-08-2020.txt','r');
% load_tsm1 = textscan(load_tsm1,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% load_tsm2 = fopen('load_exp_tsm_2-09-2020.txt','r');
% load_tsm2 = textscan(load_tsm2,'%d %s %f %f %f %f %f %f %f %f %f');
% 
% traffic_cm1 = fopen('traffic_exp_cm_2-08-2020.txt','r');
% traffic_cm1 = textscan(traffic_cm1,'%d %s %f %f %f');
% 
% traffic_cm2 = fopen('traffic_exp_cm_2-09-2020.txt','r');
% traffic_cm2 = textscan(traffic_cm2,'%d %s %f %f %f');
% 
% traffic_csm1 = fopen('traffic_exp_csm_2-07-2020.txt','r');
% traffic_csm1 = textscan(traffic_csm1,'%d %s %f %f %f');
% 
% traffic_csm2 = fopen('traffic_exp_csm_2-09-2020.txt','r');
% traffic_csm2 = textscan(traffic_csm2,'%d %s %f %f %f');
% 
% traffic_tm1 = fopen('traffic_exp_tm_2-09-2020.txt','r');
% traffic_tm1 = textscan(traffic_tm1,'%d %s %f %f %f');
% 
% traffic_tm2 = fopen('traffic_tm_sl_int_2020-02-09_00-31-39.txt','r');
% traffic_tm2 = textscan(traffic_tm2,'%d %s %f %f %f');
% 
% traffic_tsm1 = fopen('traffic_exp_tsm_2-08-2020.txt','r');
% traffic_tsm1 = textscan(traffic_tsm1,'%d %s %f %f %f');
% 
% traffic_tsm2 = fopen('traffic_exp_tsm_2-09-2020.txt','r');
% traffic_tsm2 = textscan(traffic_tsm2,'%d %s %f %f %f');
% 
% %Traffic In and Out
% traffic_tm1_dst_in = traffic_tm1{5}(3:6:216);
% traffic_tm1_dst_out = traffic_tm1{5}(4:6:216);
% traffic_tm1_src_in = traffic_tm1{5}(5:6:216);
% traffic_tm1_src_out = traffic_tm1{5}(6:6:216);
% 
% traffic_tsm1_dst_in = traffic_tsm1{5}(3:6:216);
% traffic_tsm1_dst_out = traffic_tsm1{5}(4:6:216);
% traffic_tsm1_src_in = traffic_tsm1{5}(5:6:216);
% traffic_tsm1_src_out = traffic_tsm1{5}(6:6:216);
% 
% traffic_cm1_dst_in = traffic_cm1{5}(3:10:360);
% traffic_cm1_dst_out = traffic_cm1{5}(4:10:360);
% traffic_cm1_src_in = traffic_cm1{5}(9:10:360);
% traffic_cm1_src_out = traffic_cm1{5}(10:10:360);
% 
% traffic_csm1_dst_in = traffic_csm1{5}(3:10:360);
% traffic_csm1_dst_out = traffic_csm1{5}(4:10:360);
% traffic_csm1_src_in = traffic_csm1{5}(9:10:360);
% traffic_csm1_src_out = traffic_csm1{5}(10:10:360);
% 
% traffic_tm2_dst_in = traffic_tm2{5}(3:6:216);
% traffic_tm2_dst_out = traffic_tm2{5}(4:6:216);
% traffic_tm2_src_in = traffic_tm2{5}(5:6:216);
% traffic_tm2_src_out = traffic_tm2{5}(6:6:216);
% 
% traffic_tsm2_dst_in = traffic_tsm2{5}(3:6:216);
% traffic_tsm2_dst_out = traffic_tsm2{5}(4:6:216);
% traffic_tsm2_src_in = traffic_tsm2{5}(5:6:216);
% traffic_tsm2_src_out = traffic_tsm2{5}(6:6:216);
% 
% traffic_cm2_dst_in = traffic_cm2{5}(3:10:360);
% traffic_cm2_dst_out = traffic_cm2{5}(4:10:360);
% traffic_cm2_src_in = traffic_cm2{5}(9:10:360);
% traffic_cm2_src_out = traffic_cm2{5}(10:10:360);
% 
% traffic_csm2_dst_in = traffic_csm2{5}(3:10:360);
% traffic_csm2_dst_out = traffic_csm2{5}(4:10:360);
% traffic_csm2_src_in = traffic_csm2{5}(9:10:360);
% traffic_csm2_src_out = traffic_csm2{5}(10:10:360);
% 
% 
% 
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
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SL','CM-SL','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
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
% legend('TM-SF','CM-SF','Location','northwest');
% set(gca, 'XTickLabel', {'0.1' '1' '10' '100'})
% dim = [0.75 0.3 0.3 0.3];
% str = {'Layer size=10MB','State change=10%','BW (Mbps):','SRC-DST=100','SRC-Client=10','DST-Client=50','DST-N1=942','DST-N2=942','Load: SRC>DST'};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
% grid minor;
% 
% %Load values
% load_tm1_dst = load_tm1{8}(2:3:108);
% load_cm1_dst = load_cm1{8}(2:3:180);
% load_tm1_src = load_tm1{8}(3:3:108);
% load_cm1_src = load_cm1{8}(5:6:180);
% 
% load_tsm1_dst = load_tsm1{8}(2:3:108);
% load_csm1_dst = load_csm1{8}(2:3:180);
% load_tsm1_src = load_tsm1{8}(3:3:108);
% load_csm1_src = load_csm1{8}(5:6:180);
% 
% load_tm2_dst = load_tm2{8}(2:3:108);
% load_cm2_dst = load_cm2{8}(2:3:180);
% load_tm2_src = load_tm2{8}(3:3:108);
% load_cm2_src = load_cm2{8}(5:6:180);
% 
% load_tsm2_dst = load_tsm2{8}(2:3:108);
% load_csm2_dst = load_csm2{8}(2:3:180);
% load_tsm2_src = load_tsm2{8}(3:3:108);
% load_csm2_src = load_csm2{8}(5:6:180);

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
% legend('Traditional SL','CM SL','Location','northwest');
% 
% % legend('Traditional SL','CM SL','Traditional SF','CM SF','Location','northwest');
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
% legend('Traditional SF','CM SF','Location','northwest');


% figure
% plot(1,1)
% h1 = cdfplot(migr_time_tm1(:,2)./1000);
% hold on;
% h2 = cdfplot(migr_time_cm1(:,2)./1000);
% h3 = cdfplot(migr_time_tsm1(:,2)./1000);
% h4 = cdfplot(migr_time_csm1(:,2)./1000);
% hold off;
% 
% set( h1,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h2, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% set( h3, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % xlim([50 150]);
% grid minor;
% xlabel('Migration Time (s)');
% ylabel('CDF');
% title('Migration Time CDF')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('Traditional SL','CM SL','Location','northwest');
% 
% figure
% plot(1,1)
% h1 = cdfplot(migr_time_tm1(:,2)./1000);
% h2 = cdfplot(migr_time_cm1(:,2)./1000);
% h3 = cdfplot(migr_time_tsm2(:,2)/1000);
% hold on;
% h4 = cdfplot(migr_time_csm2(:,2)/1000);
% set( h3,'LineStyle',':','LineWidth',3,'MarkerSize',5);
% set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% set( h3, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% set( h4, 'LineStyle','-','LineWidth',3,'MarkerSize',5);
% % xlim([50 150]);
% grid minor;
% xlabel('Migration Time (s)');
% ylabel('CDF');
% title('Migration Time CDF')
% set(gca,'FontSize',20, 'FontWeight','bold');
% legend('Traditional SF','CM SF','Location','northwest');
% 

% 
% 
