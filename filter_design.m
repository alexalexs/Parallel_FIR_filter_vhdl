clc
clear all
clf
%% Create four signals y1 y2 y3 y4
N_bit=8; % filter coefficients width
N_length=4; % Array length of pi/4 sin
N=200;  % n-points for testbench
t_max=N_length*10e-12;
f=1/t_max/1*15; % freq
t=linspace(0,t_max,N);
period=t(2)-t(1);
y1=sin(2.2*pi*f*t+1)+1; % signal 1
y2=sin(1.3*2*pi*f*t+2)+1; % signal 2
y3=sin(6*2*pi*f*t+3)+1; % signal 3
y4=sin(2.1*2*pi*f*t+4)+1; % signal 4
y=y1+y2+y3+y4; % sum of signals
edges=0:1/(2^N_bit-1):max(abs(y))+0.1; % discretization
y_discr=discretize(y,edges);
[Y,E]=discretize(t,0:t_max/N_length:t_max+(t_max/N_length)*1);
t_discr=E(Y);
% Plot
subplot(2,2,1)
plot(t,y./max(y))
hold on
title(['four signals'])
xlabel('s')
subplot(2,2,2)
plot(t,y1+y2)
xlabel('s')
title('two signals')
%% Converting signal to binary
y_discr_norm=edges(y_discr);
y_discr_norm_bin=dec2base(round(y_discr_norm.*(2^(N_bit+1-4)-2)),2,N_bit+1);
y_bit_trunc=y_discr_norm_bin(:,1:N_bit);
y_bit_trunc(1:N/N_length:end,:);
str_="b"""+join(string(y_bit_trunc(1:end,:))','",b"');
str_write=join(string(y_bit_trunc(1:end,:))','\n');
y_discr_norm2=base2dec(y_bit_trunc,2)';
y_discr_norm2=y_discr_norm2./max(y_discr_norm2);
%% Write to file
file=fopen('input.txt','w');
fprintf(file,str_write,'%d');
fclose(file);
%% Binary signal check
y_temp=bin2dec(y_bit_trunc);
% Plot
subplot(2,2,1)
plot(t,y_temp./max(y_temp))
%% Creation  Filter
Fpass = 30;
Fstop = 200;
Apass =1 ;
Astop = 30;
Fs = 1000;
d = designfilt('lowpassfir', ...
  'PassbandFrequency',Fpass,'StopbandFrequency',Fstop, ...
  'PassbandRipple',Apass,'StopbandAttenuation',Astop, ...
  'DesignMethod','equiripple','SampleRate',Fs);
% fvtool(d)
d.Coefficients;
%% Filter coefficients for array_coeff in filter.vhdl 
array_coeff=join(string(dec2bin(d.Coefficients*100000)),""",""0")
%% Filtered signals
y_filter=filter(d,y);
% Plot
subplot(2,2,4)
plot(t,y_filter./max(y_filter))
hold on
title('filtered')
%% Calculate FFT
[n_f,y_fft_norm_half]=fft_fun(t,y);
subplot(2,2,3)
plot(n_f,y_fft_norm_half)
hold on
[n_f,y_fft_norm_half]=fft_fun(t,y_filter);
plot(n_f,y_fft_norm_half)
% axis([0 3e11 0 1])
hold on
title('FFT')
xlabel('freq')
ylabel('db')
%% Filter tool plot
% figure
% freqz(d.Coefficients,1)
%% Read file from ModelSim
file=fopen('output.txt','r');
A=split(fscanf(file,'%c'));
A(1:length(d.Coefficients)+2)={'0'};
A(1:3)=[];
A(end)=[];
fclose(file);
%% Converting binary signed to int8->double
y_out_dec=typecast(uint8(bin2dec(A)), 'int8'); % Converting to signed data
y_out_dec_norm=double(y_out_dec)./double(max(max(abs(y_out_dec)))); % Converting to double
x_out=(1:length(y_out_dec)).*period-period*1; % offset on one sample period for modelsim data
% Plot
subplot(2,2,4)
plot(x_out,y_out_dec_norm./max(y_out_dec_norm))
xlabel('s')
hold on
legend({'signals','modelsim'})
%% Calculation FFT
[n_f,y_fft_norm_half]=fft_fun(x_out,y_out_dec_norm);
% Plot
subplot(2,2,3)
plot(n_f,y_fft_norm_half)
legend({'env','filtered','modelsim'})
%% FFT function
function [n_f,y_fft_norm_half]=fft_fun(x,y)
Fs=1/(x(2)-x(1)); % sample freq
N_fft=1024*4;
y_fft=abs(fft(y,N_fft));
y_fft_norm=y_fft./max(y_fft);
y_fft_norm_half=10.*log10(abs(y_fft_norm(1:N_fft/2).^2));
n_f=Fs.*(0:N_fft/2-1)./N_fft;
end