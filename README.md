# EMLI

To run the RPI scripts we need to install bc for floating point comparison with `sudo apt-get install bc`

Test the system by running `./Tests/send_example_sensor_values.sh | tee >(./RPI/control_pump.sh) >(./RPI/mqtt_publish.sh)` where 1 is the ID of the pump you want to test.