% This script analyzes SNIC results, simulates dynamics, 
% and plots time series while sweeping the parameter factor 'f'

tiledlayout(5, 5);  % Create a 5x5 tile layout for plots
amp_origin = 25.5348;  % Original amplitude for threshold reference

for numtxtfile = 1:70  % Process sniclist1.txt to sniclist70.txt
    pdfcnt = 1;  % Initialize PDF export counter
    
    % Read the corresponding SNIC parameter list file
    filename = [num2str(numtxtfile) 'sniclist.txt'];
    fid = fopen(filename, 'r');
    lines = textscan(fid, '%s', 'Delimiter', '\n');  % Read all lines
    fclose(fid);
    
    line_count = numel(lines{1});
    lineNumber = 1;
    
    % Process each parameter-f pair in the sniclist (every 2 lines)
    for i = 1:2:line_count
        figure('Visible', 'off');  % Create a new figure in the background
        
        % Reopen the file to fetch the exact line
        fileID = fopen(filename, 'r');
        
        % Skip to the target parameter line
        for k = 1:lineNumber - 1
            fgetl(fileID);
        end
        
        % Read the parameter line starting with '#'
        parameterLine = fgetl(fileID);
        param_indices = strfind(parameterLine, '#');
        parameterLine_remaining = parameterLine(param_indices(1) + 1:end);
        para = strsplit(strtrim(parameterLine_remaining));  % Split by space
        parameterSet = str2double(para);  % Convert to numeric array
        
        % Log parameter info
        write_txtname = [num2str(numtxtfile) 'onlysnicdetail_log.txt'];
        diary(write_txtname);
        disp(['Line ' num2str(lineNumber) ': PDF ' num2str(pdfcnt) ' #' parameterLine_remaining]);
        disp(['(Parameter count: ' num2str(length(para)) ')']);
        
        % Read the next line to get the factor f value
        lineNumber = lineNumber + 1;
        fLine = fgetl(fileID);
        f_a = str2double(extractAfter(fLine, ': '));
        disp(['Line ' num2str(lineNumber) ': f = ' num2str(f_a)]);
        fclose(fileID);
        
        % Simulation preparation
        newparameters = DetailedModel('parametervalues');
        originalParameterVal = newparameters(parameterSet);
        
        % Sweep 'f' from f_a to 0
        for f = f_a : -f_a / 20 : 0
            % Apply the factor to selected parameters
            newparameters(parameterSet) = originalParameterVal * f;
            
            % Run the ODE simulation
            [t, x] = ode15s(@(t, x) DetailedModel(t, x, newparameters), [0 1000], DetailedModel());
            startpt = round(length(t) * 0.7);  % Use last 30% for analysis
            shortenedVal = x(startpt:end, 21);  % Analyze variable #21 (e.g., Bmal1)
            
            % Compute y-axis scaling based on initial f_a
            y_middle = (max(shortenedVal) + min(shortenedVal)) / 2;
            if f == f_a
                scale = (max(shortenedVal) - min(shortenedVal)) / 2;
            end
            y_bottom = y_middle - scale;
            y_top = y_middle + scale;
            
            % Plot the result
            nexttile;
            plot(t(startpt:end), shortenedVal);
            ylim([y_bottom y_top]);
            xlim([900 1000]);
            title(['f = ' num2str(f)]);
            
            % Analyze amplitude and period
            if isempty(shortenedVal)
                amp = 0;
                period = 0;
            else
                shortenedTime = t(startpt:end);
                [~, pktime] = findpeaks(shortenedVal, shortenedTime);
                
                if numel(pktime) <= 1
                    period = 0;
                else
                    period = pktime(end) - pktime(end - 1);
                    amp = max(shortenedVal) - min(shortenedVal);
                    
                    if f == f_a
                        period_a = period;
                        amp_a = amp;
                    end
                end
            end
            
            % Classify as SNIC or no bifurcation based on amplitude/period
            if amp < (amp_a - 10)
                if period < (period_a * 2) && period > 0
                    disp("↓ Classified as No Bifurcation ↓");
                end
            elseif period > (period_a * 2)
                if amp > (amp_a - 10)
                    disp("↓ Classified as SNIC ↓");
                end
            end
            
            disp(['f : ', num2str(f)]);
            disp(['amp: ', num2str(amp)]);
            disp(['period: ', num2str(period)]);
        end
        
        % Export the figure as a PDF
        disp("---------------------------");
        figfile_name = sprintf('%dparams_pdf%d_%s.pdf', length(para), pdfcnt, strjoin(string(parameterSet), '_'));
        exportgraphics(gcf, figfile_name, 'ContentType', 'vector');
        pdfcnt = pdfcnt + 1;
    end
    diary off;  % End logging for this SNIC list
end
