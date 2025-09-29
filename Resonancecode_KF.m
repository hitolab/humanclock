newparameters = DetailedModel('parametervalues');

%fill in the numbers
parameterSet1 = [62 22 3 7 49 12 63 57 6 68];
parameterSet2 = [20 56 32 2 8 64 10 21 48 53]; 
parameterSet3 = [4 37 42 29 67 49 47 10 64 38];
parameterSet4 = [66 70 13 64 10 63 44 26 49 2];
parameterSet5 = [8 4 50 5 68 1 9 6 40 16];
parameterSet6 = [43 70 40 44 5 11 2 59 35 23];
parameterSet7 = [19 37 55 45 65 5 57 14 52 53];
parameterSet8 = [8 4 50 5 68 1 9 6 40 16];
parameterSet9 = [43 70 40 44 5 11 2 59 35 23];
parameterSet10 = [19 37 55 45 65 5 57 14 52 53];

fvals = [0.2 0.4 0.5 0.2 0.4 0.4 0.2 0.2 0.2 0.2];

parameterSets = transpose([parameterSet1;parameterSet2;parameterSet3;parameterSet4;parameterSet5;parameterSet6;parameterSet7;parameterSet8;parameterSet9;parameterSet10]);

parameterNo = 0;
for parameterSet = parameterSets
    parameterNo = parameterNo+1;
    parameterSet = transpose(parameterSet);
    disp(parameterSet);

    originalParameterVal = [];
    for idx = parameterSet
        originalParameterVal = [originalParameterVal, newparameters(idx)];
    end

    figure;
    tiledlayout(4, 3);

    amplist = []; % Initialize amplist to store amplitude values
    Tlist = [];   % Initialize Tlist to store period values

    lowPeriod = 10;
    highPeriod = 60;

    for T=lowPeriod:highPeriod  % external period
        disp("T="+num2str(T));
        time =[];
        val = [];


        cycles = round(500/T); % number of cycles

        for i = 0:cycles
            f = 1;
            cnt =1;
            for idx = parameterSet
                newparameters(idx) = originalParameterVal(cnt) * f;
                cnt = cnt + 1;
            end
            if i==0
                [t,x]=ode15s(@(t,x) DetailedModel(t,x,newparameters),[T*i T*i+1],DetailedModel());
                time = t;
                val = x;
            else
                [t,x]=ode15s(@(t,x) DetailedModel(t,x,newparameters),[T*i T*i+1],x(end,:));
                time = [time; t];
                val = [val; x];
            end

            f =fvals(parameterNo);
            cnt =1;
            for idx = parameterSet
                newparameters(idx) = originalParameterVal(cnt) * f;
                cnt = cnt + 1;
            end
            [t,x]=ode15s(@(t,x) DetailedModel(t,x,newparameters),[T*i+1 T*(i+1)],x(end,:));
            time = [time; t];
            val = [val; x];

        end

        if mod(T,round((highPeriod-lowPeriod)/9))==0
            nexttile;
            plot(time(1:end), val(1:end,21));
        end
        title("T:"+num2str(T));
        amplist = [amplist, std(val(time>300,21))] ;
        Tlist = [Tlist, T];
    end

    nexttile;
    plot(Tlist, amplist);
    figname = strjoin(string(parameterSet), '_');
    exportgraphics(gcf, figname+"_f"+num2str(f)+'.pdf', 'ContentType', 'vector');
end