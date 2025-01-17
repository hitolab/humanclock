newparameters = DetailedModel('parametervalues');
%parameterNo = 22;
parameterSet = [63 30 19];
factorList = linspace(0.009,0.010,16);

disp("Now calculating Bifurcation Diagram for parameter #"+num2str(parameterSet))
originalParameterVal = [];
for idx = parameterSet
    originalParameterVal = [originalParameterVal, newparameters(idx)];
end


tiledlayout(4,4); % Number of figures
nexttile;
for f = factorList % min factor, max factor, number
        cnt = 1;
        disp(f);
    for idx = parameterSet
        newparameters(idx) = originalParameterVal(cnt) * f;
        cnt = cnt + 1;
    end
    [t,x]=ode15s(@(t,x) DetailedModel(t,x,newparameters),[0 2000],DetailedModel()); 
    plot(t(900:end), x(900:end,21))
    title("#"+int2str(parameterSet)+": Factor= "+ num2str(round(f,3)));
    nexttile;

end


