% Goodwin Model: Hopf and SNIC Bifurcation Analysis
clc; clear; close all;

% Use ode15s for stiff systems if needed
use_stiff_solver = false;

% Parameter definitions
n = 10;              % Hill coefficient
kx_o = 1; ky_o = 1; kz_o = 1;   % Production rates
dx_o = 0.1; dy_o = 0.1; dz_o = 0.1; % Degradation rates
K = 1;               % Threshold constant
pars_o = [kx_o ky_o kz_o dx_o dy_o dz_o];  % Base parameter set
pars = pars_o;

% Simulation settings
tspan = [0 4000];        % Simulation time
X0 = [0; 1; 2];          % Initial conditions [mRNA, protein, complex]

% Bifurcation scan settings
num_iterations = 50;             % Number of parameter steps
parval = zeros(num_iterations + 1, 1);   % Scaled parameter values
amplist = zeros(num_iterations + 1, 1);  % Amplitude values
periodlist = zeros(num_iterations + 1, 1); % Period values

% Prepare the figure layout (A4 size)
figure('Units', 'centimeters', 'Position', [0, 0, 21, 29.7]);

% Loop through all 63 combinations of parameters to vary (6 binary bits)
for j = 1:63
    subplot(16, 4, j);  % Create subplot for this parameter combination
    pars = pars_o;      % Reset parameter set
    
    % Parameter sweep from full strength to zero
    for i = 0:num_iterations
        % Determine which parameters are being varied based on binary j
        parset = j;
        for cnt = 1:6
            if mod(parset, 2) == 1
                pars(cnt) = pars_o(cnt) * (i / num_iterations);  % Linearly reduce the selected parameter
            end
            parset = bitshift(parset, -1);  % Check next parameter
        end
        
        % Define the system of ODEs
        dxdt = @(t, X) [
            (pars(1) * K^n / (K^n + X(3)^n) - pars(4) * X(1))*P/24;   % mRNA dynamics
            (pars(2) * X(1) - pars(5) * X(2))*P/24;                   % Protein dynamics
            (pars(3) * X(2) - pars(6) * X(3))*P/24;                    % Complex dynamics
        ];

        % Run the simulation
        if use_stiff_solver
            [t, X] = ode45(dxdt, tspan, X0);   % Non-stiff solver
        else
            [t, X] = ode15s(dxdt, tspan, X0);  % Stiff solver
        end

        % Analyze amplitude (standard deviation) using the second half of the simulation
        half_idx = round(length(t) * 0.5);
        amp = std(X(half_idx:end, 3));  % Analyze oscillations of the complex

        % Store parameter scaling, amplitude, and period results
        parval(i + 1) = i / num_iterations;
        amplist(i + 1) = amp;

        % Detect peaks to calculate the oscillation period
        [~, locs] = findpeaks(X(:, 3), t);
        if length(locs) <= 3
            period = 0;  % Not enough peaks detected
        else
            locs = locs(end - 3:end);       % Use the last few peaks for stability
            periods = diff(locs);
            period = mean(periods);         % Calculate the average period
        end
        periodlist(i + 1) = period;
    end

    % === Plotting bifurcation results ===
    yyaxis left
    scatter(parval, amplist, 2, 'filled');   % Plot amplitude
    ylim([0, 0.6]);                         % Fix y-axis range for amplitude

    yyaxis right
    scatter(parval, periodlist, 2, 'filled'); % Plot period
    ylim([0, 100]);                          % Fix y-axis range for period

    % === Generate dynamic subplot title indicating varied parameters ===
    figtitle = '';
    parset = j;
    if mod(parset, 2) == 1, figtitle = figtitle + "k_x "; end; parset = bitshift(parset, -1);
    if mod(parset, 2) == 1, figtitle = figtitle + "k_y "; end; parset = bitshift(parset, -1);
    if mod(parset, 2) == 1, figtitle = figtitle + "k_z "; end; parset = bitshift(parset, -1);
    if mod(parset, 2) == 1, figtitle = figtitle + "d_x "; end; parset = bitshift(parset, -1);
    if mod(parset, 2) == 1, figtitle = figtitle + "d_y "; end; parset = bitshift(parset, -1);
    if mod(parset, 2) == 1, figtitle = figtitle + "d_z "; end;

    title(figtitle, 'FontSize', 4);          % Set title indicating varied parameters
    ax = gca;
    set(ax, 'FontSize', 4);                  % Set axis font size
    disp(j);                                 % Display progress
end

% === Export figure settings for PDF (A4 size) ===
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [21, 29.7]);          % A4 paper size (portrait)
set(gcf, 'PaperPosition', [0, 0, 21, 29.7]); % Fill the A4 page

% === Export the figure ===
if use_stiff_solver
    exportgraphics(gcf, "bifurcation.pdf", 'ContentType', 'vector');
else
    exportgraphics(gcf, "bifurcation_s.pdf", 'ContentType', 'vector');
end
