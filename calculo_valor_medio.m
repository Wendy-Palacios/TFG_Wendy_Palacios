%El objetivo de la función es obtener los valores medios de los intervalos
%de tiempo, y en algunos casos tensión(para la onda P, T). Estos datos se 
%guardan en la vbl "media". 
%Por otro lado, en la variable "datos", se guardan 3 datos (valor máximo,
%valor mínimo, y valor de intervalo para el período correspondiente)

function [media,datos] = calculo_valor_medio(val_Max,val_Min,maximo,aux)
%val_Max: indica el valor del tiempo/tensión en el momento inicial de
%periodo de la onda
%val_Min: indica el valor del tiempo/tensión en el momento final de
%periodo de la onda
%maximo: es el nº de periodos que se deben calcular
%aux: permite conocer el caso que se desea analizar

intervalos=[];%Valor del intervalo de tiempo o en algunos caso tensión.

if aux==0   %Caso para conocer el valor medio del intervalo R-R
    for i=2:1:maximo
        intervalo= val_Max(i)- val_Max(i-1);
        intervalos=[intervalos, intervalo];
    end
    datos=[];
    x=length(intervalos);
    for i=2:1:(x+1)
        datos=[datos;{val_Max(i-1),val_Max(i),intervalos(i-1)}];
    end
    
elseif aux==1 %Caso para conocer el valor medio del intervalo T
    for i=2:1:maximo
        intervalo= val_Max(i)- val_Min(i);
        intervalos=[intervalos, intervalo];
    end
    datos=[];
    x=length(intervalos);
    for i=1:1:x
        datos=[datos;{val_Min(i),val_Max(i),intervalos(i)}];
    end
    
elseif aux==2 %Caso para conocer el valor medio del resto de parámetros que
              %no se contempla en la condición anterior y posterior.
    for i=1:1:maximo
        intervalo= val_Max(i)- val_Min(i);
        intervalos=[intervalos, intervalo];
    end
    datos=[];
    x=length(intervalos);
    for i=1:1:x
        datos=[datos;{val_Min(i),val_Max(i),intervalos(i)}];
    end
end
media=mean(intervalos)*1000; %valor medio en mV o ms
end