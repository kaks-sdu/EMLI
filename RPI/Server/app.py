from flask import Flask, render_template
import matplotlib.pyplot as plt
import csv

app = Flask(__name__)

@app.route('/')
def index():
	timestamps, plant_water_alarm_values, pump_water_alarm_values, moisture_values, light_values = read_sensor_values()

	generate_graph(timestamps, plant_water_alarm_values, pump_water_alarm_values, moisture_values, light_values)

	plant_water_alarm = 'Yes' if plant_water_alarm_values[-1] == '1' else 'No'
	pump_water_alarm = 'Yes' if pump_water_alarm_values[-1] == '1' else  'No'

	return render_template('graph.html', plant_water_alarm=plant_water_alarm, pump_water_alarm=pump_water_alarm)

def read_sensor_values():
	timestamps = []
	plant_water_alarm_values = []
	pump_water_alarm_values = []
	moisture_values = []
	light_values = []

	with open('output.csv', 'r') as file:
		reader = csv.reader(file)
		next(reader)
		for row in reader:
			timestamp = row[0]
			pico_id = row[1]
			plant_water_alarm = row[2]
			pump_water_alarm = row[3]
			moisture = row[4]
			light = row[5]
			timestamps.append(timestamp)
			plant_water_alarm_values.append(plant_water_alarm)
			pump_water_alarm_values.append(pump_water_alarm)
			moisture_values.append(moisture)
			light_values.append(light)
		return timestamps, plant_water_alarm_values, pump_water_alarm_values, moisture_values, light_values

def generate_graph(timestamps, plant_water_alarm_values, pump_water_alarm_values, moisture_values, light_values):
	# Moisture
	plt.figure(figsize=(12,6))
	plt.plot(timestamps, moisture_values)
	plt.xlabel('Timestamp')
	plt.ylabel('Moisture Value')
	plt.title('Moisture Sensor Values Over Time')
	plt.savefig('static/moisture_graph.png')
	plt.close()

	# Light
	plt.figure(figsize=(12, 6))
	plt.plot(timestamps, light_values)
	plt.xlabel('Timestamps')
	plt.ylabel('Light Value')
	plt.title('Light Sensor Values Over Time')
	plt.savefig('static/light_graph.png')
	plt.close()

if __name__ == '__main__':
	app.run(debug=True, host='0.0.0.0')
