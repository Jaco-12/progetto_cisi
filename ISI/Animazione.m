%% ----- Animazione Modello Funivia ----- %%
close all

% ENTRAMBI NON POSSONO ESSERE TRUE
multiplot = true;  %<------------ NEW VARIABLE TO SET MULTIPLOT OPTION
innovaz_plot = false;

dt  =  0.1;

% Creazione figura
f = figure;
f.WindowState = 'maximized';

% Estrazione Dati da Simulink
q = out.q.Data;
z = out.z.Data;
tout = out.tout;

% Retrieve EKF data from simulink
% https://it.mathworks.com/help/simulink/slref/toworkspace.html
q_hat_computed = get(out, "q_hat_computed");
q_true = get(out, "q_true");
x_error = get(out, "x_error");
theta_error = get(out, "theta_error");

% Innovazione misure EKF
e_k_D = get(out, "e_k_D");
e_k_d1 = get(out, "e_k_d1");
e_k_omega = get(out, "e_k_omega");

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
if (multiplot | innovaz_plot)
    subplot(3, 2, [1, 2]);
end

hold on
axis equal
axis ([-5 30 -7 3])
grid on
title('Moto Funivia')

% Parametri Cabina %
high_cab = 1;
width_cab = 2;
bar = 0.05;         

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
R_r(4) = rectangle('Position', [q_pp(1,1) - (l+r)*sin(q_pp(3,1)) - r, -(q_pp(2,1) - (l+r)*cos(q_pp(3,1)) + r), 2*r, 2*r], 'Curvature', [1,1], 'EdgeColor', 'r', 'LineWidth', 2);

i_sampled = 1;   % indice per il sampling dei grafici

%% Plot Dinamico Funivia (multi_plot)%%
if multiplot
    for i = 1:1:size(q_pp,2)
        subplot(3, 2, [1, 2]);
        cla;
        
        line([q_pp(1,i)-5, q_pp(1,i)+30], [0, 0], 'LineStyle','-','Color','k','LineWidth',1);
        line([q_pp(1,i)-5, q_pp(1,i)+30], [-1.2, -1.2], 'LineStyle','-','Color','k','LineWidth',1);
    
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
        R_r(4) = rectangle('Position', [q_pp(1,i) - (l+r)*sin(q_pp(3,i)) - r, -(q_pp(2,i) - (l+r)*cos(q_pp(3,i)) + r), 2*r, 2*r], 'Curvature', [1,1], 'EdgeColor', 'r', 'LineWidth', 2);
    
        % Aggiorno gli assi con la coordinata della cabina
        xlim([q_pp(1,i) - 5, q_pp(1,i) + 30]);
        ylim([-(q_pp(2,i) + 7), -(q_pp(2,i) - 3)]);
    
        % Plot q_hat_computed(3) beneath the main plot
        i_sampled = round(i_sampled + (dt/min_sample_rates));
        subplot(3,2,3);
        hold on
        plot(q_hat_computed.Time(1:i_sampled), q_hat_computed.Data(1:i_sampled, 3), 'b', 'LineWidth', 1, 'DisplayName', "x\_EKF");
        plot(q_true.Time(1:i_sampled), q_true.Data(1, 1:i_sampled), 'g', 'LineWidth', 1, 'DisplayName', "x\_true");
        plot(q_true.Time(1:i_sampled), q_k_n(3, 1:i_sampled), 'r', 'LineWidth', 1, 'DisplayName', "x\_smooth\_EKF");
        title('x\_hat vs x\_true vs x\_smooth\_EKF');
        xlabel('Time');
        ylabel('x [m]');
        grid on;
        legend("x EKF", "x true", "x smooth EKF");
        
        % Plot q_hat_computed(4) beneath the main plot
        subplot(3,2,4);
        hold on
        plot(q_true.Time(1:i_sampled), q_hat_computed.Data(1:i_sampled, 4), 'b', 'LineWidth', 1, 'DisplayName', "theta\_EKF");
        plot(q_true.Time(1:i_sampled), q_true.Data(2, 1:i_sampled), 'g', 'LineWidth', 1, 'DisplayName', "theta\_true");
        plot(q_true.Time(1:i_sampled), q_k_n(4, 1:i_sampled), 'r', 'LineWidth', 1, 'DisplayName', "theta\_smooth\_EKF");
        title('theta\_hat vs theta\_true vs theta\_smooth\_EKF');
        xlabel('Time');
        ylabel('theta [rad]');
        grid on;
        legend("theta\_EKF", "theta\_true", "theta\_smooth\_EKF");
    
        % Plot x_error
        subplot(3,2,5);
        hold on
        plot(x_error.Time(1:i_sampled), x_error.Data(1, 1:i_sampled), 'r', 'LineWidth', 1, 'DisplayName', "x_error");
        title('x\_error (EKF - true)');
        xlabel('Time');
        ylabel('x [m]');
        grid on;
        legend("x error");
        
        % Plot theta_error
        subplot(3,2,6);
        hold on
        plot(theta_error.Time(1:i_sampled), theta_error.Data(1, 1:i_sampled), 'r', 'LineWidth', 1, 'DisplayName', "theta_error");
        title('theta\_error (EKF - true)');
        xlabel('Time');
        ylabel('theta [rad]');
        grid on;
        legend("theta error");
    
        %legend('Location', 'best');
        drawnow
        
        pause(0.005)
        
    end
end
if innovaz_plot
    for i = 1:1:size(q_pp,2)
        subplot(3, 2, [1, 2]);
        cla;
        
        line([q_pp(1,i)-5, q_pp(1,i)+30], [0, 0], 'LineStyle','-','Color','k','LineWidth',1);
        line([q_pp(1,i)-5, q_pp(1,i)+30], [-1.2, -1.2], 'LineStyle','-','Color','k','LineWidth',1);
    
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
        R_r(4) = rectangle('Position', [q_pp(1,i) - (l+r)*sin(q_pp(3,i)) - r, -(q_pp(2,i) - (l+r)*cos(q_pp(3,i)) + r), 2*r, 2*r], 'Curvature', [1,1], 'EdgeColor', 'r', 'LineWidth', 2);
    
        % Aggiorno gli assi con la coordinata della cabina
        xlim([q_pp(1,i) - 5, q_pp(1,i) + 30]);
        ylim([-(q_pp(2,i) + 7), -(q_pp(2,i) - 3)]);
    
        % Plot innovazione D
        i_sampled = round(i_sampled + (dt/min_sample_rates));
        subplot(3,2,3);
        hold on
        plot(e_k_D.Time(1:i_sampled), e_k_D.Data(1:i_sampled), 'b', 'LineWidth', 1, 'DisplayName', "e_k_D");
        title('Innovazione misura D');
        xlabel('Time');
        ylabel('[m]');
        grid on;
        legend("e\_k\_D");
        
        % Plot innovazione d1
        subplot(3,2,4);
        hold on
        plot(e_k_d1.Time(1:i_sampled), e_k_d1.Data(1:i_sampled), 'b', 'LineWidth', 1, 'DisplayName', "e\_k\_d1");
        title('Innovazione misura d1');
        xlabel('Time');
        ylabel('[m]');
        grid on;
        legend("e\_k\_d1");
    
        % Plot innovazione omega_enc
        subplot(3,2,[5, 6]);
        hold on
        plot(e_k_omega.Time(1:i_sampled), e_k_omega.Data(1:i_sampled), 'b', 'LineWidth', 1, 'DisplayName', "e\_k\_omega");
        title('Innovazione misura omega');
        xlabel('Time');
        ylabel('[Rad/s]');
        grid on;
        legend("e\_k\_omega");
        
        drawnow
        
        pause(0.005)
        
    end
end
if (~multiplot & ~innovaz_plot)     
    %% Plot Dinamico Funivia  (single plot)%%
    for i = 1:1:size(q_pp,2)
        cla;
        
        line([q_pp(1,i)-5, q_pp(1,i)+30], [0, 0], 'LineStyle','-','Color','k','LineWidth',1);
        line([q_pp(1,i)-5, q_pp(1,i)+30], [-1.2, -1.2], 'LineStyle','-','Color','k','LineWidth',1);
    
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
        R_r(4) = rectangle('Position', [q_pp(1,i) - (l+r)*sin(q_pp(3,i)) - r, -(q_pp(2,i) - (l+r)*cos(q_pp(3,i)) + r), 2*r, 2*r], 'Curvature', [1,1], 'EdgeColor', 'r', 'LineWidth', 2);
    
        % Aggiorno gli assi con la coordinata della cabina
        xlim([q_pp(1,i) - 5, q_pp(1,i) + 30]);
        ylim([-(q_pp(2,i) + 7), -(q_pp(2,i) - 3)]);
   
        drawnow
        
        pause(0.005)
        
    end
end
