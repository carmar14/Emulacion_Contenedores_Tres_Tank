% Configuración de la conexión UDP
udpServer = udpport("LocalPort", 8889);

% Preparar la figura para la visualización
figure;
t = tiledlayout(2,1);

% Ejes para los estados
ax1 = nexttile;
title(ax1, 'Estados de los Tanques');
xlabel(ax1, 'Tiempo (s)');
ylabel(ax1, 'Altura');
hold(ax1, 'on');
grid(ax1, 'on');
x1_plot = plot(ax1, NaN, NaN, '-r', 'DisplayName', 'x1');
x2_plot = plot(ax1, NaN, NaN, '-g', 'DisplayName', 'x2');
x3_plot = plot(ax1, NaN, NaN, '-b', 'DisplayName', 'x3');
legend(ax1);

% Ejes para las acciones de control
ax2 = nexttile;
title(ax2, 'Acciones de Control');
xlabel(ax2, 'Tiempo (s)');
ylabel(ax2, 'Control');
hold(ax2, 'on');
grid(ax2, 'on');
u1_plot = plot(ax2, NaN, NaN, '-m', 'DisplayName', 'u1');
u2_plot = plot(ax2, NaN, NaN, '-c', 'DisplayName', 'u2');
legend(ax2);

% Variables para almacenar los datos
time = [];
x1_data = [];
x2_data = [];
x3_data = [];
u1_data = [];
u2_data = [];
startTime = tic;

% Loop para recibir y visualizar datos
while true
    % Recibir datos del ESP32
    data = readline(udpServer);

    % Parsear los datos
    data = char(data);
    tokens = split(data, ',');
    x1 = str2double(extractAfter(tokens(1), "x1:"));
    x2 = str2double(extractAfter(tokens(2), "x2:"));
    x3 = str2double(extractAfter(tokens(3), "x3:"));
    u1 = str2double(extractAfter(tokens(4), "u1:"));
    u2 = str2double(extractAfter(tokens(5), "u2:"));
    
    % Actualizar datos
    elapsed = toc(startTime);
    time = [time, elapsed];
    x1_data = [x1_data, x1];
    x2_data = [x2_data, x2];
    x3_data = [x3_data, x3];
    u1_data = [u1_data, u1];
    u2_data = [u2_data, u2];
    
    % Actualizar gráficos
    set(x1_plot, 'XData', time, 'YData', x1_data);
    set(x2_plot, 'XData', time, 'YData', x2_data);
    set(x3_plot, 'XData', time, 'YData', x3_data);
    set(u1_plot, 'XData', time, 'YData', u1_data);
    set(u2_plot, 'XData', time, 'YData', u2_data);
    
    drawnow;
end
