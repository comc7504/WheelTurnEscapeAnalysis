%Displays the step
disp('Trace plots');

%Making plot for raw fiber photometry traces
%requires load_csvs_mvb

% You can define colors by proportion of RGB values (base 255)
bleu = [0.2157 0.3765 0.5725]; 
verte = [0.5725 0.8157 0.3137];
violet = [.61 .51 .74];
grey = [.75, .75, .75, .8]; 
red = [.75, 0, 0, .5]; 

%Loop for plot for each N
for k = 1:size(rats,1)

    %Gets file information
    [~,rat_num,~] = fileparts(rats(k).name);
    destfile = strcat(fullfile(Folder, rat_num),separator);
    figure, hold on

    %405_fit trace
    plot(fp_data{k,1}, fp_data{k,3}, 'Color', violet) 
    
    %465 trace
    plot(fp_data{k,1}, fp_data{k,4}, 'Color', bleu)   

    %dF (465-405_fit) trace
    plot(fp_data{k,1}, fp_data{k,5}, 'Color', verte)  

    %Give max time value during test
    xlim([0 max(fp_data{k,1})]); 

    %Adjust depending on dF
    ylim([-0.2 0.6]); 

    %Formating
    set(gca, 'box', 'on');
    set(gca,'TickDir','in');
    plot([0 max(fp_data{k,1})], [0 0], 'Color', 'k', 'LineWidth', 0.75)

    %Wheel event plots
   % plot_events(fp_data{k,17}, grey , 0.1, 'all'); 

    %Stress event plots
    plot_events(fp_data{k,9}(:,1), red, 0.3, 'all'); 

    %Approx time for x axis
    set(gca,'XTick',0:1000:7000,'XTickLabel',{floor((0:1000:7000)./60)}, 'fontsize',12); 
    
    %Yaxis
    set(gca,'YTick',-0.5:0.5:2,'YTickLabel',{'-0.5', '0', '0.5', '1', '1.5',...
        '2'},'fontsize',12);

    %Labeling
    title('\bf100 Trials','fontsize',18);
    xlabel('Time (min)','fontsize',14);
    ylabel('465-405\_fit (dF)','fontsize',14);
    set(gca, 'LineWidth', 0.75);
    legend({'405\_fit', '465', 'dF'}, 'location', 'northeast')

    %name the figure and save to rat folder
    outP = [destfile 'ES_session_405_465_dF']; 
    saveFig(gcf, outP, 'fig');
    saveFig(gcf, outP, 'pdf');

    % Take time to appreciate your beautiful data
    pause(3) 
    
    %Displays which N is finished
    rats(k).name 

    close all
end

save([Folder strcat(exp, '_', gp)]) 
