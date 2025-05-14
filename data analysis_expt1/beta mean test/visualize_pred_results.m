% Initialize the data sets
obs_val = cell(1, 2);
epsilon = 0.0000001;
T = readtable('participant_performance.csv');
obs_val{1} = T{T.cond_factor == 1,'y'};
obs_val{2} = T{T.cond_factor == 2,'y'};
          
params = cell(1, 2);
params{1} = [0.811, 18.02];
params{2} = [0.811, 12.423];


% Determine global x limits based on both datasets
allData = [obs_val{1}; obs_val{2}]';
globalXMin = min(allData);
globalXMax = max(allData);

% Determine the number of bins
% binwidth = 0.05;

for i = 1:length(obs_val)
    data = obs_val{i};

    % Create subplot
    subplot(1, 2, i);
    histogram(data, 'BinMethod', 'integers', 'Normalization', 'pdf');
    hold on;
    
    % Generate line plot data
%     XMax = min(globalXMax + 0.05, 1);
%     x_values = linspace(globalXMin - 0.05, XMax, 100);
    x_values = linspace(globalXMin, globalXMax, globalXMax - globalXMin + 1);
    mode = params{i}(1);
    conc = params{i}(2);
    y_values = zeros(1,length(x_values));
    for j = 1:length(x_values)
        x = x_values(j);
        y_values(j) = betabinompmf(x, 48, mode, conc);
    end
    
    % Create line plot
    plot(x_values, y_values, 'r-', 'LineWidth', 2);
    
    % Set the same x and y limits for both subplots
%     xlim([globalXMin - 0.05, globalXMax + 0.05]);
%     xticks(0.25:0.05:1);
%     ylim([0, 5]);
    xlim([globalXMin - 1, globalXMax + 1]);
    xticks(globalXMin:3:globalXMax);
    
    % Add titles, labels, and legends
    if i == 1
        title('Random');
    elseif i == 2
        title('Student Chosen');
    end
    xlabel('Test Accuracy');
    ylabel('Relative Frequency');

    hold off;
end