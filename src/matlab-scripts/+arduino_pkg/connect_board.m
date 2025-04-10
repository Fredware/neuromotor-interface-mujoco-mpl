function [board, connected] = connect_board(varargin)
% This function sets up the communication between matlab and the arduino,
% for *two* EMG channels.
% 'uno' is a serial communication MATLAB object that is used to get the data
% from the arduino, and 'connected' is a flag specifying if the
% connection was made.
%
% Version: F. Mino 2023/07/20  

fprintf('%s\n\t', repmat('=', 1, 80))
disp("Attempting Connection with Arduino")
try
    if nargin
        % Pass COM port string if specified
        board = serial_pkg.SerialComm(varargin); 
    else
        board = serial_pkg.SerialComm();
    end
    connected = true;
    fprintf("\t\tArduino Connection Established\n")
catch
    board = NaN;
    connected = false;
    fprintf("\t\tArduino Connection Failed\n")
end
end