from flask import Flask, render_template, jsonify, send_from_directory
import csv
import os

app = Flask(__name__)

def read_sensor_values():
	timestamps = []
	pico_id_values = []
	plant_water_alarm_values = []
	pump_water_alarm_values = []
	moisture_values = []
	light_values = []

	with open('sensor_values.csv', 'r') as file:
		reader = csv.reader(file)
		for row in reader:
			if len(row) != 6:
				continue
			timestamp = row[0]
			pico_id = row[1]
			plant_water_alarm = row[2]
			pump_water_alarm = row[3]
			moisture = row[4]
			light = row[5]
			timestamps.append(timestamp)
			pico_id_values.append(pico_id)
			plant_water_alarm_values.append(plant_water_alarm)
			pump_water_alarm_values.append(pump_water_alarm)
			moisture_values.append(float(moisture))
			light_values.append(float(light))

	return timestamps, pico_id_values, plant_water_alarm_values, pump_water_alarm_values, moisture_values, light_values

@app.route('/')
def index():
	timestamps, pico_id_values, plant_water_alarm_values, pump_water_alarm_values, moisture_values, light_values = read_sensor_values()
	return render_template('graph.html', plant_water_alarm=plant_water_alarm_values[-1], pump_water_alarm=pump_water_alarm_values[-1])

@app.route('/download')
def download():
	filename = 'sensor_values.csv'
	directory = os.getcwd()
	return send_from_directory(directory, filename, as_attachment=True)

@app.route('/update')
def update():
	timestamps, pico_id_values, plant_water_alarm_values, pump_water_alarm_values, moisture_values, light_values = read_sensor_values()
	data = {
		'timestamps': timestamps,
		'pico_id': pico_id_values,
		'moisture_values': moisture_values,
		'light_values': light_values,
		'plant_water_alarm_values': plant_water_alarm_values,
		'pump_water_alarm_values': pump_water_alarm_values
	}
	return jsonify(data)

if __name__ == '__main__':
	app.run(host='0.0.0.0', port=5000)
