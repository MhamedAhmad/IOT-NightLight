//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//Including libraries
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
#include <Adafruit_NeoPixel.h>

#include <TimeLib.h>

#include <Preferences.h>

#include <WiFi.h>

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
bool configured = false;
bool manually_configured = false;
bool was_configured = false;
bool connecting = false;
bool color_page = false;
bool BT_connecting = false;
bool connected = false;
bool was_connected = false;
bool BT_connected = false;
std::string page = "0";
BLECharacteristic* pCharacteristic_8 = NULL;
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
int low_hue = 0;
int low_saturation = 0;
int low_value = 0;
int high_hue = 0;
int high_saturation = 0;
int high_value = 0;
int motion_value = 0;
//turn on pixels
void light(float fraction, bool motion=false)
{
  int hue = 0;
  int sat = 0;
  int val = 0;
  if(motion)
  {
    hue = low_hue;
    sat = low_saturation;
    val = motion_value;
  }
  else
  {
    if((high_hue > low_hue && high_hue - low_hue < 32768) || (high_hue <= low_hue && low_hue - high_hue < 32768))
      hue = fraction * high_hue + (1-fraction) * low_hue;
    else if(low_hue < 32768)
      hue = (int)(fraction * high_hue + (1-fraction) * (65536 + low_hue)) % 65536;
    else
      hue = (int)(fraction * (65536 + high_hue) + (1-fraction) * low_hue) % 65536;
    sat = fraction * high_saturation + (1-fraction) * low_saturation;
    val = fraction * high_value + (1-fraction) * low_value;
  }
  uint32_t rgbcolor = pixels.gamma32(pixels.ColorHSV(hue, sat, val));
  pixels.fill(rgbcolor);
  pixels.show();
}
//handle pixel color change
void handleColors(std::string colors, bool high)
{
  int hue = 65535 * ((getValue(String(colors.c_str()), '+', 0)).toFloat())/360;
  int sat = 255 * (getValue(String(colors.c_str()), '+', 1)).toFloat();
  int val = 255 * (getValue(String(colors.c_str()), '+', 2)).toFloat();
  int save = (getValue(String(colors.c_str()), '+', 3)).toInt();
  Serial.println(hue);
  Serial.println(sat);
  Serial.println(val);
  uint32_t rgbcolor = pixels.gamma32(pixels.ColorHSV(hue, sat, val));
  Serial.println(rgbcolor);
  pixels.fill(rgbcolor);
  if((high && page == "1") || (!high && page == "2"))
    pixels.show();
  if(save == 0)
    return;
  if(high)
  {
    high_hue = hue;
    high_saturation = sat;
    high_value = val;
    prefs.putInt("high_hue", high_hue);
    prefs.putInt("high_saturation", high_saturation);
    prefs.putInt("high_value", high_value);
  }
  else
  {
    low_hue = hue;
    low_saturation = sat;
    low_value = val;
    motion_value = 255*(getValue(String(colors.c_str()), '+', 4)).toFloat();
    prefs.putInt("low_hue", low_hue);
    prefs.putInt("low_saturation", low_saturation);
    prefs.putInt("low_value", low_value);
    prefs.putInt("motion_value", motion_value);
  }
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
int start_time = 0;
int end_time = 0;
int rise_time = 0;
int fade_time = 0;
int delay_time = 0;
//configure time using time sent by user
void handleTimeConfig(std::string curr_time)
{
  int hour = (getValue(String(curr_time.c_str()), '+', 0)).toInt();
  int minute =(getValue(String(curr_time.c_str()), '+', 1)).toInt();
  int second =(getValue(String(curr_time.c_str()), '+', 2)).toInt();
  int day =(getValue(String(curr_time.c_str()), '+', 3)).toInt();
  int month =(getValue(String(curr_time.c_str()), '+', 4)).toInt();
  int year =(getValue(String(curr_time.c_str()), '+', 5)).toInt();
  setTime(hour, minute, second, day, month, year);
  manually_configured = true;
  int value = 1;
  if(connected)
    value = 5;
  pCharacteristic_8->setValue(value);
  pCharacteristic_8->notify();
}
//finds the state neopixel should be in and apply it
void actAccordingTime(bool motion = false)
{
  struct tm timeinfo;
  int time = 0;
  if(manually_configured)
    time = hour()*3600 + minute()*60 + second();
  else if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  else
    time = timeinfo.tm_hour * 3600 + timeinfo.tm_min*60 + timeinfo.tm_sec;
  if(start_time <= end_time)
  {
    if(time == start_time)
      light(0);
    else if(time == end_time)
      light(1, motion);
    else if(time > start_time && time < start_time + rise_time)
      light((time-start_time)/(float)rise_time);
    else if(time >= start_time + rise_time && time < end_time)
      light(1);
    else if(time >= end_time + fade_time)
      light(0, motion);
    else
    {
      if(end_time + fade_time <= 24 * 3600)
      {
        if(time < start_time)
          light(0, motion);
        else
          light(1-(time-end_time)/(float)fade_time, motion);
      }
      else
      {
        if(time > end_time)
          light(1-(time-end_time)/(float)fade_time, motion);
        else if(time + 24 * 3600 >= end_time + fade_time)
          light(0, motion);
        else
          light(1-(time + 24 * 3600-end_time)/(float)fade_time, motion);
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
      light(1-(time-end_time)/(float)fade_time, motion);
    else if(time >= end_time + fade_time && time < start_time)
      light(0, motion);
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
  int start_hours = (getValue(String(times.c_str()), '+', 2)).toInt();
  int start_minutes = (getValue(String(times.c_str()), '+', 3)).toInt();
  start_time = start_hours * 3600 + start_minutes * 60;
  int end_hours = (getValue(String(times.c_str()), '+', 0)).toInt();
  int end_minutes = (getValue(String(times.c_str()), '+', 1)).toInt();
  end_time = end_hours * 3600 + end_minutes * 60;
  rise_time = 60 * (getValue(String(times.c_str()), '+', 4)).toInt();
  fade_time = 60 * (getValue(String(times.c_str()), '+', 5)).toInt();
  delay_time = 60 * (getValue(String(times.c_str()), '+', 6)).toInt();
  Serial.print("Start time: ");
  Serial.print(start_hours);
  Serial.print(" : ");
  Serial.println(start_minutes);
  Serial.print("end time: ");
  Serial.print(end_hours);
  Serial.print(" : ");
  Serial.println(end_minutes);
  Serial.print("rise time: ");
  Serial.println(rise_time);
  Serial.print("fade time: ");
  Serial.println(fade_time);
  Serial.print("delay time: ");
  Serial.println(delay_time);
  prefs.putInt("start_time", start_time);
  prefs.putInt("end_time", end_time);
  prefs.putInt("rise_time", rise_time);
  prefs.putInt("fade_time", fade_time);
  prefs.putInt("delay_time", delay_time);
}
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//PIR initializations and functions
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//initializations
#define PIRInput 34
int pirState = LOW;
int val = 0;
uint32_t last_motion = 0;
bool detected_mode = false;
//check if there is a motion (if there is then motion brightness will be applied, otherwise it will depend on time)
void detectMotion()
{

  val = digitalRead(PIRInput);
  if (val == HIGH) 
  {
    //Serial.println("Detecting motion on");
    if(pirState == LOW)
      Serial.println("motion on");
    actAccordingTime(true);
    pirState = HIGH;
    detected_mode = true;
  }
  else 
  {
    if(configured || manually_configured)
    {
    //Serial.println("Detecting motion off");
      if (pirState == HIGH) {
        Serial.println("motion off");
        last_motion = millis()/1000;
        pirState = LOW;
      }
      uint32_t now = millis()/1000;
      if(now < last_motion)
        now = now + 4294967;
      if(now + 3 - last_motion >= delay_time)
        actAccordingTime();
    }
    else if(!connecting)
      connectWithPref();
  }
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
    char last_ssid[33] = {0};
    prefs.getBytes("ssid", last_ssid, ssid_length);
    char last_pw[64] = {0};
    prefs.getBytes("pw", last_pw, pw_length);
    IPAddress dns(8,8,8,8);
    //Serial.println(last_ssid);
    //Serial.println(last_pw);
    WiFi.mode(WIFI_STA);
    WiFi.begin(last_ssid, last_pw);
    //Serial.println("trying saved info");
    delay(2000);
    if(WiFi.status() == WL_CONNECTED)
    {
      Serial.println("internet connected");
      configTime(0, 0, ntpServer);
      setenv("TZ", "IST-2IDT,M3.4.4/26,M10.5.0", 1);
      tzset();
      struct tm timeinfo;
      if(!getLocalTime(&timeinfo)){
        connected = true;
        Serial.println("Failed to obtain time");
        return;
      }
      configured = true;
      connected = true;
      Serial.println("Finally Obtained time while connecting to wifi with password saved!!");
      WiFi.disconnect(true);
      WiFi.mode(WIFI_OFF);
    }
  }
  else if(ssid_length > 0)
  {
    char last_ssid[33] = {0};
    prefs.getBytes("ssid", last_ssid, ssid_length);
    IPAddress dns(8,8,8,8);
    //Serial.println(last_ssid);
    WiFi.mode(WIFI_STA);
    WiFi.begin(last_ssid);
    delay(2000);
    if(WiFi.status() == WL_CONNECTED)
    {
      Serial.println("internet connected");
      configTime(0, 0, ntpServer);
      setenv("TZ", "IST-2IDT,M3.4.4/26,M10.5.0", 1);
      tzset();
      struct tm timeinfo;
      if(!getLocalTime(&timeinfo)){
        connected = true;
        Serial.println("Failed to obtain time");
        return;
      }
      configured = true;
      connected = true;
      Serial.println("Finally Obtained time while connecting to wifi with no password saved!!");
      WiFi.disconnect(true);
      WiFi.mode(WIFI_OFF);
    }
  }
}
//load pixel settings
void loadPixelSettings()
{
  high_hue = prefs.getInt("high_hue", 0);
  high_saturation = prefs.getInt("high_saturation", 0);
  high_value = prefs.getInt("high_value", 0);
  low_hue = prefs.getInt("low_hue", 0);
  low_saturation = prefs.getInt("low_saturation", 0);
  low_value = prefs.getInt("low_value", 0);
  motion_value = prefs.getInt("motion_value", 0);
}
//load times settings
void loadTimeSettings()
{
  start_time = prefs.getInt("start_time", 0);
  end_time = prefs.getInt("end_time", 0);
  rise_time = prefs.getInt("rise_time", 0);
  fade_time = prefs.getInt("fade_time", 0);
  delay_time = prefs.getInt("delay_time", 0);
  detectMotion();
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
BLECharacteristic* pCharacteristic_5 = NULL;
BLECharacteristic* pCharacteristic_6 = NULL;
BLECharacteristic* pCharacteristic_7 = NULL;
BLEDescriptor *pDescr;
BLE2902 *pBLE2902_1;
BLE2902 *pBLE2902_2;
#define SERVICE_UUID        "cfdfdee4-a53c-47f4-a4f1-9854017f3817"
#define CHAR1_UUID          "006e3a0b-1a72-427b-8a00-9d03f029b9a9"
#define CHAR2_UUID          "81b703d5-518a-4789-8133-04cb281361c3"
#define CHAR3_UUID          "3ca69c2c-0868-4579-8fa8-91a203a5b931"
#define CHAR4_UUID          "125f4480-415c-46e0-ab49-218377ab846a"
#define CHAR5_UUID          "be31c4e4-c3f7-4b6f-83b3-d9421988d355"
#define CHAR6_UUID          "c78ed52c-7a26-49ab-ba3c-c4133568a8f2"
#define CHAR7_UUID          "6d6fb840-ed2b-438f-8375-9220a5164be8"
#define CHAR8_UUID          "69ce5b3b-3db5-4511-acd1-743d30bcfb37"
//changing the behavior when getting a data back from client
class CharacteristicCallBack: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChar) override { 
    if((pChar->getUUID()).toString() == CHAR1_UUID)
      handleCredentials(pChar->getValue());
    else if((pChar->getUUID()).toString() == CHAR2_UUID)
      handleColors(pChar->getValue(), true);
    else if((pChar->getUUID()).toString() == CHAR3_UUID)
      handleColors(pChar->getValue(), false);
    else if((pChar->getUUID()).toString() == CHAR4_UUID)
      handleCycleTimes(pChar->getValue());
    else if((pChar->getUUID()).toString() == CHAR6_UUID){
      page = pChar->getValue();
      color_page = (page != "0");
      if(!color_page)
        return;
      int hue = high_hue;
      int sat = high_saturation;
      int val = high_value;
      if(page == "2")
      {
        hue = low_hue;
        sat = low_saturation;
        val = low_value;
      }
      uint32_t rgbcolor = pixels.gamma32(pixels.ColorHSV(hue, sat, val));
      Serial.println(rgbcolor);
      pixels.fill(rgbcolor);
      pixels.show();
    }
    else if((pChar->getUUID()).toString() == CHAR7_UUID)
      handleTimeConfig(pChar->getValue());
  }
};
//

class MyServerCallbacks: public BLEServerCallbacks {
    void onDisconnect(BLEServer* pServer) {
      Serial.println("DISCONNECTED");
      color_page = false;
      BT_connected = false;
      pServer->startAdvertising();
    }
    void onConnect(BLEServer* pServer) {
      BT_connecting = true;
      BT_connected = true;
    }
};
//starting BLE connection
void BLEStart()
{
  BLEDevice::init("NightLightIOT");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  BLEService *pService = pServer->createService(BLEUUID(SERVICE_UUID), 50);
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
  pCharacteristic_5 = pService->createCharacteristic(
                      CHAR5_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );                   
  pBLE2902_1 = new BLE2902();
  pBLE2902_1->setNotifications(true);
  pCharacteristic_5->addDescriptor(pBLE2902_1);
  pCharacteristic_5->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_6 = pService->createCharacteristic(
                      CHAR6_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_6->addDescriptor(new BLE2902());
  pCharacteristic_6->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_7 = pService->createCharacteristic(
                      CHAR7_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_7->addDescriptor(new BLE2902());
  pCharacteristic_7->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_8 = pService->createCharacteristic(
                      CHAR8_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );                   
  pBLE2902_2 = new BLE2902();
  pBLE2902_2->setNotifications(true);
  pCharacteristic_8->addDescriptor(pBLE2902_2);
  pCharacteristic_8->setCallbacks(new CharacteristicCallBack());
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
      strIndex[1] = (data.charAt(i)==separator) ? i : i+1;
    }
  }
  return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
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
  bool now_connected = false;
  connecting = true;
  int value = 3;
  for(int i=0; i < 3; i++)
  {
    String ssid;
    String pw;
    Serial.print("SSID: ");
    ssid = getValue(String(credentials.c_str()), '+', 0);
    const char* input_ssid = ssid.c_str();
    Serial.println(input_ssid);
    //Serial.println(strlen(input_ssid));
    Serial.print("PW: ");
    pw = getValue(String(credentials.c_str()), '+', 1);
    const char* input_pw = pw.c_str();
    Serial.println(input_pw);
    //Serial.println(strlen(input_pw));
    IPAddress dns(8,8,8,8);
    WiFi.mode(WIFI_STA);
    if(strlen(input_pw) == 0)
    {
      Serial.println("NO PASSWROD");
      WiFi.begin(input_ssid);
    }
    else
      WiFi.begin(input_ssid, input_pw);
    delay(2000);
    if(WiFi.status() == WL_CONNECTED)
    {
      Serial.println("internet connected");
      //Serial.println(input_ssid);
      //Serial.println(input_pw);
      prefs.putBytes("ssid", input_ssid, strlen(input_ssid));
      //Serial.print(input_ssid);
      //Serial.println(strlen(input_ssid));
      if(strlen(input_pw) == 0)
        prefs.remove("pw");
      else
        prefs.putBytes("pw", input_pw, strlen(input_pw));
      configTime(0, 0, ntpServer);
      setenv("TZ", "IST-2IDT,M3.4.4/26,M10.5.0", 1);
      tzset();
      struct tm timeinfo;
      if(!getLocalTime(&timeinfo, 2000)){
        now_connected = true;
        connected = true;
        was_connected = true;
        Serial.println("Failed to obtain time");
      }
      else
      {
        now_connected = true;
        connected = true;
        was_connected = true;
        Serial.println("Finally Obtained time while connecting from WiFi from app!!");
        WiFi.disconnect(true);
        WiFi.mode(WIFI_OFF);
        was_configured = true;
        configured = true;
        pCharacteristic_5->setValue(value);
        pCharacteristic_5->notify();
        connecting = false;
        return;
      }
    }
  }
  if(now_connected){
    value = 2;
    if(manually_configured)
      value = 5;
  }
  else if (configured || manually_configured)
    value = 1;
  else
    value = 0;
  pCharacteristic_5->setValue(value);
  pCharacteristic_5->notify();
  connecting = false;
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
  pinMode(PIRInput, INPUT);
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
  if(configured && !was_configured && BT_connected && !BT_connecting)
  {
    was_configured = true;
    int value = 3;
    pCharacteristic_8->setValue(value);
    pCharacteristic_8->notify();
    was_connected = true;
  }
  else if(connected && !was_connected && BT_connected && !BT_connecting)
  {
    was_connected = true;
    int value = 2;
    if(configured)
    {
      value = 3;
      was_configured = true;
    }
    else if(manually_configured)
      value = 5;
    pCharacteristic_8->setValue(value);
    pCharacteristic_8->notify();
  }
  if(BT_connecting)
  {
    for(int i=0; i < 3; i++){
        pixels.fill(6553600);
        pixels.show();
        delay(400);
        pixels.clear();
        pixels.show();
        delay(400);
      }
      if(page != "0")
      {
        int hue = high_hue;
        int sat = high_saturation;
        int val = high_value;
        if(page == "2")
        {
          hue = low_hue;
          sat = low_saturation;
          val = low_value;
        }
        uint32_t rgbcolor = pixels.gamma32(pixels.ColorHSV(hue, sat, val));
        Serial.println(rgbcolor);
        pixels.fill(rgbcolor);
        pixels.show();
        color_page = true;
      }
      int value = 0;
      if(connected)
      {
        was_connected = true;
        value = 2;
        if(configured)
        {
          was_configured = true;
          value = 3;
        }
        else if(manually_configured)
          value = 5;
      }
      else if(manually_configured)
        value = 1;
      Serial.println(value);
      pCharacteristic_8->setValue(value);
      pCharacteristic_8->notify();
      BT_connecting = false;
  }
  delay(200);
  if(!color_page)
    detectMotion();
}
