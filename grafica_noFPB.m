%El objetivo de la función es obtener los valores de las muestras obtenidas
%del sensor, adquiridas desde arduino y solicitadas desde Matlab.
%En este caso se obtiene el valor de la variable.
%       -> Gráfica tiempo-tensión: la vbl será "tensión", por otro lado la
%       variable "tiempo" se calcula desde App Designer en v_principal
function [tension]=grafica_noFPB()
global Arduino_COM
dato_arduino=zeros(1,750);%se guarda la señal adquirida de Arduino cada vez 
                          %que se llama a la función.
%% Recibir datos, acondicionarlos en la escala correspondiente
%Los valores que se reciben están en un valor digital que varía de 0 a
%1023, es por ello, que será necesario dimensionarlo a V (0V-3.3V).
    Comando=uint8(120);%cada vez que se envíe el valor de 120, Arduino se 
                       %dispondrá a enviar los datos a través del bus.
    fwrite(Arduino_COM, Comando,'uchar');  

%% Se van almacenando los datos que se reciben del bus
     for j=1:1:750
         dato=fscanf(Arduino_COM, '%d');
         dato_arduino(j)=dato;
     end
     dato_arduino=dato_arduino*(3.3/1024);
%% Eliminar DC
    dato_arduino=dato_arduino-mean(dato_arduino); 
    tension=dato_arduino;
end 