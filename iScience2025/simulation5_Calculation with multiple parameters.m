newparameters = DetailedModel('parametervalues');
rng(2);

tiledlayout(2,2); % 3 by 3 tiles
factorList = 0:0.1:1; %firstval:step:lastval、パラメーターにかける倍率、低い倍率のパラメータの数が多いほどホップ
%%factorList = 0:0.01:0.2;
%%for i = 1:10 % 20 parameter sets%%特定のパラメータでリズム変化を見るときは消す
    %%parameterSet = randsample(1:70,3);%１から７０までの数列から3個の値を抽出
    parameterSet = [63 30 19];
    disp(strcat("Bifurcation Diagram for parameter #",num2str(parameterSet)));
    originalParameterVal = [];
    for idx = parameterSet
        originalParameterVal = [originalParameterVal, newparameters(idx)];
    end
    ampList = [];
    periodList = [];
    for f = factorList
        cnt = 1;
        for idx = parameterSet
            newparameters(idx) = originalParameterVal(cnt) * f;
            cnt = cnt + 1;
        end
        [t,x]=ode15s(@(t,x) DetailedModel(t,x,newparameters),[0 1000],DetailedModel());%0から200時間

        timeptNum = length(t);
        startpt = round(timeptNum*0.7);%後ろの３割だけ
        shortenedVal = x(startpt:end,21);%21はBmal1
        if length(shortenedVal) == 0%shortenedValは後ろの３割部分
            amp = 0;
            period = 0;
        else

            shortenedTime = t(startpt:end);
            amp = max(shortenedVal)-min(shortenedVal);
            

            [pkvalue,pktime] = findpeaks(shortenedVal,shortenedTime);

            if isempty(pktime) || length(pktime) == 1
                period = 0;
            else
                period = pktime(end)-pktime(end-1);
            end

        end
        ampList = [ampList amp];
        periodList =[periodList period];



    end
    nexttile;
    yyaxis left
    p1 = plot(factorList, ampList, "wo", 'MarkerFaceColor',[0.3010 0.7450 0.9330]);
    ylim([0 max(ampList)]);
    ylabel ('Amplitude')
    yyaxis right
    plot (factorList, periodList, "ro", 'MarkerFaceColor',[0.9900 0.53250 0.2980]);
    %ylim([0 max(periodList)]);
    ylabel ('Period')
    title(strcat("#"+num2str(parameterSet)));
    xlabel('factorList')

%%end%%特定のパラメータでリズム変化を見るときは消す

