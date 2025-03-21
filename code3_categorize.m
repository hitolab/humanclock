newparameters = DetailedModel('parametervalues');
rng(1);
factorList = 1:-0.05:0.05;  % Scaling factors from 1 down to 0.05

hopfList = [];
snicList = [];
chooseList = [];

choose_cnt_max = 70;

for choose_cnt = 2:choose_cnt_max
    s = RandStream('mlfg6331_64', 'Seed', 1);
    hopf_cnt = 0;
    snic_cnt = 0;

    for i = 1:100
        amp = 1; period = 1; amp_origin = 1;
        parameterSet = randsample(s, 1:70, choose_cnt);  % Randomly select parameters

        diary('logfile.txt');
        disp(strcat("Bifurcation Diagram for parameter #", num2str(parameterSet)));

        % Reset parameters
        newparameters = DetailedModel('parametervalues');
        originalParameterVal = newparameters(parameterSet);

        % Initial test with factor = 0
        newparameters(parameterSet) = originalParameterVal * 0;
        [t, x] = ode15s(@(t, x) DetailedModel(t, x, newparameters), [0 1000], DetailedModel());
        shortenedVal = extractOscillationSegment(t, x(:, 21));

        [amp, period] = computeAmpPeriod(shortenedVal, t);

        if amp < (25 * 0.1) || period >= 300
            % Try factor = 0.01
            newparameters = DetailedModel('parametervalues');
            newparameters(parameterSet) = originalParameterVal * 0.01;
            [t_a, x_a] = ode15s(@(t, x) DetailedModel(t, x, newparameters), [0 1000], DetailedModel());
            shortenedVal = extractOscillationSegment(t_a, x_a(:, 21));
            [amp, period] = computeAmpPeriod(shortenedVal, t_a);

            if amp < (25 * 0.1) || period >= 300
                % Sweep the factor if rhythm still weak
                for f = factorList
                    newparameters = DetailedModel('parametervalues');
                    newparameters(parameterSet) = originalParameterVal * f;

                    [t, x] = ode15s(@(t, x) DetailedModel(t, x, newparameters), [0 1000], DetailedModel());
                    shortenedVal = extractOscillationSegment(t, x(:, 21));
                    [amp, period] = computeAmpPeriod(shortenedVal, t);

                    if f == 1
                        amp_origin = amp;  % Store baseline amplitude
                    end

                    % Bifurcation classification
                    if amp < (amp_origin * 0.2) && period < 48
                        hopf_cnt = hopf_cnt + 1;
                        break;
                    elseif period > 48 && amp > (amp_origin * 0.2)
                        snic_cnt = snic_cnt + 1;
                        break;
                    end
                end
            end

            disp(strcat("f : ", num2str(f)));
            disp(strcat("amp: ", num2str(amp)));
            disp(strcat("period : ", num2str(period)));
            if f == 0.01
                disp("Rhythm does not disappear.");
            end
            disp(strcat("hopf_cnt : ", num2str(hopf_cnt), "/", num2str(i), ...
                        " (Num of parameters: ", num2str(choose_cnt), ")"));
            disp(strcat("snic_cnt : ", num2str(snic_cnt), "/", num2str(i), ...
                        " (Num of parameters: ", num2str(choose_cnt), ")"));
        end

        hopfList = [hopfList hopf_cnt];
        snicList = [snicList snic_cnt];
        chooseList = [chooseList choose_cnt];
    end

    % === Plotting after each parameter size iteration ===
    nexttile;
    yyaxis left
    plot(chooseList, hopfList, "-o", 'MarkerFaceColor', [0.3010 0.7450 0.9330]);
    ylabel('Hopf probability [%]');
    ylim([0 100]);

    yyaxis right
    plot(chooseList, snicList, "-o", 'MarkerFaceColor', [0.9900 0.53250 0.2980]);
    ylabel('SNIC probability [%]');
    ylim([0 100]);

    title("Bifurcation Probability");
    xlabel('Number of Parameters');
    xlim([0 70]);

    disp(strcat("hopfList : ", num2str(hopfList)));
    disp(strcat("snicList : ", num2str(snicList)));

    diary off;
end

%% === Helper Functions ===
function shortenedVal = extractOscillationSegment(t, val)
    timeptNum = length(t);
    startpt = round(timeptNum * 0.7);
    shortenedVal = val(startpt:end);
end

function [amp, period] = computeAmpPeriod(val, t)
    if isempty(val)
        amp = 0; 
        period = 0;
        return;
    end
    
    shortenedTime = t(round(length(t) * 0.7):end);
    [~, pktime] = findpeaks(val, shortenedTime);

    % Always compute amplitude, even if no peaks
    amp = max(val) - min(val);
    
    if numel(pktime) <= 1
        period = 0;
    else
        period = pktime(end) - pktime(end - 1);
    end
end
