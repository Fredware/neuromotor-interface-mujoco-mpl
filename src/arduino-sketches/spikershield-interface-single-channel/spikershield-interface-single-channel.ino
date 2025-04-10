/*********************************/
/* Data Acquisition Configuration*/
#define SAMPLING_FREQ 1140.0 // [Hz]. Sampling frequency needed for using an FFC filter in MATLAB with N=19 while remaining below the standard 57.6e3 baudrate
#define SAMPLING_PERIOD 1.0 / SAMPLING_FREQ // [seconds]
#define CHARS_PER_CHAN 5 // MAX VAL:1023 => 4 DIGITS = (4 CHARS + '\n') = 5 [bytes]
/*** The parameters in this subsection must match the values in MATLAB's SerialComm class.*/
#define MATLAB_BAUD_RATE 57600
#define N_CHANS 1
#define MATLAB_MESSAGE_FORMAT "%04d"
/* Developper Flags*/
#define DEBUG_MODE false
/***/
const int emg_pins[] = {A0}; // Choose any analog pin, but make sure the hardware jumper matches your software.
char serial_buffer[N_CHANS * CHARS_PER_CHAN]; // Allocate space to store the voltages from the analog pins.
/*********************************/

/*********************************/
/* Setup */
void setup(){
  /* Set up serial communication and give it time to initialize */
  Serial.begin(MATLAB_BAUD_RATE);
  delay(10);
}
/*********************************/

/*********************************/
/*Infinite Loop*/
void loop(){
  unsigned long loop_start_time = micros();

  /* Fill buffer with EMG data*/
  sprintf( serial_buffer, MATLAB_MESSAGE_FORMAT, analogRead( emg_pins[0]));
  
  /*Send data over serial*/
  if (DEBUG_MODE){ /*Allows visualization in Arduino Serial Plotter, but breaks MATLAB communication*/
    Serial.print(1024);
    Serial.print(" ");
    Serial.print(100);
    Serial.print(" ");
  }
  Serial.println(serial_buffer);
  
  /* Enforce the sampling rate */
  unsigned long loop_duration = micros() - loop_start_time;
  while( loop_duration < SAMPLING_PERIOD){
    loop_duration = micros() - loop_start_time;
  };
}
/*********************************/