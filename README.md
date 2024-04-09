# NightLight Project: by Ahmad Mhamed,Noor Mahajna and Sham abu-Shtya.
The Night Light for Nursing Homes project aims to improve the sleep quality and nighttime mobility of residents in nursing homes by providing a specialized night light solution. This project addresses the unique needs of elderly individuals by offering a motion-sensing night light with customizable features such as adjustable sleep-friendly colors, intensity levels, and motion detection.
## Our Project in details
### Main Features:
- **Adjustable Sleep-Friendly Lighting**: Users can customize the color temperature and intensity of the night light to create a comfortable sleep environment.
- **Motion Detection Capability**: The night light is equipped with motion sensors that adjust the light intensity when movement is detected, aiding in nighttime mobility.
- **Mobile App Control**: The night light can be controlled via a mobile app, allowing users to set sleep/wake times, adjust lighting settings, and manage other features remotely.
### How to use:
1. Download 'nightlight' app.
2. Turn on both bluetooth and location in your phone.
3. Press on connect to connect to the ESP via bluetooth and give permissions for location/bluetooth if asked.
4. In WiFi page enter network information to connect in order for the ESP to keep track of the current time (doing so once is enough as long as the network info doesn't change since they will be saved).
5. if connecting to WiFi fails the option to send the phone's current time to ESP can be used
     *this option is less accurate (up to 1 minute error) and the time will be lost if if the ESP gets turned off.
6. Set the preferred settings you want to use and **Do Not Forget To Press Save :)** (the settings will be saved untill changed again).

![graph](https://github.com/MhamedAhmad/IOT-NightLight/assets/158752975/83a8937a-b598-44b9-86f2-2782f093c19b)

## Folder Description
- Flutter : dart code for our Flutter app.
- UnitTests : tests for individual hardware components (input / output devices).
- hsv_night_light : source code for the esp side (firmware).
## Arduino/ESP32 libraries used in this project
- Adafruit_NeoPixel - Version 1.12.0
- Time - Version 1.6.1
- WifiManager - Version 2.0.17
## Hardware Used
- 1 X ESP32 (30pins)
- 1 X PIR
- 1 X Neopixel (around 1 Meter)
- 1 X External Power Supply
## Project Diagram
![diagram](https://github.com/MhamedAhmad/IOT-NightLight/assets/158752975/be8331c8-610c-4ad4-be84-3aa3df369528)\
## Project Poster
This project is part of ICST - The Interdisciplinary Center for Smart Technologies, Taub Faculty of Computer Science, Technion https://icst.cs.technion.ac.il/

