function tlo = plot_session_data(emg_buffer, control_buffer, session_timestamps, fs)
tlo  = tiledlayout(2,1);

ax1 = nexttile;
emg_data = emg_buffer.data(~isnan(emg_buffer.data));
emg_time = (0:1:length(emg_data)-1)'/fs;
plot(emg_time, emg_data);
title('EMG Vs. Time')
xlabel('Time [sec]')
ylabel('EMG [V]')
ylim([-3.0, 3.0])
yticks(linspace(-2.5,2.5,0.5))
ytickformat('%.02f')
legend('Channel 01 EMG')
box off

ax2 = nexttile;
control_data = control_buffer.data(~isnan(control_buffer.data));
control_time = session_timestamps;
plot(control_time, control_data)
title('Control Signal Vs. Time')
xlabel('Time [sec]')
ylabel('?? [??]')
legend('Control Signal')
box off

linkaxes([ax1, ax2], 'x')
end