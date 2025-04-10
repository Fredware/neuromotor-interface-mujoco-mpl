%% Section 0: Verify your MATLAB version and Working Directory
version_devel = "R2024a";
version_current = strcat("R", version('-release'));
if (version_current ~= version_devel)
    warning("The installed MATLAB version (%s) is different from the version used to develop this code (%s). Beware of deprecated APIs", version_current, version_devel)
else
    disp("The installed MATLAB version is compatible with this code.")
end
cd(fileparts(matlab.desktop.editor.getActiveFilename))

%% Section 1: Start MuJoCo
% The following line will start the MuJoCo-HAPTIX app.
% Once the program opens:
%   1. Load a model
%   2. Click the "Run" button in MuJoCo.
system("..\mujoco-app\program\mjhaptix.exe &")

%% Section 2: Clear your MATLAB workspace from previous session data
% Terminate existing arduino connections. If closing arduino fails, do nothing.
try arduino_uno.close; catch; end
% Clear program variables and clear the workspace display
close all; clear all; clc; 

%% Section 3: Connect MuJoCo to MATLAB
% You should have MuJoCo open with a model loaded and running before
% starting this code!  If your code is crashing during this section, try
% the following: Close MuJoCo, Open MuJoCo, Open Model, Play MuJoCo, Run
% MATLAB Code.
[joint_positions, joint_groups, mujoco_command, mujoco_connected] = mujoco_pkg.connect_hand();

%% Section 4: Set up serial communication with the SpikerShield
[arduino_uno, uno_connected] = arduino_pkg.connect_board();

%% Section 5: Set up the real-time plots
fs = arduino_uno.SAMPLING_FREQ;
n_emg_chans = arduino_uno.N_CHANS;
n_control_chans = n_emg_chans;
mujoco_sensors = zeros(19,6); % 19 sensors x 6-sample window
session_timestamps = [];

% Set up real-time plot
main_fig = rtplot_pkg.initialize_figure(n_emg_chans, n_control_chans, 0, false);

%Set up data buffers
[emg_buffer, control_buffer, force_buffer, freq_buffer] = initialize_data_structures(n_emg_chans, n_control_chans);

% Variables to monitor loop update rate
t_loop = [];
i_loop = 0;

% Signal Conditioning
f_pli = 60; % Powerline interference frequency in [Hz]
ffc_lag = ceil(fs/f_pli); % Number ofs samples to remove PLI with FFC filter

% Control Parameters
mav_win_len = 300e-3 * fs; % MAV window in [ms]
control_gain = 10;
control_bias = -0.15;

%% Section 6: Real-time control
while (ishandle(main_fig.handle))
    tic
    pause(0.02)
    
    % REQUEST EMG SAMPLES FROM THE ARDUINO
    try
        % Request samples from arduino serial
        emg_samples = arduino_uno.get_recent_emg;
        if ~isempty(emg_samples)
            % Save data to buffer
            emg_sample_count = size(emg_samples, 1);
            emg_buffer.data(emg_buffer.ptr:emg_buffer.ptr + emg_sample_count-1,:) = emg_samples;
            % Update buffer pointers
            emg_buffer.ptr = emg_buffer.ptr + emg_sample_count;
            control_buffer.ptr = control_buffer.ptr + 1;
            force_buffer.ptr = force_buffer.ptr + 1;
        end
    catch
        fprintf("\t\tData Acquisition Failed\n")
    end

    % IF WE GOT EMG SAMPLES: 
    %   1) CALCULATE CONTROL VALUE
    %   2) UPDATE THE REAL-TIME PLOT
    %   3) SEND CONTROL VALUE TO THE MUJOCO HAND
    if ~isempty(emg_samples)
        timestamp = (emg_buffer.ptr - 1)/fs;

        % 1) CALCULATE CONTROL VALUE
        try
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%% YOUR CODE GOES HERE %%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Calculate a 1x1 scalar value (i.e., no matrices or vectors).
            try
            % control_value = rand(1)*emg_buffer.data(emg_buffer.ptr-300:emg_buffer.ptr-1); % Replace this line
            emg_start_idx = emg_buffer.ptr-mav_win_len;
            emg_stop_idx = emg_buffer.ptr-1;
            raw_emg = emg_buffer.data(emg_start_idx:emg_stop_idx,:);
            delayed_emg = emg_buffer.data(emg_start_idx-ffc_lag:emg_stop_idx-ffc_lag,:);
            filt_emg = raw_emg - delayed_emg;
            mav_feature = mean(abs(filt_emg - mean(filt_emg)));
            control_value = control_gain*(mav_feature+control_bias);
            if (control_value) > 1
                control_value = 1;
            elseif control_value < 0
                control_value = 0;
            end
            % CTRL_THRESH = 0.5;
            % if(CTRL_THRESH>0)
            %     ctrl_value = control_value > 0.5;
            % end
            catch
                control_value = 0;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            assert( ...
                isequal( size(control_value), [1 1]), ...
                sprintf( "Incorrect control size: Expected [1 1], got [%d %d] instead.", size(control_value)) ...
            )
            control_buffer.data(control_buffer.ptr, :) = control_value;
            force_buffer.data(force_buffer.ptr, :) = max(mujoco_sensors(:,1));
        catch
            fprintf("\t\tControl Computation Failed\n")
        end
        session_timestamps = [session_timestamps; timestamp];

        % 2) UPDATE PLOT
        if(ishandle(main_fig.handle))
            main_fig = rtplot_pkg.update_figure(main_fig, timestamp, emg_buffer, control_buffer, force_buffer, freq_buffer, 0, false);
            emg_buffer.ptr_prev = emg_buffer.ptr;
        end

        % 3) UPDATE HAND
        if mujoco_connected
            % Send control value to hand
            mujoco_status = mujoco_pkg.update_hand(control_buffer, joint_groups, joint_positions, mujoco_command);

            % Read MuJoCo force sensors
            mujoco_sensors = circshift(mujoco_sensors, [0,1]);
            mujoco_sensors(:,1) = mujoco_status.contact;
        end
    end
    i_loop = i_loop + 1;
    t_loop(i_loop) = toc;
end
arduino_uno.close;

%% Section 7: (Optional) Plot data
fig_handle = plot_session_data(emg_buffer, control_buffer, session_timestamps, fs);

%% Section 8: (Optional) Save session data
% Generate a unique filename using the computer's date and time information
filename = sprintf( ".\\saved_data\\session_%s.mat", ...
                    datetime('now', Format='uuuuMMdd_HHmmss') ...
                  );

% Save the buffer variables. 
% Note: Recall the buffers are initialized to NaNs. You will have to
%       remove/ignore the unchanged NaN values when you load the data.
save(filename, "emg_buffer", "control_buffer", "session_timestamps", "fs");
fprintf("Saved data in: %s", filename)
