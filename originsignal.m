clear;
clc;
T=0.0005;
t=-0.01:T:0.01;
fs=2000;
sdt=1/fs;
t1=-0.01:sdt:0.01;
xt=cos(2*pi*30*t)+sin(2*pi*120*t);
st=cos(2*pi*30*t1)+sin(2*pi*120*t1);
max = max(abs(st));

% ԭʼ�ź�
figure;
subplot(2,1,1);plot(t,xt);title('ԭʼ�ź�');
grid on;
subplot(2,1,2);stem(t1,st,'.');title('�����ź�');
grid on;















