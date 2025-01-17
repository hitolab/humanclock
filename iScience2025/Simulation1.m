newparameters = DetailedModel('parametervalues');



tiledlayout(5,5); % 5 by 5 tiles
factorList = 0:0.05:1; %fistval:step:lastval
for idx = 1:5 % #1 to #25
    nexttile;
    disp("Now calculating Bifurcation Diagram for parameter #"+num2str(idx))
    originalParameterVal = newparameters(idx);
    ampList = [];
    periodList = [];
    for f = factorList
        newparameters(idx) = originalParameterVal * f;
        [t,x]=ode15s(@(t,x) DetailedModel(t,x,newparameters),[0 1000],DetailedModel());

        timeptNum = length(x);
        startpt = round(timeptNum*0.7);
        shortenedVal = x(startpt:end,21);
        shortenedTime = t(startpt:end);
        amp = max(shortenedVal)-min(shortenedVal);
        ampList = [ampList amp];  
        
        [pkvalue,pktime] = findpeaks(shortenedVal,shortenedTime);

        if isempty(pktime) || length(pktime) == 1
            period = 0;
        else
            period = pktime(end)-pktime(end-1);
        end
        periodList =[periodList period];
       
        %disp(pktime)
        %disp(pkvalue)
        
        
    end
    yyaxis left
    plot(factorList, ampList, "wo", 'MarkerFaceColor',[0.3010 0.7450 0.9330]);
    ylim([0 max(ampList)+5]);
    ylabel ('Amplitude','color',[0.3010 0.7450 0.9330])
    yyaxis right
    plot (factorList, periodList, "wo", 'MarkerFaceColor',[0.9900 0.53250 0.2980]);
    ylim([15 max(periodList)]);
    ylabel ('Period','color',[0.9900 0.53250 0.2980])
    title("Parameter #"+num2str(idx));
    xlabel('factorList')
    
end

