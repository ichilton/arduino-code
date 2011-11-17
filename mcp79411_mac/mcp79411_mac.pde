/************************************************************************************
 * Sample code to read the unique MAC address from a Microchip MCP79411.
 * 
 * Ian Chilton <ian@ichilton.co.uk>
 * 08/11/2011
 *
 * See the README file for more information.
 *
 ************************************************************************************/

// Include the Wire library for I2C:
#include "Wire.h"

// I2C Address:
#define MCP7941x_EEPROM_I2C_ADDR 0x57

// Memory location of the mac address:
// (starts at 0xF0 but first 2 bytes are empty on the MCP79411)
#define MAC_LOCATION 0xF2

// Array for the mac address:
static uint8_t mymac[6] = { 0,0,0,0,0,0 };


// Function to read the mac address:
void getMacAddress(byte *mac_address)
{ 
  Wire.beginTransmission(MCP7941x_EEPROM_I2C_ADDR);
  Wire.send(MAC_LOCATION);
  Wire.endTransmission();

  Wire.requestFrom(MCP7941x_EEPROM_I2C_ADDR, 6);

  for( int i=0; i<6; i++ )
  {
    mac_address[i] = Wire.receive();
  }
}


void setup()
{
  Wire.begin();
  Serial.begin(9600);

  // Get the mac address and store in mymac:
  getMacAddress(mymac);
}


void loop()
{
  // Print the mac address:
  for( int i=0; i<6; i++ )
  {
    if (mymac[i] < 10)
    {
      Serial.print(0);  
    }
    
    Serial.print( mymac[i], HEX );
    Serial.print( i < 5 ? ":" : "" );
  }

  Serial.println();
  
  // Sleep for 10s:
  delay(10000);
}

