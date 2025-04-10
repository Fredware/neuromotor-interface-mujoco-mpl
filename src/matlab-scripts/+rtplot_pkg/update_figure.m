function fig = update_figure(fig, timestamp, emg_buffer, ctrl_buffer, force_buffer, freq_buffer, ctrl_thresh, stim_connected)

for i=1:fig.n_rec
    addpoints(fig.axes{1}.line_handles{i}, timestamp, max( emg_buffer.data(emg_buffer.ptr_prev:emg_buffer.ptr-1, i)));
    addpoints(fig.axes{1}.line_handles{i}, timestamp, min( emg_buffer.data(emg_buffer.ptr_prev:emg_buffer.ptr-1, i)));
end

for i=1:fig.n_ctrl
     addpoints(fig.axes{2}.line_handles{i}, timestamp, ctrl_buffer.data(ctrl_buffer.ptr, i));
end

% for i=1:fig.n_ctrl
%     addpoints(fig.line_handles{fig.n_rec+i}, timestamp, ctrl_buffer.data(ctrl_buffer.ptr, i));
% end
% 
% for i=1:fig.n_opt
%     if i==1 && stim_connected
%         addpoints(fig.line_handles{fig.n_rec+fig.n_ctrl+i}, timestamp, freq_buffer.data(freq_buffer.ptr));
%     else
%         addpoints(fig.line_handles{fig.n_rec+fig.n_ctrl+i}, timestamp, force_buffer.data(force_buffer.ptr));
%     end
% end

if timestamp > fig.t_max
    fig.t_max = fig.t_max + 5;
    fig.t_min = fig.t_min + 5;
    xlim(fig.axes{1}.handle, [fig.t_min, fig.t_max])
    % for i=1:length(fig.axes_handles)
    %     xlim(fig.axes_handles{i},[fig.t_min fig.t_max])
    % end
    if ctrl_thresh > 0
        for i=1:fig.n_ctrl
            subplot(fig.n_rec+i)
            hold on;
            plot([fig.t_min, fig.t_max], [ctrl_thresh, ctrl_thresh], Color="blue");
        end
    end
end
drawnow limitrate %update the plot, but limit update rate to 20 fps
end