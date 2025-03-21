% Load the default parameter set from the model
newparameters = DetailedModel('parametervalues');

% Define the parameter indices to vary
parameterSet = [63, 30, 19];

% Define the scaling factors (from 1 down to 0.05 with step -0.05)
factorList = 1:-0.05:0.05;

disp("Now calculating the Bifurcation Diagram for parameter indices: " + num2str(parameterSet));

% Store the original parameter values before modification
originalParameterVal = newparameters(parameterSet);

% Prepare the figure layout (5x5 subplots)
tiledlayout(5, 5);

% Loop through each scaling factor
for f = factorList
    nexttile;   % Create a subplot for each factor
    disp("Scaling factor: " + num2str(f));  % Display current factor
    
    % Apply scaling to the selected parameters
    cnt = 1;
    for idx = parameterSet
        newparameters(idx) = originalParameterVal(cnt) * f;
        cnt = cnt + 1;
    end

    % Run the simulation (analyzing the time window from 900 to 1000)
    [t, x] = ode15s(@(t, x) DetailedModel(t, x, newparameters), [900 1000], DetailedModel());
    
    % Plot the output of variable 21 (assumed to represent the target gene/protein)
    plot(t(t > 900), x(t > 900, 21), 'LineWidth', 1);
    xlabel('Time');
    ylabel('X_{21}');
    title("#" + num2str(parameterSet) + " | Factor = " + num2str(round(f, 3)));
end
