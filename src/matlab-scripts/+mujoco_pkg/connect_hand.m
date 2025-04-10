function [joint_positions, joint_groups, command, mujoco_connected] = connect_hand()
%CONNECT_HAND Summary of this function goes here
%   Detailed explanation goes here
fprintf('%s\n\t', repmat('=', 1, 80))
disp("Attempting Connection with MuJoCo")
try
    addpath(regexprep(pwd, "matlab-scripts", "mujoco-app\\apimex"))
    hx_close
    hx_connect('')

    % Set up inital configuration of the hand
    joint_positions = [ 
        0; ...     %(01) wrist pronation/supination
        0; ...     %(02) wrist deviation
        0; ...     %(03) wrist flexion/extension
        1.62; ...  %(04) thumb abduction/adduction
        0; ...     %(05) thumb flexion/extension (at base)
        0; ...     %(06) thumb flexion/extension (at first joint - most proximal)
        0; ...     %(07) thumb flexion/extension (at last joint - most distal)
        0; ...     %(08) index abduction/adduction
        0; ...     %(09) index flexion/extension
        0; ...     %(10) middle flexion/extension
        0; ...     %(11) ring flexion/extension
        0; ...     %(12) pinky abduction/adduction
        0;];       %(13) pinky flexion/extension

    % Set up command
    command = struct( 'ref_pos', joint_positions, ...        %reference position
        'ref_vel', zeros(13,1), ...
        'gain_pos', zeros(13,1), ...
        'gain_vel', zeros(13,1), ...
        'ref_pos_enabled', 1, ...
        'ref_vel_enabled', 0, ...
        'gain_pos_enabled', 0, ...
        'gain_vel_enabled', 0);

    % Set the groups of joints to be controlled using the join_positions
    % indices
    joint_groups = struct( ...
        'all_fingers', [5, 6, 7, 8, 9, 10, 11, 12, 13], ...
        'wrist_flexion', [3] ...
        );

    mujoco_connected = true;
    fprintf("\t\tRobot Information:\n")
    disp(hx_robot_info)
    fprintf("\t\tMuJoCo Connection Established\n")
catch
    joint_positions = NaN;
    command = NaN;
    joint_groups = NaN;
    mujoco_connected = false;
    fprintf("\t\tMuJoCo Connection Failed\n")
end
end

