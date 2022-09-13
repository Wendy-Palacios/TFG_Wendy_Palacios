function []=DAQ_Start()
global Arduino_COM
%Se define el puerto a abrir y su valor de baud.
Arduino_COM=serial('COM3','BaudRate',230400);
%Se abre el puerto indicado
fopen(Arduino_COM);
end