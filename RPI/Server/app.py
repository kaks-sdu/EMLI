from flask import Flask, render_template, jsonify
import csv

app = Flask(__name__)

def read_sensor_values():
    timestamps = []
    plant_water_alarms = []
    pump_water_alarms = []
    moisture_values = []
    light_values = []

    with open('sensor_values.csv', 'r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        for row in reader:
            timestamp, pico_id, plant_water_alarm, pump_water_alarm, moisture, light = row[0].split(',')
            timestamps.append(timestamp)
            plant_water_alarms.append(plant_water_alarm)
            pump_water_alarms.append(pump_water_alarm)
            moisture_values.append(float(moisture))
            light_values.append(float(light))

    return timestamps, plant_water_alarms, pump_water_alarms, moisture_values, light_values

@app.route('/')
def index():
    timestamps, plant_water_alarms, pump_water_alarms, moisture_values, light_values = read_sensor_values()
    return render_template('graph.html', plant_water_alarm=plant_water_alarms[-1], pump_water_alarm=pump_water_alarms[-1])

@app.route('/update')
def update():
    timestamps, plant_water_alarms, pump_water_alarms, moisture_values, light_values = read_sensor_values()
    data = {
        'timestamps': timestamps,
        'moisture_values': moisture_values,
        'light_values': light_values
    }
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
