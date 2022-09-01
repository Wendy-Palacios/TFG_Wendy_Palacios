
/*DEFINICIÓN DE VARIABLES GLOBALES, 1 número entero son 2 bytes*/
const int pin_sensor=A0; //variable entrada sensor ECG
int tiempo_lectura=2;
int sensor;
unsigned int datos_enviar[750];
char mensaje;
void setup() {
  Serial.begin(230400);
}

void loop() {  
  /*Se realiza 750 lecturas y se almacena en un vector*/
  for (int i = 0; i < 750; i++)
  {
    sensor = analogRead(pin_sensor);  //valor del sensor
    datos_enviar[i]=sensor; 
    delay(tiempo_lectura);    //tiempo entre cada muestra   
  }
 
 if(Serial.available() > 0) {  
      /*VALOR enviado por Matlab, orden enviar datos:
      Arduino -> Matlab*/
   char mensaje = Serial.read();
    if (mensaje==120)
    {
        for (int i = 0; i < 750; i++)
        {
          Serial.println(datos_enviar[i]); 
        }
       
    }
  }
}
