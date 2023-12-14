%% ----- Animazione Modello Funivia ----- %%
close all

dt  =  0.03;

% Creazione figura
f = figure;
f.WindowState = 'maximized';

% Estrazione Dati da Simulink
q = out.q.Data;
z = out.z.Data;
tout = out.tout;

% Ricampionamento temporale a dt
time  =  0 : dt : tout(end);
q_pp  =  zeros(size(q,1),size(time,2));
for i  =  1 : size(time,2)
    [d, ix]  =  min(abs(tout-time(i)));
    q_pp(1,i)  =  q(1, ix);
    q_pp(2,i)  =  z(1, ix);
    q_pp(3,i)  =  q(2, ix);
end

%% Movimento Funivia %%

hold on
axis equal
axis ([-5 30 -7 3])
grid on
title('Moto Funivia')

% Parametri Cabina %
high_cab = 1;
width_cab = 2;
bar = 0.05;
pul = 0.08;         

% Geometria Punti di Interesse %
rect_x = q_pp(1,1) + h*sin(q_pp(3,1)) - width_cab/2;
rect_z = -(q_pp(2,1) + h*cos(q_pp(3,1)) + high_cab/2);

y_x = q_pp(1,1) + h*sin(q_pp(3,1));
y_z = -(q_pp(2,1) + h*cos(q_pp(3,1)));

end_asta_x = q_pp(1,1) - L*sin(q_pp(3,1));
end_asta_z = -(q_pp(2,1) - L*cos(q_pp(3,1)));


% Traiettoria Baricentro %
R_l(1) = plot(q_pp(1,1), -q_pp(2,1), 'LineStyle', '-', 'Color', [0.2 .7 .5], 'LineWidth', 1);
% Cabina %
R_r(1) = rectangle('Position', [rect_x, rect_z, width_cab, high_cab], 'EdgeColor', 'g', 'LineWidth', 3);
% Giunto Cabina-Fune %
R_r(2) = line([y_x; end_asta_x], [y_z; end_asta_z], 'LineStyle', '-', 'Color', 'g', 'LineWidth', 3);
% Posizione Baricentro %
R_r(3) = rectangle('Position', [q_pp(1,1) - bar/2, -(q_pp(2,1) + bar/2), bar, bar], 'Curvature', [1,1], 'EdgeColor', 'b', 'LineWidth', 2);
% Posizione Puleggia Cabina %
R_r(4) = rectangle('Position', [q_pp(1,1) - l*sin(q_pp(3,1)) - pul/2, -(q_pp(2,1) - l*cos(q_pp(3,1)) + pul/2), pul, pul], 'Curvature', [1,1], 'EdgeColor', 'r', 'LineWidth', 2);

%% Plot Dinamico Funivia %%
for i=1:1:size(q_pp,2)
    
    cla;

    line([-5, 30], [0, 0], 'LineStyle','-','Color','k','LineWidth',1);
    line([-5, 30], [-1.2, -1.2], 'LineStyle','-','Color','k','LineWidth',1);

    % Geometria Punti di Interesse %
    rect_x(i) = q_pp(1,i) + h*sin(q_pp(3,i)) - width_cab/2;
    rect_z(i) = -(q_pp(2,i) + h*cos(q_pp(3,i)) + high_cab/2);

    y_x(i) = q_pp(1,i) + h*sin(q_pp(3,i));
    y_z(i) = -(q_pp(2,i) + h*cos(q_pp(3,i)));

    end_asta_x(i) = q_pp(1,i) - L*sin(q_pp(3,i));
    end_asta_z(i) = -(q_pp(2,i) - L*cos(q_pp(3,i)));


    R_l(1) = plot(q_pp(1,1:i), -q_pp(2,1:i), 'LineStyle', '-', 'Color', [0.2 .7 .5], 'LineWidth', 1);
    R_r(1) = rectangle('Position', [rect_x(i), rect_z(i), width_cab, high_cab], 'EdgeColor', 'g', 'LineWidth', 3);
    R_r(2) = line([y_x(i); end_asta_x(i)], [y_z(i); end_asta_z(i)], 'LineStyle', '-', 'Color', 'g', 'LineWidth', 3);
    R_r(3) = rectangle('Position', [q_pp(1,i) - bar/2, -(q_pp(2,i) + bar/2), bar, bar], 'Curvature', [1,1], 'EdgeColor', 'b', 'LineWidth', 2);
    R_r(4) = rectangle('Position', [q_pp(1,i) - l*sin(q_pp(3,i)) - pul/2, -(q_pp(2,i) - l*cos(q_pp(3,i)) +pul/2), pul, pul], 'Curvature', [1,1], 'EdgeColor', 'r', 'LineWidth', 2);
    
    drawnow
    pause(dt)
    
end
