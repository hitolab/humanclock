tiledlayout(5, 5);   % Create a 5x5 grid for plots
amp_origin = 25.5348;
pdfcnt = 46;
filename = 'snic.txt';

for j = 91:2:91
    figure('Visible', 'off');
    lineNumber = j;

    % === Read parameter set and initial factor f_a ===
    fileID = fopen(filename, 'r');
    if fileID == -1
        error('Could not open the file: %s', filename);
    end
    for i = 1:lineNumber - 1
        fgetl(fileID);
    end
    parameterLine = fgetl(fileID);
    parameterLine_remaining = extractAfter(parameterLine, '#');
    para = strsplit(strtrim(parameterLine_remaining));
    parameterSet = str2double(para);

    diary('snic_log.txt');
    disp(['Line ' num2str(lineNumber) ': PDF No.' num2str(pdfcnt) ' # ' parameterLine_remaining]);
    disp(['Number of parameters: ' num2str(length(para))]);

    fLine = fgetl(fileID);
    fLine_remaining = extractAfter(fLine, ': ');
    f_a = str2double(fLine_remaining);
    disp(['Line ' num2str(lineNumber + 1) ': f = ' fLine_remaining]);
    fclose(fileID);

    % === Retrieve initial parameter values ===
    newparameters = DetailedModel('parametervalues');
    originalParameterVal = newparameters(parameterSet);

    % === Initial simulation with scaling factor f = 0 ===
    newparameters(parameterSet) = originalParameterVal * 0;
    [t_0, x_0] = ode15s(@(t, x) DetailedModel(t, x, newparameters), [0 1000], DetailedModel());
    [amp, period] = analyzeDynamics(t_0, x_0(:, 21));

    % === Check if further exploration is needed ===
    if amp < (25 * 0.1) || period >= 300
        newparameters = DetailedModel('parametervalues');
        newparameters(parameterSet) = originalParameterVal * 0.01;
        [t_a, x_a] = ode15s(@(t, x) DetailedModel(t, x, newparameters), [0 1000], DetailedModel());
        [amp, period] = analyzeDynamics(t_a, x_a(:, 21));

        if amp < (25 * 0.1) || period >= 300
            newparameters = DetailedModel('parametervalues');
            originalParameterVal = newparameters(parameterSet);

            % === Sweep factor f from f_a to 0 ===
            for f = f_a:-f_a / 20:0
                newparameters(parameterSet) = originalParameterVal * f;
                [t, x] = ode15s(@(t, x) DetailedModel(t, x, newparameters), [0 1000], DetailedModel());
                shortenedVal = extractTail(t, x(:, 21));

                if f == f_a
                    y_bottom = min(shortenedVal) - 0.1 * range(shortenedVal);
                    y_top = max(shortenedVal) + 0.1 * range(shortenedVal);
                end

                % === Plot the oscillation ===
                nexttile;
                plot(t(t > 900), x(t > 900, 21));
                ylim([y_bottom, y_top]);
                xlim([900, 1000]);
                title(strcat("f = ", num2str(f)));

                % === Analyze amplitude and period ===
                [amp, period] = analyzeDynamics(t, x(:, 21));
                if f == f_a
                    period_a = period;
                end

                % === Classify bifurcation type ===
                if amp < (amp_origin * 0.2)
                    if period < (period_a * 2) && period > 0
                        disp("↓ Classified as Hopf bifurcation ↓");
                    end
                elseif period > 48 && amp > (amp_origin * 0.2)
                    disp("↓ Classified as SNIC bifurcation ↓");
                end

                disp(strcat("f : ", num2str(f)));
                disp(strcat("amp: ", num2str(amp)));
                disp(strcat("period : ", num2str(period)));
            end
        end
    end

    % === Final rhythm check ===
    if amp >= (25 * 0.1) && period < 300
        disp(strcat("f : ", num2str(f)));
        disp(strcat("amp: ", num2str(amp)));
        disp(strcat("period : ", num2str(period)));
        disp("The rhythm is maintained.");
    end

    disp("---------------------------");

    % === Export the figure as PDF ===
    folder = 'snic';
    figfile_name = sprintf('%d_params_%d#%s.pdf', length(para), pdfcnt, strjoin(string(parameterSet), '_'));
    filepath = fullfile(folder, figfile_name);
    exportgraphics(gcf, filepath, 'ContentType', 'vector');
    pdfcnt = pdfcnt + 1;
end

diary off;

%% === Helper: Analyze amplitude and period from time-series data ===
function [amp, period] = analyzeDynamics(t, val)
    timeptNum = length(t);
    startpt = round(timeptNum * 0.7);  % Use the last 30% of data
    shortenedVal = val(startpt:end);
    shortenedTime = t(startpt:end);
    if isempty(shortenedVal)
        amp = 0;
        period = 0;
        return;
    end
    [~, pktime] = findpeaks(shortenedVal, shortenedTime);
    if numel(pktime) <= 1
        period = 0;
    else
        period = pktime(end) - pktime(end - 1);
    end
    amp = max(shortenedVal) - min(shortenedVal);
end

%% === Helper: Extract the last 30% segment of the time series ===
function shortenedVal = extractTail(t, val)
    timeptNum = length(t);
    startpt = round(timeptNum * 0.7);
    shortenedVal = val(startpt:end);
end
