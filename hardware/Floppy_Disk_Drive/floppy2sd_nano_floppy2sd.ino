/*****************************************************************************

                            VZ DISK to SD transfer 

 This sketch is uploaded to the Arduino to communicate with the VZ  
 

 Compile using the Arduino IDE

*****************************************************************************/
#include <SD.h>
#include <SPI.h>

File vzDiskFile;

#define SD_MISO  12
#define SD_MOSI  11 
#define SD_CS    10 
#define SD_SCK   13  
 
#define externalRedLed   9
#define externalGreenLed 8
#define Y1  2              // interrupt pin  - WRITE
#define Y2  3              // interrupt pin  - READ
#define DATA_IN  4         // connected to latched bit 

static byte GAP1[] = {0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00};
static byte IDAM[] = {0xFE, 0xE7, 0x18, 0xC3};
byte  track, sector, ts_checksum;
static byte GAP2[] = {0x80, 0x80, 0x80, 0x80, 0x80, 0x00, 0xC3, 0x18, 0xE7, 0xFE};
unsigned int data_checksum; 


int   d7;
bool  data_write;
int   bitCount, constructedByte, mask;

byte  nBuffer[130];
int   nBytes = 0;

void Z80_WRITE_PORT()
{
      // A Z80 write to port 40h has been triggered by the LS138. 
      // The output bit (D7) has been latched on the LS259. This is 
      // wired to nano port D4. By the time this ISR is run, the bit
      // will be latched 

    data_write = true; 
    d7 = digitalRead(DATA_IN);          // read bit from latch output
}


void Z80_READ_PORT()
{
 
}


void setup() {
  pinMode(externalRedLed, OUTPUT);
  pinMode(externalGreenLed, OUTPUT);
  
  pinMode(DATA_IN, INPUT);
  pinMode(Y1, INPUT);
  pinMode(Y2, INPUT);

  data_write = false; 

  // attempt to connect to sd card. Display green if ok, red if not ok
  if (!SD.begin(SD_CS))
  {
    // not ok - light red led and stop
    digitalWrite(externalRedLed,HIGH); 
    while (1);
  }
  // card ok. Light green led to show success
  digitalWrite(externalGreenLed,HIGH); 

  attachInterrupt(digitalPinToInterrupt(Y1),Z80_WRITE_PORT,FALLING);
  attachInterrupt(digitalPinToInterrupt(Y2),Z80_READ_PORT,FALLING);

  bitCount = 0;
  mask = 7;
  constructedByte = 0;
}



void loop() {
  if (data_write)
  {
      // build byte from D7 to D0
      constructedByte += (d7 << mask);
      bitCount++;
      mask--;
      if (bitCount == 8)        // 8 bits constructed into a byte 
      {
        nBuffer[nBytes++] = constructedByte;

        bitCount = 0;
        mask = 7;
        constructedByte = 0;

        if (nBytes == 130)    // track, sector + 128 bytes data 
        {
            digitalWrite(externalRedLed,HIGH); 
            vzDiskFile = SD.open("vzdisk.dsk", FILE_WRITE);
            if (vzDiskFile)
            {
              for (int i=0;i<7;i++) vzDiskFile.write(GAP1[i]);
              for (int i=0;i<4;i++) vzDiskFile.write(IDAM[i]);
              track = nBuffer[0];   vzDiskFile.write(track);
              sector = nBuffer[1];  vzDiskFile.write(sector);
              ts_checksum = track + sector; vzDiskFile.write(ts_checksum);
              for (int i=0;i<10;i++) vzDiskFile.write(GAP2[i]);
              data_checksum = 0;
              for (int i=2;i<130;i++)
              {
                data_checksum += nBuffer[i];
                vzDiskFile.write(nBuffer[i]);  
              }
              // write data checksum as lb, hb 
              int hb = (int) data_checksum / 256;
              int lb = (int) data_checksum - 256*hb;
              vzDiskFile.write(lb);
              vzDiskFile.write(hb);
            }
            vzDiskFile.close();
            digitalWrite(externalRedLed,LOW);
            nBytes = 0;
        }
       
       }
      data_write = false; 
  }

}
