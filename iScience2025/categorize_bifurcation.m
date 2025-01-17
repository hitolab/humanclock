newparameters = DetailedModel('parametervalues');
%%rng("shuffle");
rng(1);
%choose_cnt_max = 2;

factorList = 1:-0.05:0.05;%0.05までにして、0の時に振幅0→Hopfカウントを防ぐ
%factorList = flip(factorList);

choose_cnt = 2;

hopfList = [];%グラフy軸　Hopf分岐になるパラメータ数
snicList = [];
chooseList = [];%グラフx軸　選んだパラメータ数　0~70

%idx =[];
parameterSet = [];

tiledlayout(2,2);
%for choose_cnt = 1:choose_cnt_max % １からcnt_max個まで1個ずつ増やす
    hopf_cnt = 0;
    snic_cnt = 0;
    for i = 1:100%ランダムに選ぶことを100回
        parameterSet = randsample(1:70,choose_cnt);%１から７０までの数列からchoose_cnt個の値を抽出
        disp(strcat("Bifurcation Diagram for parameter #",num2str(parameterSet)));
        originalParameterVal = [];

        %for j = 1:choose_cnt%選んだパラメータの数の分 matlabではインデックス1から
        %  disp(choose_cnt)

        originalParameterVal = [originalParameterVal, newparameters(parameterSet)];
        %parameterSet・・・選んだパラメータの番号が並ぶ
        %newparameters・・・選んだパラメータの値が並ぶ
        %originalParameterValの後ろに、その値が追加されていく

        minamp = 1000;
        minperiod = 1000;
        ampList = [];
        periodList =[];
    
        for f = factorList
            cnt = 1;
            for idx = parameterSet
                newparameters(idx) = originalParameterVal(cnt) * f;
                cnt = cnt + 1;
                %newparametersの中の選んだパラメータ番号の場所にfをかけた値が入る
                %cnt・・・複数パラメータ選んだ時、順番に行う
            end

            [t,x]=ode15s(@(t,x) DetailedModel(t,x,newparameters),[0 1000],DetailedModel());
            %0から1000時間

            timeptNum = length(t);
            startpt = round(timeptNum*0.7);%後ろの３割だけ
            shortenedVal = x(startpt:end,21);%21はBmal1
            if length(shortenedVal) == 0%shortenedValは後ろの３割部分
                amp = 0;
                period = 0;
            else

                shortenedTime = t(startpt:end);
                amp = max(shortenedVal)-min(shortenedVal);
                minamp = min(amp, minamp);
                ampList = [ampList amp];
                


                [pkvalue,pktime] = findpeaks(shortenedVal,shortenedTime);

                if isempty(pktime) || length(pktime) == 1
                    period = 0;
                else

                    period = pktime(end)-pktime(end-1);
                    minperiod = min(period, minperiod);
                    periodList = [periodList period];
                end


            end
        end

        %disp(periodList)
        %disp(ampList)

        if period > (minperiod * 10) %%SNIC判定
            snic_cnt = snic_cnt + 1;
        elseif 0 < minamp || minamp < 1%%Hopf判定 0より大きいを追加
            hopf_cnt = hopf_cnt + 1;
        end
    disp(strcat("i : ",num2str(i)));
    disp(strcat("hopf_cnt : ",num2str(hopf_cnt)));%確認
    disp(strcat("snic_cnt : ",num2str(snic_cnt)));%

    end

    %hopfList = [hopfList hopf_cnt];%ベクトルの要素１ずつ増えてく
    %snicList = [snicList snic_cnt];
    %chooseList =[chooseList choose_cnt];

    %disp(strcat("hopf_cnt : ",num2str(hopf_cnt)));
    %disp(strcat("snic_cnt : ",num2str(snic_cnt)));

%end
%nexttile;
%yyaxis left
%p1 = plot(chooseList,hopfList, "-o", 'MarkerFaceColor',[0.3010 0.7450 0.9330]);
%ylabel('Hopf probability[%]');
%ylim([0 100]);

%yyaxis right
%plot(chooseList,snicList, "-o", 'MarkerFaceColor',[0.9900 0.53250 0.2980]);
%ylabel('SNIC probability[%]');
%ylim([0 100]);

%title(strcat("Bifurcation probability"));

%xlabel('parameter numbers');
%xlim([0 70]);

