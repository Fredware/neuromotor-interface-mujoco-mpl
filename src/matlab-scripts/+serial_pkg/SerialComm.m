classdef SerialComm < handle
    % This class for connecting to, reading from, and closing the BYB
    % SpikerShield
    %
    % Version: 20210222
    % Author: Tyler Davis
    %
    % Version: 20230710
    % Author: Fredi Mino
    
    properties
        arduino_board; 
        port_number;
        sample_count; 
        data_buffer;
        status;
        is_ready;
        
        % These properties must match the values in the arduino sketch.
        SAMPLING_FREQ = 1140; % [Hz]
        BAUD_RATE = 57600;
        N_CHANS = 1;
        MESSAGE_FORMAT = "%04d"; 
    end
    
    methods
        function obj = SerialComm( varargin)
            
            obj.is_ready = false;

            % Buffer size = [(n_samples = 2 sec @ 1 kHz), (n_chans)]
            N_SAMPLES = 2000;
            obj.data_buffer = zeros(N_SAMPLES, obj.N_CHANS);
            
            obj.status.elapsed_time = nan;
            obj.status.current_time = clock;
            obj.status.prior_time = clock;
            obj.sample_count = 0;
            
            % Optional args:            
            % {1}: COM port number
            if nargin > 0
                com_port = varargin{1};
                init( obj, com_port);
            else
                init( obj);
            end
        end
        
        function init( obj, varargin)
            if nargin > 1
                com_port = varargin{1};
                if ~isempty( com_port)
                    obj.port_number = sprintf( 'COM%0.0f', com_port{1});
                end
            else
                devs = serial_pkg.get_serial_id;
                if ~isempty(devs)
                    com_port = cell2mat(devs(~cellfun(@isempty,regexp(devs(:,1),'Arduino Uno')),2));
                    if ~isempty(com_port)
                        obj.port_number = sprintf('COM%0.0f',com_port(1));
                    else
                        com_port = cell2mat(devs(~cellfun(@isempty,regexp(devs(:,1),'USB-SERIAL CH340')),2));
                        if ~isempty(com_port)
                            obj.port_number = sprintf('COM%0.0f',com_port(1));
                        end
                    end
                end
            end
            delete(instrfind('port',obj.port_number));
            obj.arduino_board = serialport(obj.port_number, obj.BAUD_RATE, 'Timeout', 1);
            configureCallback(obj.arduino_board,"terminator",@obj.read_serial);
            flush(obj.arduino_board);
            pause(0.1);
            obj.is_ready = true;
        end
        
        function close( obj, varargin)
            if isobject( obj.arduino_board)
                delete( obj.arduino_board);
            end
        end
        
        function read_serial( obj, varargin)
            try
                % read data & update status
                obj.status.data = sscanf( readline( obj.arduino_board), obj.MESSAGE_FORMAT);
                obj.status.current_time = clock;
                obj.status.elapsed_time = etime( obj.status.current_time, obj.status.prior_time);
                obj.status.prior_time = obj.status.current_time;
                
                % store data into buffer row by row
                obj.data_buffer = circshift( obj.data_buffer, [-1 0]);
                obj.data_buffer( end, :) = obj.status.data;
                
                obj.sample_count = obj.sample_count + 1;
            catch
                disp('Serial communication error!')
            end
        end
        
        function emg = get_emg( obj, varargin)
            % - divide by highest value (1023) to normalize signal
            % - multiply by 5 to match the signal recorded by the SpikerShield (0V-5V)
            % - subtract 2.5 V to make the signal zero-centered and undo the
            %   shift introduced by BYB  
            emg = obj.data_buffer / 1023 * 5 - 2.5;
        end
        
        function emg = get_recent_emg( obj, varargin)
            last_sample_idx = size( obj.data_buffer, 1); % return the rows of the buffer
            first_sample_idx = (last_sample_idx - obj.sample_count)+1;
            if first_sample_idx < 1
                first_sample_idx = 1;
            end
            if obj.sample_count == 0
                emg = [];
            else
                emg = obj.data_buffer(first_sample_idx:end,:) / 1023 * 5 - 2.5;
                obj.sample_count = 0;
            end
        end
    end    
end
