%El objetivo de la función es obtener los valores de las muestras
%atenuadas, eliminando las interferecnias a altas frecuencias.
%En este caso se almacenan 3 salidas, divididas en 2 gráficas diferentes:
%       -> Gráfica tiempo-tensión: las vbls serán "ecg_filtrada".
%       -> Gráfica frecuencia-amplitud: las vbls serán "v_frec","fft_ecg".
function [ecg_filtrada,v_frec,fft_ecg]=grafica_FPB(tension)
%% Diseño de un FILTRO PASO BAJO
    %Filtro paso bajo, objetivo eliminar ruido superior a 90Hz:
    %Características del filtro: (toolbox: filterDesigner)
    t_muestreo=0.002;%período de muestreo
    fs=1/t_muestreo;%frecuencia de muestreo
    N  = 1;%orden del filtro
    Fc = 90;%frecuencia de corte
    h1  = fdesign.lowpass('N,F3dB', N, Fc, fs);
    Hd1 = design(h1, 'butter');
    ecg_filtrada=filter(Hd1,tension);  
    
    %% Variables para representar la FFT
    fft_ecg=fft(ecg_filtrada);
    fft_ecg=abs(fft_ecg);
    fft_ecg=fft_ecg(1:round(end/2));  
    fft_ecg=fft_ecg/max(abs(fft_ecg));
    tam_fft=length(fft_ecg);
    v_frec=(1:1:tam_fft)*((fs/2)/tam_fft);
end 