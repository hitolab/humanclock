% Initialize model and random seed
newparameters = DetailedModel('parametervalues');
rng(2);

% Plot layout setup
tiledlayout(1, 1);

% Parameter settings
factorList = 0:0.02:1;  % factor scan range
parameterSet = [63, 30, 19];

disp(strcat("Bifurcation Diagram for parameter #", num2str(parameterSet)));

% Store original parameter values
originalParameterVal = newparameters(parameterSet);

% Preallocate results
ampList = zeros(size(factorList));
periodList = zeros(size(factorList));

% Loop through scaling factors
for idx_f = 1:length(factorList)
    f = factorList(idx_f);
    
    % Apply scaling to the selected parameters
    scaledParameters = newparameters;
    scaledParameters(parameterSet) = originalParameterVal * f;
    
    % Run ODE simulation
    [t, x] = ode15s(@(t, x) DetailedModel(t, x, scaledParameters), [0 1000], DetailedModel());
    
    % Analyze only the last 30% of the trajectory for steady behavior
    timeptNum = length(t);
    startpt = round(timeptNum * 0.7);
    shortenedVal = x(startpt:end, 21);
    
    % Compute amplitude and period
    if isempty(shortenedVal)
        amp = 0;
        period = 0;
    else
        shortenedTime = t(startpt:end);
        amp = max(shortenedVal) - min(shortenedVal);
        
        % Peak detection for period calculation
        [~, pktime] = findpeaks(shortenedVal, shortenedTime);
        if length(pktime) <= 1
            period = 0;
        else
            period = pktime(end) - pktime(end - 1);
        end
    end

    % Store results
    ampList(idx_f) = amp;
    periodList(idx_f) = period;
    
    % Display current status using disp(strcat())
    disp(strcat("Factor f = ", num2str(f), ...
                " | Amplitude = ", num2str(amp), ...
                " | Period = ", num2str(period)));
end

% ===== Plotting the Bifurcation Diagram =====
nexttile;
yyaxis left
plot(factorList, ampList, 'wo-', 'MarkerFaceColor', [0.3010 0.7450 0.9330], 'LineWidth', 1.5);
ylim([0, max(ampList)]);
ylabel('Amplitude');

yyaxis right
plot(factorList, periodList, 'ro-', 'MarkerFaceColor', [0.9900 0.5325 0.2980], 'LineWidth', 1.5);
ylim([0, max(periodList)]);
ylabel('Period');

title(strcat("Bifurcation Diagram for parameter #", num2str(parameterSet)));
xlabel('Scaling Factor');
grid on;
    