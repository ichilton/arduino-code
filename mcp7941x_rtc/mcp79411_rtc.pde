/**********************************************************************************************
 * Code to set and display the date & time on the MCP79410, MCP79411 and MCP79412. 
 *
 * Ian Chilton <ian@ichilton.co.uk>
 * 08/11/2011
 *
 * See the setup() function to set the clock.
 *
 * Taken from tronixstuff's DS1307 example, re-hashed and modified for the MCP7941x.
 * https://sites.google.com/site/tronixstuff/home/arduino-tutorial-series-files/example7p4.pde
 *
 * See the README file for more information.
 *
 **********************************************************************************************/

// Include the Wire library for I2C:
#include "Wire.h"

// I2C Address:
#define MCP7941x_RTC_I2C_ADDR 0x6f

// Memory address for the RTC:
#define RTC_LOCATION 0x00


// Convert normal decimal numbers to binary coded decimal:
byte decToBcd(byte val)
{
  return ( (val/10*16) + (val%10) );
}

// Convert binary coded decimal to normal decimal numbers:
byte bcdToDec(byte val)
{
  return ( (val/16*10) + (val%16) );
}


// Set the date/time, set to 24hr and start the clock:
// (assumes you're passing in valid numbers)
void setDateTime(
  byte second,        // 0-59
  byte minute,        // 0-59
  byte hour,          // 1-23
  byte dayOfWeek,     // 1-7
  byte dayOfMonth,    // 1-28/29/30/31
  byte month,         // 1-12
  byte year)          // 0-99
{
  Wire.beginTransmission(MCP7941x_RTC_I2C_ADDR);
  Wire.send(RTC_LOCATION);
  
  Wire.send(decToBcd(second) & 0x7f);     // set seconds and disable clock
  Wire.send(decToBcd(minute) & 0x7f);     // set minutes
  Wire.send(decToBcd(hour) & 0x3f);       // set hours and to 24hr clock   
  Wire.send(decToBcd(dayOfWeek) & 0x0f);  // set the day and enable battery backup
  Wire.send(decToBcd(dayOfMonth) & 0x3f); // set the date in month
  Wire.send(decToBcd(month) & 0x1f);      // set the month
  Wire.send(decToBcd(year));              // set the year
  
  Wire.endTransmission();

  // Start Clock:
  Wire.beginTransmission(MCP7941x_RTC_I2C_ADDR);
  Wire.send(RTC_LOCATION);
  Wire.send(decToBcd(second) | 0x80);     // set seconds and enable clock
  Wire.endTransmission();
}


// Get the date/time:
void getDateTime(
  byte *second,
  byte *minute,
  byte *hour,
  byte *dayOfWeek,
  byte *dayOfMonth,
  byte *month,
  byte *year)
{
  Wire.beginTransmission(MCP7941x_RTC_I2C_ADDR);
  Wire.send(RTC_LOCATION);
  Wire.endTransmission();

  Wire.requestFrom(MCP7941x_RTC_I2C_ADDR, 7);
  
  // A few of these need masks because certain bits are control bits
  *second     = bcdToDec(Wire.receive() & 0x7f);
  *minute     = bcdToDec(Wire.receive() & 0x7f);
  *hour       = bcdToDec(Wire.receive() & 0x3f);
  *dayOfWeek  = bcdToDec(Wire.receive() & 0x07);
  *dayOfMonth = bcdToDec(Wire.receive() & 0x3f);
  *month      = bcdToDec(Wire.receive() & 0x3f);
  *year       = bcdToDec(Wire.receive());
}


void displayDateTime(
  byte second,
  byte minute,
  byte hour,
  byte dayOfWeek,
  byte dayOfMonth,
  byte month,
  byte year) 
{
  if (hour < 10)
  {
    Serial.print("0");
  }
  
  Serial.print(hour, DEC);
  Serial.print(":");

  if (minute < 10)
  {
      Serial.print("0");
  }

  Serial.print(minute, DEC);
  Serial.print(":");

  if (second < 10)
  {
    Serial.print("0");
  }

  Serial.print(second, DEC);
  Serial.print("  ");

  if (dayOfMonth < 10)
  {
    Serial.print("0");
  }
  
  Serial.print(dayOfMonth, DEC);
  Serial.print("/");

  if (month < 10)
  {
    Serial.print("0");
  }
  
  Serial.print(month, DEC);
  Serial.print("/");
  
  Serial.print(year, DEC);

  Serial.print(" (");

  switch(dayOfWeek)
  {
    case 1: 
      Serial.print("Sunday");
      break;

    case 2: 
      Serial.print("Monday");
      break;

    case 3: 
      Serial.print("Tuesday");
      break;

    case 4: 
      Serial.print("Wednesday");
      break;

    case 5: 
      Serial.print("Thursday");
      break;

    case 6: 
      Serial.print("Friday");
      break;

    case 7: 
      Serial.print("Saturday");
      break;
  }

  Serial.println(")");  
}


void setup()
{
  byte second, minute, hour, dayOfWeek, dayOfMonth, month, year;
  
  Wire.begin();
  Serial.begin(9600);

  // Set these to the values you want to set the date/time to:
  second = 0;
  minute = 59;
  hour = 23;
  dayOfWeek = 3;   // 1 = Sunday, 7 = Saturday
  dayOfMonth = 8;
  month = 11;
  year = 11;

  // Uncomment the next line to set the date/time:
  // setDateTime(second, minute, hour, dayOfWeek, dayOfMonth, month, year);
  
  // If you have a battery, you should only need to do the set once and after that,
  // it should remember the date/time even when the power is off.
}


void loop()
{
  byte second, minute, hour, dayOfWeek, dayOfMonth, month, year;

  // Get the date/time from the RTC:
  getDateTime(&second, &minute, &hour, &dayOfWeek, &dayOfMonth, &month, &year);

  // Display the Date/Time on the serial line:
  displayDateTime(second, minute, hour, dayOfWeek, dayOfMonth, month, year);
  
  // Sleep for 1s:
  delay(1000);
}

