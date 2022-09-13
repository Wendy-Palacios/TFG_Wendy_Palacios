%El objetivo de la función es poder detectar los valores de interés, es 
%decir las ondas de una señal ECG, y en algunos casos también será 
%necesario conocer donde empieza y/o acaba. El método (en el mayor de los 
%casos)para poder detectar los valores de los parámetros será ir analizando
%el valor de la pendiente. 
%En otros casos, cuando ya se tenga la información suficiente de ciertas 
%ondas, será suficiente con encontrar el valor máximo dentro de un rango 
%determinado.
%Cada vez que se encuentra un punto deseado, se interrumpe el bucle y se 
%busca el siguiente punto en el siguiente intervalo.

function [valores_tension,valores_tiempo,valores_posiciones]=detectar_valores(tipo,tension,tiempo,umbral,max1,min,posiciones,incr,max2)
%tipo: permite conocer el caso que se desea analizar
%tension: puede ser "tension" o "ecg_filtrada", que se definen en 
        %v_principal().
%tiempo: vector tiempo 
%umbral: valor que se debe cumplir o superar para considerar que el punto 
        %hallado es el deseado.
%max1,min:nº veces máximas, mínimas que se podruce el bucle for NO anidado.
%max2:nº de veces máximas que se realiza el for anidado.
%incr:el incremento que se produce en el bucle for.
%posiciones:vector que tiene almacenado las posiciones del intervalo que se
            %va a ir teniendo en cuenta para hallar cada onda.
%% Variables de salida
puntos=[];%vbl que guarda la tensión en un instante dado.
puntos_tiempo=[];%vbl que guarda el tiempo donde se produce el punto de 
                 %interés
posicion=[];%vbl que indica el índice de la muestra dentro del vector donde
            %está almacenado.
%% Variables auxiliares
%pendiente_s, se calcula la pendiente de subida.
%pendiente_b, secalcula la pendiente de bajada. 
%% Caso para hallar las ondas R
if tipo==0 
%El 1º bucle va desde la muestra 1 de tension hasta el final
    for i=1:incr:max1
%1ºCondición superar el umbral que será >= 35% de la onda más grande
        if (tension(i)>=umbral)
            pendiente_s= tension(i)-tension(i-1);
            pendiente_b= tension(i+1) - tension(i);
%%2ºCondición, que la muestra sea superior al valor anterior y posterior.
            if (pendiente_s>0 && pendiente_b<0)
                puntos=[puntos,tension(i)];
                puntos_tiempo=[puntos_tiempo, tiempo(i)];
                posicion=[posicion,i];
            end
        end
    end
%% Caso para hallar las ondas Q y S
%1º Se halla la onda Q, para acotar su búsqueda, se determina el rango de 
%muestras a tener en cuenta, esto es, 2:1:dim_R,dim_R es el vector donde se
%calcula el nº de ondas R. Esto determinará que el bucle anidado vaya 
%posiciones(i):incr:posiciones(i+incr), es decir,
%posiciones_R(almacena las posiciones de las ondas R):1:(i-1), por tanto, 
%la primera onda Q hallada pertenecerá a la segunda onda R y la última a la
%penúltima onda Q.

%2º Se halla la onda S, previamente ya se conocen los puntos de inicio de
%la onda Q. El valor de "i" irá de 1:1:dim_onda, por tanto la búsqueda se
%acotará para cada onda S, desde la posición R correspondiente:1:la
%siguiente onda R.
elseif tipo==1 %Caso para  hallar ondas negativas (Q,S)
    for i=min:1:max1
        for j=posiciones(i):incr:posiciones(i+incr)
%1ºCondición que el punto sea negativo
            if tension(j)<0
                pendiente_b= tension(j-1) - tension(j);
                pendiente_s= tension(j+1) - tension(j);   
%2ºCondición, que la muestra sea inferior al valor anterior y posterior.                
                if pendiente_b>0 && pendiente_s>0
                    puntos=[puntos, tension(j)];
                    puntos_tiempo=[puntos_tiempo, tiempo(j)];
                    posicion=[posicion,j];
                    break;
                end
            end

        end
    end
%% Caso para hallar el punto de inicio de la onda Q, y el punto donde acaba la onda S.
%1º Se halla los puntos de inicio de cada onda Q. Para acotar su búsqueda,
%se determina el rango de muestras a tener en cuenta,esto es, 1:1:dim_onda.
%El bucle anidado vaya posiciones(i):incr:max2, es decir,
%posiciones_Q(almacena las posiciones de las ondas Q):-1:0, por tanto, el 
%primer punto hallado pertenecerá a la primera onda Q almacenada en su 
%vector correspondiente, y asi sucesivamente.

%2º Se halla los puntos de fin de cada onda S, previamente ya se conocen
%los puntos de inicio de la onda Q. Los bucles tendrán las variables 
%asociadas a la onda S,la diferencia es el valor que tiene "incr" que es -1    
elseif tipo==2 
    for i=min:1:max1
      for j=posiciones(i):incr:max2
           pendiente_b= tension(j+1)-tension(j);
           pendiente_s= tension(j)-tension(j-1);
%1ºCaso, los puntos deberán pasar por 0, o estar muy cerca, es por ello que
%se elige el valor inmediato a 0.           
           if tension(j)>=0
               puntos=[puntos, tension(j)];
               puntos_tiempo=[puntos_tiempo,tiempo(j)];
               posicion=[posicion,j];
               break;
%2ºCaso, cuando no es posible ser >=0, se analiza el punto inferior a 0 
%cumpliendo la condición de que la muestra sea superior a la muestra 
%anterior y posterior.            
           elseif (tension(j)<0 && pendiente_b<0 && pendiente_s>0)
               puntos=[puntos, tension(j)];
               puntos_tiempo=[puntos_tiempo,tiempo(j)];
               posicion=[posicion,j];
               break;
           end
      end
    end
%% Caso para hallar el punto T,P 
%1ºAl haber detectado las ondas anteriores, conocer sus valores resultará 
%más sencillo, ya que, valdrá con encontrar primero los punto más altos 
%dentro del intervalo donde acaba la onda S(del periodo anterior) a 
%Q(del periodo actual). 

%2ºSeguidamente se halla los puntos P, acotando más dicho intervalo, entre
%el punto donde acaba la onda T del periodo anterior hasta la onda Q (del 
%periodo actual).
elseif tipo==3               
    for i=1:1:max2
        [punto,j]=max(tension(min(i): max1(i)));  
        puntos=[puntos, punto];
        puntos_tiempo=[puntos_tiempo, tiempo(j+min(i))];
        j=min(i)+j-1;
        posicion=[posicion,j];
    end
%% Caso para hallar los puntos de inicio y fin de las ondas T,P.
%En estos casos se debrá cumplir un valor de umbral del 1%
%1ºPuntos de inicio y fin de la onda T
    %-Puntos de inicio, i=min:1:max1 (1:1:dim_posT). El segundo bucle acota
    % la busqueda entre posiciones(i):incr:max2,es decir, posicionesT:-1:0.
    %-Puntos de fin, varía los valores del según for, posicionesT:1:n_muestras
%2ºPuntos de inicio y fin de la onda P
    %-Puntos de inicio, similar al anterior, varían las variables dim_posT 
    % a dim_posP, posicionesT a posicionesT
    %-Puntos de fin, varía los valores del según for, posicionesP:1:n_muestras
elseif tipo==4 
      for i=min:1:max1
       for j=posiciones(i):incr:max2
           pendiente_s= tension(j+1)-tension(j);
           pendiente_b= tension(j)-tension(j-1);
%1ºCaso, deberá ser <=0 y además cumplir un valor <= a la vbl umbral(tiene un valor  muy cercano a 0)          
           if (tension(j)<=0 && tension(j)<=umbral(i))
               puntos=[puntos, tension(j)];
               puntos_tiempo=[puntos_tiempo,tiempo(j)];
               posicion=[posicion,j];
               break;
%2ºCaso no pasa por 0, se estudia el punto que sea inmediantemente superior a 0 y teniendo en cuenta que el
%valor de la muestra deberá ser inferior al valor anterior y posterior.
           elseif (tension(j)>0 && pendiente_b<0 && pendiente_s>0 && tension(j)<=umbral(i))
               puntos=[puntos, tension(j)];
               puntos_tiempo=[puntos_tiempo,tiempo(j)];
               posicion=[posicion,j];
               break;
           end
       end
      end
end
%Se guarda cada  vector auxiliar en su salida correspondiente
valores_tension=puntos;
valores_tiempo=puntos_tiempo;
valores_posiciones=posicion;
end