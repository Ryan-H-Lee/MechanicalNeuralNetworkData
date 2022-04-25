  #include <EEPROM.h>
#include <Adafruit_MCP4725.h>
#define EEPROM_SIZE 202
#define enablePin  4
#define pulsePin  13
#define sensorPin 36
#define intStart  10
#define floatStart 43
#define boolStart  0
#define nFloats 28
#define nInts 5
#define nBools 5

Adafruit_MCP4725 dac;
TaskHandle_t Sampler, Comms;


const int32_t nReads = 7;
const float tanX[] = {0,0.0050266,0.010053,0.015081,0.020109,0.025138,0.030168,0.0352,0.040234,0.04527,0.050308,0.055348,0.060392,0.065438,0.070488,0.075541,0.080599,0.08566,0.090726,0.095796,0.10087,0.10595,0.11104,0.11613,0.12123,0.12633,0.13144,0.13656,0.14168,0.14681,0.15195,0.1571,0.16225,0.16741,0.17259,0.17777,0.18296,0.18816,0.19337,0.19859,0.20382,0.20906,0.21431,0.21957,0.22485,0.23013,0.23543,0.24074,0.24607,0.25141,0.25676,0.26212,0.2675,0.27289,0.2783,0.28373,0.28916,0.29462,0.30009,0.30558,0.31108,0.3166,0.32214,0.3277,0.33328,0.33887,0.34448,0.35012,0.35577,0.36144,0.36714,0.37285,0.37859,0.38434,0.39013,0.39593,0.40175,0.4076,0.41348,0.41938,0.4253,0.43125,0.43722,0.44322,0.44925,0.4553,0.46139,0.4675,0.47364,0.47981,0.48601,0.49223,0.49849,0.50479,0.51111,0.51747,0.52385,0.53028,0.53673,0.54323,0.54975,0.55632,0.56292,0.56956,0.57623,0.58295,0.5897,0.5965,0.60333,0.61021,0.61713,0.62409,0.6311,0.63815,0.64525,0.65239,0.65958,0.66682,0.6741,0.68144,0.68882,0.69626,0.70375,0.71129,0.71889,0.72654,0.73425,0.74202,0.74984,0.75772,0.76566,0.77367,0.78174,0.78987,0.79806,0.80632,0.81465,0.82305,0.83151,0.84005,0.84866,0.85735,0.8661,0.87494,0.88385,0.89285,0.90192,0.91108,0.92032,0.92965,0.93906,0.94857,0.95816,0.96785,0.97763,0.98751,0.99749,1.0076,1.0177,1.028,1.0384,1.0489,1.0595,1.0703,1.0811,1.0921,1.1032,1.1144,1.1257,1.1372,1.1487,1.1605,1.1723,1.1843,1.1965,1.2088,1.2212,1.2338,1.2466,1.2595,1.2726,1.2859,1.2993,1.3129,1.3267,1.3406,1.3548,1.3691,1.3837,1.3984,1.4134,1.4286,1.444,1.4596,1.4754,1.4915,1.5079,1.5244,1.5413,1.5584,1.5757,1.5934,1.6113,1.6296,1.6481,1.6669,1.6861,1.7055,1.7254,1.7455,1.7661,1.7869,1.8082,1.8299,1.8519,1.8744,1.8973,1.9207,1.9445,1.9687,1.9935,2.0187,2.0445,2.0708,2.0977,2.1251,2.1531,2.1818,2.211,2.241,2.2716,2.3029,2.335,2.3678,2.4014,2.4358,2.4711,2.5073,2.5444,2.5824,2.6215,2.6616,2.7028,2.7451,2.7886,2.8333,2.8794,2.9268,2.9756,3.0258,3.0777,3.1311,3.1863,3.2433,3.3022,3.363,3.4259,3.4911,3.5586,3.6285,3.701,3.7763,3.8545,3.9358,4.0203,4.1084,4.2002,4.2959,4.3958,4.5003,4.6096,4.7241,4.8441,4.9702,5.1027,5.2422,5.3892,5.5444,5.7086,5.8824,6.0668,6.2628,6.4716,6.6944,6.9327,7.1882,7.4629,7.7589,8.0791,8.4263,8.8042,9.2171,9.6702,10.1695,10.7227,11.3389,12.0295,12.8091,13.696,14.7139,15.8945};
const float dTanX[] ={0.50265,0.50267,0.50271,0.50277,0.50286,0.50297,0.50311,0.50328,0.50347,0.50368,0.50393,0.50419,0.50449,0.50481,0.50515,0.50552,0.50592,0.50634,0.50679,0.50727,0.50777,0.5083,0.50885,0.50943,0.51004,0.51068,0.51134,0.51203,0.51274,0.51349,0.51426,0.51506,0.51589,0.51674,0.51763,0.51854,0.51948,0.52045,0.52145,0.52248,0.52354,0.52462,0.52574,0.52689,0.52807,0.52928,0.53052,0.53179,0.53309,0.53442,0.53579,0.53719,0.53862,0.54009,0.54159,0.54312,0.54468,0.54629,0.54792,0.54959,0.5513,0.55304,0.55482,0.55663,0.55849,0.56038,0.5623,0.56427,0.56628,0.56832,0.57041,0.57253,0.5747,0.57691,0.57916,0.58145,0.58379,0.58617,0.58859,0.59106,0.59357,0.59614,0.59874,0.6014,0.6041,0.60686,0.60966,0.61251,0.61542,0.61837,0.62138,0.62445,0.62756,0.63074,0.63396,0.63725,0.6406,0.644,0.64746,0.65099,0.65457,0.65822,0.66194,0.66571,0.66956,0.67347,0.67745,0.6815,0.68563,0.68982,0.69409,0.69843,0.70286,0.70735,0.71193,0.71659,0.72133,0.72616,0.73107,0.73607,0.74115,0.74633,0.7516,0.75697,0.76243,0.76799,0.77365,0.77941,0.78528,0.79125,0.79733,0.80353,0.80983,0.81626,0.8228,0.82946,0.83624,0.84316,0.8502,0.85737,0.86468,0.87213,0.87972,0.88745,0.89533,0.90336,0.91155,0.91989,0.9284,0.93707,0.94592,0.95493,0.96413,0.97351,0.98307,0.99283,1.0028,1.0129,1.0233,1.0339,1.0447,1.0557,1.067,1.0784,1.0902,1.1021,1.1144,1.1269,1.1396,1.1526,1.166,1.1796,1.1935,1.2077,1.2223,1.2371,1.2523,1.2679,1.2838,1.3001,1.3167,1.3338,1.3512,1.3691,1.3873,1.4061,1.4252,1.4449,1.465,1.4857,1.5068,1.5285,1.5507,1.5735,1.5969,1.6209,1.6455,1.6708,1.6967,1.7234,1.7507,1.7788,1.8077,1.8374,1.8679,1.8993,1.9316,1.9648,1.999,2.0342,2.0704,2.1077,2.1462,2.1858,2.2266,2.2687,2.3121,2.3569,2.4031,2.4509,2.5002,2.5511,2.6038,2.6582,2.7145,2.7727,2.833,2.8954,2.96,3.027,3.0964,3.1685,3.2432,3.3208,3.4013,3.485,3.5721,3.6626,3.7568,3.8548,3.957,4.0635,4.1745,4.2904,4.4114,4.5379,4.6701,4.8084,4.9531,5.1048,5.2639,5.4307,5.6059,5.7901,5.9837,6.1876,6.4024,6.6289,6.868,7.1206,7.3878,7.6708,7.9707,8.289,8.6272,8.9869,9.3702,9.779,10.2156,10.6828,11.1833,11.7204,12.2978,12.9196,13.5905,14.3159,15.1016,15.9547,16.883,17.8957,19.0034,20.2181,21.5544,23.0288,24.6612,26.4748,28.4976,30.7631,33.3115,36.1922,39.4655,43.2061,47.5073,52.4871,58.296,65.129,73.2417,82.9747,94.7902,109.3275,127.4916};

int32_t sign = 1; //Holds sign for tangent
int32_t val; //holds the tangent values 
int32_t localPt, dataPt; //Holds operating loop and sample loop values
int32_t dacVal = 2048, dacLast, dacTemp; //Holds current dacValue and Last DacValue, dacTemp is prethresholded value
int32_t counter = 0; //counter for sweep
uint32_t lastTime = micros();
float pos, pos2, pos3, pos4, posTemp, posLast,  velocity, velocity1, y, mFactor;
float ADC3, ADC2, forceTemp, forceTemp2, forceTemp3; //cubed and sqaured values
float forceFlex;
bool enableLast = true;
union S{
    float f;
    uint8_t c[4];
    uint32_t i;
};  

float fMatrix[nFloats] = {0, 650,    0, 0, 0.1, /* 0_KP 1_KD   2_PosOffset, 3_ForceOffset, 4_holdVel */ 
  4.437552521717691e-04, 1.771066841374508e-04, -2.330383206367235e+02,  2.054171721371308e+03, /*  5-8 = dac2force(1-4)  */
  4.132239094562360e-14, -2.578483521874059e-09, 3.065696437458852e-04, -4.333220109502896e+00, /* 9-12 = adc2pos(1-4) */
  5.560304732843623e-03, -5.605791979671246e-03, 1.816587903199087e+00,  4.301491473883188e-03, /* 13-16 = force of Flexures (1-4) */
  9.082266019388915e-05,  4.843868954825913e-04, 4.471190685307132e-03, 1.374532658591240e-02, 1.000018351946333e+00,  /*17-21 = High Motor Drop Curve */
  1.008322359038554e-04,  5.942951764082373e-04, 4.387343533595871e-03, 1.551856651205876e-02, 1.000025720613199e+00, 0}; /*22-26 = low Motor Drop Curve */ 
  
int32_t iMatrix[nInts] = {0, 0, 0, 2048, 0}; //ID, AdcOffset, DacOffset, DacHold, curveType
bool    bMatrix[nBools] = {true, false, false, false,false}; //Hold at Value, sweep ADC inputs

void sendBinary( uint16_t, uint8_t, uint8_t, uint8_t);

void setup() {
  //SetPt = a2d1*setPt*setPt*setPt + a2d2*setPt*setPt + a2d3*setPt + a2d4;
  EEPROM.begin(EEPROM_SIZE);
  Serial.begin(500000);
  dac.begin(0x60);
  delay(100);
  Serial.print("\nInit Begin\n");
  Wire.setClock(400000);
  S convertType;
    for (int i = 0; i < nInts; i++){
    //step through the elments of the array and update from EEPROM
    convertType.c[0] = EEPROM.read(intStart + i*4 + 0);
    convertType.c[1] = EEPROM.read(intStart + i*4 + 1);
    convertType.c[2] = EEPROM.read(intStart + i*4 + 2);
    convertType.c[3] = EEPROM.read(intStart + i*4 + 3);   
    iMatrix[i] = convertType.i;       
  }
 for (int i = 0; i < nBools; i++){
    //step through the elments of the array and update from EEPROM
    bMatrix[i] = bool(EEPROM.read(boolStart + i));
  }
  for (int i = 0; i < nFloats; i++){
    //step through the elments of the array and update from EEPROM
    convertType.c[0] = EEPROM.read(floatStart + i*4 + 0);
    convertType.c[1] = EEPROM.read(floatStart + i*4 + 1);
    convertType.c[2] = EEPROM.read(floatStart + i*4 + 2);
    convertType.c[3] = EEPROM.read(floatStart + i*4 + 3);   
    fMatrix[i] = convertType.f;
//    Serial.print(convertType.f);
//    Serial.print('\t');
  }

  


  
  pinMode(enablePin, OUTPUT);
  pinMode(pulsePin, OUTPUT);
  digitalWrite(enablePin,LOW);
  digitalWrite(pulsePin, LOW);
  
    xTaskCreatePinnedToCore(
    SampleStrainGuage,        /* pvTaskCode */
    "Sampler",      /* pcName */
    6000,                   /* usStackDepth */
    NULL,                   /* pvParameters */
    0,                      /* uxPriority */
    &Sampler,              /* pxCreatedTask */
    0);                     /* xCoreID */

    xTaskCreatePinnedToCore(
    USB_interface,        /* pvTaskCode */
    "Comms",             /* pcName */
    4000,                   /* usStackDepth */
    NULL,                   /* pvParameters */
    2,                      /* uxPriority */
    &Comms,              /* pxCreatedTask */
    1);                     /* xCoreID */
}
void loop() {
  //measured value + offset
  localPt = dataPt + iMatrix[1]; // strain Value + adc offset
  ADC2 = localPt*localPt; 
  ADC3 = ADC2*localPt;
  pos = fMatrix[9]*ADC3 + fMatrix[10]*ADC2+ fMatrix[11]*localPt + fMatrix[12] + fMatrix[2]; // ADC1*a^3 + ADC2*a^2 + ADC3*a + offset Values

  //Calculate Velocity when ADC value changes
  if( posLast != pos ){
    velocity = ( -posLast + pos) / ((micros() - lastTime))*(1-fMatrix[4])+ velocity1*(fMatrix[4]);
    velocity1 = velocity;
    posLast = pos;
  lastTime = micros();
  }
  
  //Calculate Flexure Force
  pos2 = pos*pos;
  pos3 = pos2*pos;
  pos4 = pos3*pos;
  
  forceFlex =  fMatrix[13]*pos3 + fMatrix[14]*pos2 + fMatrix[15]*pos + fMatrix[16]; //KFlex1-4 are in fMatrix13-15
 
 // Adjust force for Motor Drop
 if( dacTemp >= 2048){
   mFactor = fMatrix[17]*pos4 + fMatrix[18]*pos3 + fMatrix[19]*pos2 + fMatrix[20]*pos + fMatrix[21]; //fMatrix(17-21) hold the highCal Values
 }
 else{
    mFactor = fMatrix[22]*pos4 + fMatrix[23]*pos3 + fMatrix[24]*pos2 + fMatrix[25]*pos + fMatrix[26]; //fMatrix(22-16) hold the lowCal Values
 }
// if ( mFactor < 1){
//  mFactor = 1;
//}
  // NONLINEAR Implmentation
  //iMatrix[4] selectes Type
  if(iMatrix[4] == 1){ //Tangent Curve
    val = ( fabs(pos)*100 );
    val = val>300 ? 300 : val;
    sign = (pos>= 0) - (pos<0); //form of sign(pos)
    
    y = (pos - ((double)(val)/100*sign))*dTanX[val] + tanX[val]*sign;
  }
  else{ //Linear
    y = pos - fMatrix[27];
  }
  // Convert Displacement to Force
  forceTemp = mFactor*(fMatrix[0]*y + fMatrix[1]*-velocity - forceFlex + fMatrix[3]);
  forceTemp2 = forceTemp*forceTemp;
  forceTemp3 = forceTemp2*forceTemp;
  
  dacTemp = fMatrix[5]*forceTemp3 + fMatrix[6]*forceTemp2 + fMatrix[7]*forceTemp + fMatrix[8] + iMatrix[2];
  if (bMatrix[3]){
  Serial.print(localPt);
  Serial.print('\t');
  Serial.print(pos);
  Serial.print('\t');
  Serial.print(y);
  Serial.print('\t');
  Serial.print(forceFlex);
  Serial.print('\t');
  Serial.print(mFactor);
  Serial.print('\t');
  Serial.print('\t');
  Serial.print(fMatrix[0]*y);
  Serial.print('\t');
  Serial.print(fMatrix[1]*-velocity );
  Serial.print('\t');
  Serial.print(fMatrix[3]*1000);
  Serial.print('\t');
  Serial.print(fMatrix[0]*y + fMatrix[1]*-velocity - forceFlex + fMatrix[3]);
  Serial.print('\t');
  Serial.print(forceTemp);
  Serial.print('\t');
  Serial.print(dacTemp);
  Serial.print('\n');
  }
if (bMatrix[2]){
  Serial.print(fMatrix[0]);
  Serial.print('\t');
  Serial.print(fMatrix[1]);
  Serial.print('\t');
  Serial.print(fMatrix[2]);
  Serial.print('\t');
  Serial.print(fMatrix[3]);
  Serial.print('\t');
  Serial.print(fMatrix[4]);
  Serial.print('\t');
  Serial.print('\t');
  Serial.print(fMatrix[5]);
  Serial.print('\t');
  Serial.print(fMatrix[6]);
  Serial.print('\t');
  Serial.print(fMatrix[7]);
  Serial.print('\t');
  Serial.print(fMatrix[8]);
  Serial.print('\t');
  Serial.print('\t');
  Serial.print(fMatrix[9]);
  Serial.print('\t');
  Serial.print(fMatrix[10]);
  Serial.print('\t');
  Serial.print(fMatrix[11]);
  Serial.print('\t');
  Serial.print(fMatrix[12]);
  Serial.print('\t');
  Serial.print('\t');
  Serial.print(fMatrix[13]);
  Serial.print('\t');
  Serial.print(fMatrix[14]);
  Serial.print('\t');
  Serial.print(fMatrix[15]);
  Serial.print('\t');
  Serial.print(fMatrix[16]);
  Serial.print('\t'); 
  Serial.print(fMatrix[17]);
  Serial.print('\t');
  Serial.print(fMatrix[18]);
  Serial.print('\t');
  Serial.print(fMatrix[19]);
  Serial.print('\t');
  Serial.print(fMatrix[20]);
  Serial.print('\t');
  Serial.print(fMatrix[21]);
  Serial.print('\t');
  Serial.print('\t');
  Serial.print(fMatrix[22]);
  Serial.print('\t');
  Serial.print(fMatrix[23]);
  Serial.print('\t');
  Serial.print(fMatrix[24]);
  Serial.print('\t');
  Serial.print(fMatrix[25]);
  Serial.print('\t');
  Serial.print(fMatrix[26]);
  Serial.print('\t');
  Serial.print(fMatrix[27]);
  Serial.print('\n');

  Serial.print(iMatrix[0]);
  Serial.print('\t');
  Serial.print(iMatrix[1]);
  Serial.print('\t');
  Serial.print(iMatrix[2]);
  Serial.print('\t');
  Serial.print(iMatrix[3]);
  Serial.print('\t');
  Serial.print(iMatrix[4]);
  Serial.print('\n');

  
  Serial.print(bMatrix[0]);
  Serial.print('\t');
  Serial.print(bMatrix[1]);
  Serial.print('\t');
  Serial.print(bMatrix[2]);
  Serial.print('\t');
  Serial.print(bMatrix[3]);
  Serial.print('\t');
  Serial.print(bMatrix[4]);
  Serial.print('\n');
  Serial.print('\n');
  Serial.print('\n');
  }
  //Stop Output
  if (enableLast != bMatrix[4]){
    digitalWrite(enablePin, bMatrix[4]);
    enableLast = bMatrix[4];
  }

  
  if(dacTemp > 4095){ 
      dacVal = 4095;
  }
  else if(dacTemp < 0){
      dacVal = 0;
  }
  else{
    dacVal = dacTemp;
  }
    //If FIXED VALUE SETTING
  if( bMatrix[0] == true){
    dacVal = iMatrix[3]; //iMatrix[3] = hold Value
  }

  if(dacVal != dacLast){
    dac.setVoltage(dacVal, false);
  } 
  dacLast = dacVal;

}//End of main loop

void SampleStrainGuage( void * parameter)
{
  uint32_t lastRead = 0;
  uint32_t periodRead = 100;
  uint32_t readVal;
  uint32_t readAvg;
  analogSetAttenuation(ADC_0db);//(ADC_11db);
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = 1;
  pinMode(sensorPin,INPUT);

  for (;;) {
    vTaskDelay(xFrequency);
    //Resample on Frequency
    if ( micros() - lastRead  > periodRead) {
      readVal = 0;
      //Sample loop
      for ( int i = 0; i < nReads; i++) {
        readVal = readVal + analogRead(sensorPin);
      }
      //Select for sweep
      if(bMatrix[1] == true){
          dataPt = counter;
          counter++;
          if( counter > nReads*4095){
            counter = 0;
          }
          delayMicroseconds(250);
       }
       else{
          dataPt = readVal;// dataPt is global & atomic
          lastRead = micros();
       }
    }//end of AREAD
  }// end of For loop
  vTaskDelete( NULL );
}// end of Task


void USB_interface( void * parameter) {
  analogSetAttenuation(ADC_0db);//(ADC_11db);
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = 25;
  const uint8_t startChar = 255;
  const uint8_t commandLength = 3; //A command is 6 bytes long
  const uint8_t wordLength = 2; //The start word is 
 
  uint8_t dataBuffer[wordLength] = {0};
  uint8_t messageBuffer[commandLength*wordLength] = {0};
  uint8_t byteNumber = 0;
  uint8_t type = 0;
  bool scanning = true;
  bool newMessage = false;
  S convertType = {0.0};
    
  for (;;) {
    vTaskDelay(xFrequency);
    //Serial.println(millis());
      if(Serial.available() > 0){ // only act if there are bytes available in the buffer
    //Scan for two start bytes next to each other
    if(scanning  == true && newMessage == false){
      dataBuffer[1] = dataBuffer[0]; 
      dataBuffer[0] = Serial.read();
 //     Serial.print(dataBuffer[0]);
      // If there is a start character switch to parse mode
      if( dataBuffer[1] == startChar && dataBuffer[0] == startChar){
 //       Serial.print('\t');
        scanning = false; //Set State to parse command
        newMessage = true; //There is a message available to read
        dataBuffer[1] = 0; // reset the data buffer
        dataBuffer[0] = 0; // reset the data buffer
      }
    }
    //Parse Data
    else if( newMessage == true){
      //Loop through each word in command
      if( byteNumber < commandLength*wordLength){
        messageBuffer[byteNumber] = Serial.read();
//       Serial.print(byteNumber);
 //       Serial.print(messageBuffer[byteNumber]);
//        Serial.print('\t');
//        Serial.print(commandLength*wordLength);
        byteNumber++; 

        if( byteNumber >= commandLength*wordLength){
            byteNumber = 0; //at the end of the message reset the index
            scanning = true;
            
            //Act on the command received
        //SET COMMAND
            if(messageBuffer[0]/100 == 0){
           //   Serial.print("set");
              //Choose between types
              switch (messageBuffer[0]%100){ 
                case 0:{ //int32_t{
                  int32_t tempInt = 0;
                  for( int i = 2; i <= 6; i++){
                    EEPROM.write(messageBuffer[1]*4 + intStart + i - 2, messageBuffer[i]);
                    EEPROM.commit();
                    convertType.c[i-2] = EEPROM.read(messageBuffer[1]*4 + intStart + (i - 2));
                  }
                  iMatrix[messageBuffer[1]]= convertType.i;
                  Serial.print(iMatrix[messageBuffer[1]]);}
                  break;
                case 1:{//float
                  int32_t tempFloat = 0;
                  for( int i = 2; i <= 6  ; i++){
                    EEPROM.write(messageBuffer[1]*4 + floatStart + i - 2, messageBuffer[i]);
                    EEPROM.commit();
                    convertType.c[i-2] = EEPROM.read(messageBuffer[1]*4 + floatStart + i - 2);
                  }
                  fMatrix[messageBuffer[1]] = convertType.f;
                  Serial.print(fMatrix[messageBuffer[1]]);}
                  break;
                case 2://bool
                  EEPROM.write(messageBuffer[1], messageBuffer[2]);
                  EEPROM.commit();
                  bMatrix[messageBuffer[1]] = EEPROM.read(messageBuffer[1]); 
            //      Serial.print(bMatrix[messageBuffer[1]]);
                  break;
                }
             sendBinary(messageBuffer, 6, 2, startChar);  
            }
            //GET COMMAND
            else{
             // Serial.print("get");
              switch (messageBuffer[0]%100){ //What type is the data
                case 0: //int32_t
                  messageBuffer[2] = EEPROM.read(intStart + messageBuffer[1]*4 + 0);
                  messageBuffer[3] = EEPROM.read(intStart + messageBuffer[1]*4 + 1);
                  messageBuffer[4] = EEPROM.read(intStart + messageBuffer[1]*4 + 2);
                  messageBuffer[5] = EEPROM.read(intStart + messageBuffer[1]*4 + 3);
                  convertType.c[0] = messageBuffer[2];
                  convertType.c[1] = messageBuffer[3];
                  convertType.c[2] = messageBuffer[4];
                  convertType.c[3] = messageBuffer[5]; 
                  Serial.print(convertType.i);
                  break;
                case 1: //float
                  messageBuffer[2] = EEPROM.read(floatStart + messageBuffer[1]*4 + 0);
                  messageBuffer[3] = EEPROM.read(floatStart + messageBuffer[1]*4 + 1);
                  messageBuffer[4] = EEPROM.read(floatStart + messageBuffer[1]*4 + 2);
                  messageBuffer[5] = EEPROM.read(floatStart + messageBuffer[1]*4 + 3); 
                  convertType.c[0] = messageBuffer[2];
                  convertType.c[1] = messageBuffer[3];
                  convertType.c[2] = messageBuffer[4];
                  convertType.c[3] = messageBuffer[5]; 
                  Serial.print(convertType.f);
                  break;
                case 2: //bool
                  messageBuffer[2] = EEPROM.read(messageBuffer[1]);
                  messageBuffer[3] = EEPROM.read(messageBuffer[1]);
                  messageBuffer[4] = EEPROM.read(messageBuffer[1]);
                  messageBuffer[5] = EEPROM.read(messageBuffer[1]);
             //     Serial.print(bool(messageBuffer[2]));
                  break;
              }
            sendBinary(messageBuffer, 6, 2, startChar);
            }
            newMessage = false; 
        }
      }// end message
    }
  }//end available
  }//end of for(;;)
  vTaskDelete( NULL);
}

void sendBinary( uint8_t message[], uint8_t messageLength, uint8_t wordLength, uint8_t startChar){
  for(int i = 0; i < wordLength; i++){
    Serial.write(startChar);
  }
  for( int i = 0; i < messageLength; i++){
     Serial.write( message[i]); 
  }
 
}
void writeEEPROM( int address, uint8_t message[], uint8_t startIndex, uint8_t endIndex){
    for( int i = startIndex; i <= endIndex; i++){
      EEPROM.write(address + i, message[i]);
    }
    EEPROM.commit();
}

void updateFromEEPROM(void *var  , int arraySize, int type, int index){
  S convertType;
  switch(type){
    case 0:
      for (int i = 0; i < arraySize; i++){
        //step through the elments of the array and update from EEPROM
        convertType.c[0] = EEPROM.read(index + i*4    );
        convertType.c[1] = EEPROM.read(index + i*4 + 1);
        convertType.c[2] = EEPROM.read(index + i*4 + 2);
        convertType.c[3] = EEPROM.read(index + i*4 + 2);   
        *((int32_t*)var + i) = convertType.i;       
      }
      break;
    case 1:
      for (int i = 0; i < arraySize; i++){
        //step through the elments of the array and update from EEPROM
        convertType.c[0] = EEPROM.read(index + i*4    );
        convertType.c[1] = EEPROM.read(index + i*4 + 1);
        convertType.c[2] = EEPROM.read(index + i*4 + 2);
        convertType.c[3] = EEPROM.read(index + i*4 + 2);
        *((float*)var + i) = convertType.f;                       
      }
      break;
    case 2:
      for (int i = 0; i < arraySize; i++){
        //step through the elments of the array and update from EEPROM
        *((bool*)var + i) = bool(EEPROM.read(index + i));                       
      }
      break;
  } // END Of SWITCH
}//end of updateFromEEPROM
