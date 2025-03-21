% This program is executed after running 'categorize_bifurcation'
% It extracts the parameter set and factor 'f' value when SNIC is detected

sniccnt_origin = 0;  % Initialize SNIC count baseline
cnt = 0;            % Counter for SNIC detections

for filecnt = 1:70   % Loop through 70 result files (from categorize_bifurcation)
    
    % Construct the filename to read
    filename = [num2str(filecnt) 'catelog.txt'];
    
    % Open the file
    fileID = fopen(filename, 'r');
    
    % Check if the file was opened successfully
    if fileID == -1
        error('Failed to open the file: %s', filename);
    end
    
    % Prepare the output file to save SNIC detection logs
    writefilename = [num2str(filecnt) 'sniclist.txt'];
    diary(writefilename);  % Start logging to output file
    sniclineNumber = 0;    % Keeps track of the last read line
    
    % Read through the file, processing blocks every 7 lines
    for j = 1:7:694  % Ensure the end value matches the file structure to avoid endless loops
        lineNumber = j;  % Target line to read
        
        % Skip lines until reaching the target parameter line
        for i = sniclineNumber + 1 : lineNumber - 1
            fgetl(fileID);  % Skip lines
        end
        
        % Read the parameter line (starts with '#')
        parameterLine = fgetl(fileID);
        index1 = strfind(parameterLine, '#');  % Find the '#' symbol
        
        if ~isempty(index1)
            parameterLine_remaining = parameterLine(index1(1):end);  % Extract the parameter set
        end
        
        % Read the next line where the 'f' value is stored
        lineNumber = lineNumber + 1;
        fLine = fgetl(fileID);  % Read the 'f' line
        
        % Move to the SNIC count line (5 lines below current position)
        sniclineNumber = lineNumber + 5;
        for i = lineNumber + 1 : sniclineNumber - 1
            fgetl(fileID);  % Skip intermediate lines
        end
        
        % Read the SNIC count line
        snicLine = fgetl(fileID);
        
        % Extract the SNIC count value between ': ' and '/'
        search_snic = ': ';
        endsnic = '/';
        index2 = strfind(snicLine, search_snic);
        index3 = strfind(snicLine, endsnic);
        
        if ~isempty(index2) && ~isempty(index3)
            start_index2 = index2(1) + length(search_snic);
            end_index3 = index3(1) - 1;
            snicLine_remaining = snicLine(start_index2:end_index3);
        end
        
        % Convert SNIC count string to a number
        sniccnt = str2double(snicLine_remaining);
        
        % If the SNIC count has increased, save this parameter set and f value
        if sniccnt > sniccnt_origin
            disp(parameterLine_remaining);  % Display the parameter set
            disp(fLine);                    % Display the corresponding 'f' value
            
            sniccnt_origin = sniccnt_origin + 1;  % Update the baseline count
            cnt = cnt + 1;                        % Increment detection count
        end
    end
    
    diary off;      % End logging for this file
    fclose(fileID); % Close the current file
end
