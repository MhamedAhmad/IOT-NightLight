/*
  Rui Santos
  Complete project details at https://RandomNerdTutorials.com/esp32-date-time-ntp-client-server-arduino/
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files.
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
*/

#include <WiFi.h>
#include "time.h"
#include <Preferences.h>

Preferences prefs;

const char* ntpServer = "time.google.com";
const long  gmtOffset_sec = 7200;
const int   daylightOffset_sec = 3600;

void setup(){
  Serial.begin(115200);
  prefs.begin("credentials", false);
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
    Serial.println("trying saved info");
    Serial.println(last_ssid);
    Serial.println(last_pw);
    delay(2000);
    Serial.println("tried saved info");
  }
  // Connect to Wi-Fi
  //Serial.print("Connecting to ");
  //Serial.println(ssid);
  Serial.println(ssid_length);
  Serial.println(pw_length);
  const char* input_ssid;
  const char* input_pw;
  String ssid;
  String pw;
  if(WiFi.status() != WL_CONNECTED)
  {
    while(WiFi.status() != WL_CONNECTED)
    {
      Serial.println("type ssid");
      ssid = Serial.readStringUntil('\n');
      while(ssid.length() == 0)
      {
        ssid = Serial.readStringUntil('\n');
      }
      Serial.println("type pw");
      pw = Serial.readStringUntil('\n');
      while(pw.length() == 0)
      {
        pw = Serial.readStringUntil('\n');
      }
      input_ssid = ssid.c_str();
      input_pw = pw.c_str();
      IPAddress dns(8,8,8,8);
      WiFi.begin(input_ssid, input_pw);
      Serial.println("trying input info");
      delay(2000);
      Serial.println(input_ssid);
    }
    Serial.println("connected");
    Serial.println(input_ssid);
    Serial.print(prefs.getBytesLength("pw"));
    prefs.putBytes("ssid", input_ssid, strlen(input_ssid));
    prefs.putBytes("pw", input_pw, strlen(input_pw));
  }
  Serial.println("");
  Serial.println("WiFi connected.");
  
  // Init and get the time
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  printLocalTime();

  //disconnect WiFi as it's no longer needed
  WiFi.disconnect(true);
  WiFi.mode(WIFI_OFF);
}

void loop(){
  delay(1000);
  printLocalTime();
}

void printLocalTime(){
  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");
  Serial.print("Day of week: ");
  Serial.println(&timeinfo, "%A");
  Serial.print("Month: ");
  Serial.println(&timeinfo, "%B");
  Serial.print("Day of Month: ");
  Serial.println(&timeinfo, "%d");
  Serial.print("Year: ");
  Serial.println(&timeinfo, "%Y");
  Serial.print("Hour: ");
  Serial.println(&timeinfo, "%H");
  Serial.print("Hour (12 hour format): ");
  Serial.println(&timeinfo, "%I");
  Serial.print("Minute: ");
  Serial.println(&timeinfo, "%M");
  Serial.print("Second: ");
  Serial.println(&timeinfo, "%S");

  Serial.println("Time variables");
  char timeHour[3];
  strftime(timeHour,3, "%H", &timeinfo);
  Serial.println(timeHour);
  char timeWeekDay[10];
  strftime(timeWeekDay,10, "%A", &timeinfo);
  Serial.println(timeWeekDay);
  Serial.println();
}