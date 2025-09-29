% Parameter Definitions
n = 10;
kx_o = 1;
ky_o = 1;
kz_o = 1;
dx_o = 0.1;
dy_o = 0.1;
dz_o = 0.1;
K = 1;
pars_o = [kx_o ky_o kz_o dx_o dy_o dz_o];
pars = pars_o;

% Simulate the system over time
simulationTime = 2000;
tspan = [0 simulationTime];
X0 = [0; 1; 2]; % Initial conditions

%Original period
P = 39.7018;

% reduced f value
fval = 0.3;

% specifying changed values
changedval = [1 2 4 5];

% Define the System of ODEs
dxdt = @(t, X) [
    (pars(1) * K^n / (K^n + X(3)^n) - pars(4) * X(1))*P/24;
    (pars(2) * X(1) - pars(5) * X(2))*P/24;
    (pars(3) * X(2) - pars(6) * X(3))*P/24
    ];
f = fval;
for idx = changedval
    pars(idx) = pars_o(1)*f;
end

% Define the System of ODEs
dxdt2 = @(t, X) [
    (pars(1) * K^n / (K^n + X(3)^n) - pars(4) * X(1))*P/24;
    (pars(2) * X(1) - pars(5) * X(2))*P/24;
    (pars(3) * X(2) - pars(6) * X(3))*P/24
    ];


figure;
tiledlayout(4, 3);

amplist = []; % Initialize amplist to store amplitude values
Tlist = [];   % Initialize Tlist to store period values

lowPeriod = 10;
highPeriod = 60;

for T=lowPeriod:0.25:highPeriod% external period
    disp("T="+num2str(T));
    time =[];
    val = [];


    cycles = round(simulationTime/T); %number of cycles

    for i = 0:cycles
        cnt =1;

        if i==0
            [t, x] = ode45(dxdt,[T*i T*i+1], X0);
            time = t;
            val = x;
        else
            [t,x]=ode45(dxdt,[T*i T*i+1],x(end,:));
            time = [time; t(2:end)];
            val = [val; x(2:end,:)];
        end

        cnt =1;

        [t,x]=ode45(dxdt2,[T*i+1 T*(i+1)],x(end,:));
        time = [time; t(2:end)];
        val = [val; x(2:end,:)];

    end

    if mod(T,round((highPeriod-lowPeriod)/9))==0
        nexttile;
        plot(time(1:end), val(1:end,1));
    end
    title("T:"+num2str(T));
    amplist = [amplist, std(val(time>max(time)*0.8,1))] ;
    Tlist = [Tlist, T];
end

nexttile;
plot(Tlist, amplist);
xticks([0 24 48]);

changedvalName = "";
for idx = changedval
    if idx == 1
        changedvalName = changedvalName+"_kx";
    end
    if idx == 2
        changedvalName = changedvalName+"_ky";
    end
    if idx == 3
        changedvalName = changedvalName+"_kz";
    end
    if idx == 4
        changedvalName = changedvalName+"_dx";
    end
    if idx == 5
        changedvalName = changedvalName+"_dy";
    end
    if idx == 6
        changedvalName = changedvalName+"_dz";
    end
end
exportgraphics(gcf, 'goodwin'+changedvalName+"_f"+num2str(f)+".pdf", 'ContentType', 'vector');

% Measure period
%[pks, locs] = findpeaks(val(:,1), time);
%periods = locs(2:end)-locs(1:end-1);
%mean(periods(end-3:end))
