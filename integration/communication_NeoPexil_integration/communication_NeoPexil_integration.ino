//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//Including libraries
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
#include <Adafruit_NeoPixel.h>

#include "time.h"

#include <Preferences.h>

#include <WiFi.h>

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//Preferences initialization
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
Preferences prefs;
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//NeoPixel initializations and functions
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//initializations
#define PIN        26
#define NUMPIXELS 3
Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
int red = 0;
int green = 0;
int blue = 0;
int high_brightness = 0;
int low_brightness = 0;
//turn on pixels
void light(float fraction)
{
  int brightness = fraction * high_brightness + (1-fraction) * low_brightness;
  for(int i=0; i<NUMPIXELS; i++)
    pixels.setPixelColor(i, pixels.Color((brightness*red/255), (brightness*green/255), (brightness*blue/255)));
  pixels.show();
}
//handle pixel color change
void handleColors(std::string colors)
{
  red = (getValue(String(colors.c_str()), '+', 0)).toInt();
  green = (getValue(String(colors.c_str()), '+', 1)).toInt();
  blue = (getValue(String(colors.c_str()), '+', 2)).toInt();
  for(int i=0; i<NUMPIXELS; i++)
  pixels.setPixelColor(i, pixels.Color((10*10*red/255), (10*10*green/255), (10*10*blue/255)));
  pixels.show();
  prefs.putInt("red", red);
  prefs.putInt("green", green);
  prefs.putInt("blue", blue);
  delay(500);
  actAccordingTime();
}
//handle pixel brightness change
void handleBrightness(std::string brightness)
{
  high_brightness = 10 * (getValue(String(brightness.c_str()), '+', 0)).toInt();
  low_brightness = 10 * (getValue(String(brightness.c_str()), '+', 1)).toInt();
  prefs.putInt("high_brightness", high_brightness);
  prefs.putInt("low_brightness", low_brightness);
  actAccordingTime();
}
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//NTP initializations and functions
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//initializations
const char* ntpServer = "time.google.com";
const long  gmtOffset_sec = 7200;
const int   daylightOffset_sec = 3600;
bool configured = false;
int start_time = 0;
int end_time = 0;
int rise_time = 0;
int fade_time = 0;
//finds the state neopixel should be in and apply it
void actAccordingTime()
{
  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  int time = timeinfo.tm_hour * 3600 + timeinfo.tm_min*60 + timeinfo.tm_sec;
  if(start_time <= end_time)
  {
    if(time == start_time)
      light(0);
    else if(time == end_time)
      light(1);
    else if(time > start_time && time < start_time + rise_time)
      light((time-start_time)/(float)rise_time);
    else if(time >= start_time + rise_time && time < end_time)
      light(1);
    else if(time >= end_time + fade_time)
      light(0);
    else
    {
      if(end_time + fade_time <= 24 * 3600)
      {
        if(time < start_time)
          light(0);
        else
          light(1-(time-end_time)/(float)fade_time);
      }
      else
      {
        if(time > end_time)
          light(1-(time-end_time)/(float)fade_time);
        else if(time + 24 * 3600 >= end_time + fade_time)
          light(0);
        else
          light(1-(time + 24 * 3600-end_time)/(float)fade_time);
      }
    }
  }
  else
  {
    if(time == start_time)
      light(0);
    else if(time == end_time)
      light(1);
    else if(time > end_time && time < end_time + fade_time)
      light(1-(time-end_time)/(float)fade_time);
    else if(time >= end_time + fade_time && time < start_time)
      light(0);
    else if(time >= start_time + rise_time)
      light(1);
    else
    {
      if(start_time + rise_time <= 24 * 3600)
      {
        if(time < end_time)
          light(1);
        else
          light((time-start_time)/(float)rise_time);
      }
      else
      {
        if(time > start_time)
          light((time-start_time)/(float)rise_time);
        else if(time + 24 * 3600 >= start_time + rise_time)
          light(1);
        else
          light((time + 24 * 3600-start_time)/(float)rise_time);
      }
    }
  }
}
//handle times changes
void handleCycleTimes(std::string times)
{
  int start_hours = (getValue(String(times.c_str()), '+', 0)).toInt();
  int start_minutes = (getValue(String(times.c_str()), '+', 1)).toInt();
  start_time = start_hours * 3600 + start_minutes * 60;
  int end_hours = (getValue(String(times.c_str()), '+', 2)).toInt();
  int end_minutes = (getValue(String(times.c_str()), '+', 3)).toInt();
  end_time = end_hours * 3600 + end_minutes * 60;
  rise_time = 60 * (getValue(String(times.c_str()), '+', 4)).toInt();
  fade_time = 60 * (getValue(String(times.c_str()), '+', 5)).toInt();
  actAccordingTime();
  prefs.putInt("start_time", start_time);
  prefs.putInt("end_time", end_time);
  prefs.putInt("rise_time", rise_time);
  prefs.putInt("fade_time", fade_time);
}
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//Preferences functions
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//using saved credentials to connect to WiFi and NTP
void connectWithPref()
{
  prefs.begin("saved_data", false);
  //prefs.clear();
  unsigned int  ssid_length = prefs.getBytesLength("ssid");
  unsigned int  pw_length = prefs.getBytesLength("pw");
  if(ssid_length > 0 && pw_length > 0)
  {
    char last_ssid[ssid_length];
    prefs.getBytes("ssid", last_ssid, ssid_length);
    char last_pw[pw_length];
    prefs.getBytes("pw", last_pw, pw_length);
    IPAddress dns(8,8,8,8);
    WiFi.begin(last_ssid, last_pw);
    //Serial.println("trying saved info");
    delay(2000);
    if(WiFi.status() == WL_CONNECTED)
    {
      Serial.println("internet connected");
      configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
      actAccordingTime();
      WiFi.disconnect(true);
      WiFi.mode(WIFI_OFF);
      configured = true;
    }
  }
}
//load pixel settings
void loadPixelSettings()
{
  red = prefs.getInt("red", 0);
  green = prefs.getInt("green", 0);
  blue = prefs.getInt("blue", 0);
  high_brightness = prefs.getInt("high_brightness", 0);
  low_brightness = prefs.getInt("low_brightness", 0);
}
//load times settings
void loadTimeSettings()
{
  start_time = prefs.getInt("start_time", 0);
  end_time = prefs.getInt("end_time", 0);
  rise_time = prefs.getInt("rise_time", 0);
  fade_time = prefs.getInt("fade_time", 0);
  actAccordingTime();
}
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//credentials related functions
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
void handleCredentials(std::string credentials)
{
  String ssid;
  String pw;
  Serial.print("SSID: ");
  ssid = getValue(String(credentials.c_str()), '+', 0);
  const char* input_ssid = ssid.c_str();
  Serial.println(input_ssid);
  Serial.print("PW: ");
  pw = getValue(String(credentials.c_str()), '+', 1);
  const char* input_pw = pw.c_str();
  Serial.println(input_pw);
  IPAddress dns(8,8,8,8);
  WiFi.begin(input_ssid, input_pw);
  delay(2000);
  if(WiFi.status() == WL_CONNECTED)
  {
    Serial.println("internet connected");
    Serial.println(input_ssid);
    Serial.println(input_pw);
    prefs.putBytes("ssid", input_ssid, strlen(input_ssid));
    prefs.putBytes("pw", input_pw, strlen(input_pw));
    configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
    actAccordingTime();
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);
    configured = true;
  }
}
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//BLE initializations and functions
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//initializations
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic_1 = NULL;
BLECharacteristic* pCharacteristic_2 = NULL;
BLECharacteristic* pCharacteristic_3 = NULL;
BLECharacteristic* pCharacteristic_4 = NULL;
BLEDescriptor *pDescr;
BLE2902 *pBLE2902;
#define SERVICE_UUID        "cfdfdee4-a53c-47f4-a4f1-9854017f3817"
#define CHAR1_UUID          "006e3a0b-1a72-427b-8a00-9d03f029b9a9"
#define CHAR2_UUID          "81b703d5-518a-4789-8133-04cb281361c3"
#define CHAR3_UUID          "3ca69c2c-0868-4579-8fa8-91a203a5b931"
#define CHAR4_UUID          "125f4480-415c-46e0-ab49-218377ab846a"
//changing the behavior when getting a data back from client
class CharacteristicCallBack: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChar) override { 
    if((pChar->getUUID()).toString() == CHAR1_UUID)
      handleCredentials(pChar->getValue());
    else if((pChar->getUUID()).toString() == CHAR2_UUID)
      handleColors(pChar->getValue());
    else if((pChar->getUUID()).toString() == CHAR3_UUID)
      handleBrightness(pChar->getValue());
    else if((pChar->getUUID()).toString() == CHAR4_UUID)
      handleCycleTimes(pChar->getValue());
  }
};
//starting BLE connection
void BLEStart()
{
  BLEDevice::init("ESP32");
  pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic_1 = pService->createCharacteristic(
                      CHAR1_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_1->addDescriptor(new BLE2902());
  pCharacteristic_1->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_2 = pService->createCharacteristic(
                      CHAR2_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_2->addDescriptor(new BLE2902());
  pCharacteristic_2->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_3 = pService->createCharacteristic(
                      CHAR3_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_3->addDescriptor(new BLE2902());
  pCharacteristic_3->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_4 = pService->createCharacteristic(
                      CHAR4_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_4->addDescriptor(new BLE2902());
  pCharacteristic_4->setCallbacks(new CharacteristicCallBack());
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising(); 
}
//separating data received from clienthandleCycleTimes
String getValue(String data, char separator, int index){
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length()-1;

  for(int i=0; i<=maxIndex && found <=index; i++){
    if(data.charAt(i)==separator || i==maxIndex){
      found++;
      strIndex[0] = strIndex[1]+1;
      strIndex[1] = (i==maxIndex) ? i+1 : i;
    }
  }
  return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//setup
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
void setup(){
  Serial.begin(115200); 
  connectWithPref();
  loadPixelSettings();
  loadTimeSettings();
  BLEStart();
}
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//loop
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
void loop(){
  if(configured)
    actAccordingTime();
}
