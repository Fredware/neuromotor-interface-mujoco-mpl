function status = update_hand(control_buffer, joint_groups, joint_positions, mujoco_command)
%UPDATE_HAND Summary of this function goes here
%   Detailed explanation goes here
control_values = control_buffer.data(control_buffer.ptr, :);

control_values(control_values >  1) =  1;
control_values(control_values < -1) = -1;
control_values(isnan(control_values)) = 0;

joint_positions(joint_groups.all_fingers) = control_values;
mujoco_command.ref_pos = joint_positions;
status = hx_update(mujoco_command);
end

