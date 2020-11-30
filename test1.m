clear ;
clc;             %A=3.5;
f=1000;
fs=8*10^3;
T=1/fs;
w=2*pi*f;
t=0:0.00000001:0.008;
y=3.5*sin(w*t);% �����ź�

figure(1)
Signal_m=y;
plot(t,Signal_m);
title('�����ԭʼ�ź�');
grid;
n=1:100;% �����ĸ���0
fs=8*10^3;
Y(n)=1;%���������ֵΪ1

figure(2)
stem(n,Y(n));
axis([0 50 0 1]);
xlabel('n');
ylabel(' ���� ');
legend(' ���������ź� ');

n=1:100;
fs=2*10^3;
T=1/fs;
w=2*pi*f;
s=3.5*sin(w*n*T);
figure(3)
stem(n,s);% ʱ���������ź�ͼ
axis([0 100 -4 4]);
xlabel('n');
ylabel(' ���� ');
legend(' ʱ������ź�ͼ ');

f=n./(100*T);
y1=abs(fft(s));
figure(4)
plot(f,y1);
xlabel('f');
ylabel(' ��Ƶ ');
legend(' �����ź�Ƶ�� ');

%====================================================================
% >>>>>>>>>>>>>>>>>>>>>>PCM Encoding<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%====================================================================
Is = round(2048 * (Signal_m/10));	% ����ת��
Len = length(Is);			% Get the lenght of the Code vertor
Code = zeros(Len,8);

%---------------------------------������-----------------------------------c1
y=abs(y);
for i = 1:Len
    if(Is(i) > 0)
        Code(i,1) = 1;
    end
end
%----------------------------------������----------------------------------
Signal = abs(Is);
for i = 1:Len
    sign_temp = Signal(i);
    for j = 0 : 7
        sign_temp = sign_temp / 2;
        if sign_temp < 8
            break;
        end
    end
    bin_temp = dec2bin(j,3);
    temp = num2str(bin_temp, 3);
    Code(i,2) = bin2dec(temp(1));
    Code(i,3) = bin2dec(temp(2));
    Code(i,4) = bin2dec(temp(3));
end
% ---------------------------------������---------------------------------
Start_Level = [0,16,32,64,128,256,512,1024];				%��������ƽ   %�������
Quan_Interval = [1,1,2,4,8,16,32,64];					%�����������%����16���õ�ÿ�ε���С�������
ParagraphN = zeros(1,Len);
for i = 1:Len
    ParagraphN(i) = Code(i,2)*4 + Code(i,3)*2 + Code(i,4) + 1;	%����ڶ��ڵ�λ��
end

for i = 1:Len
    ZeltaLevel = Signal(i) - Start_Level(ParagraphN(i));		%��ȥ��ʵ��ƽ֮��ĵ�ѹ
    Cur_LHJG = Quan_Interval(ParagraphN(i));
    dec_temp = ZeltaLevel/Cur_LHJG;
    bin_temp = dec2bin(dec_temp,4);
    temp = num2str(bin_temp,4);
    Code(i,5) = bin2dec(temp(1));  %���������Ϊ������
    Code(i,6) = bin2dec(temp(2));
    Code(i,7) = bin2dec(temp(3));
    Code(i,8) = bin2dec(temp(4));
end
 

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>coding part<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Quan_Unit = zeros(1,Len);
Quan_Value = zeros(1,Len);
Mark = zeros(1,Len);
Signal_trans = zeros(1,Len);
%-----------pcm����---------------------
%figure(4);
%stairs(ParagraphN);
%title('PCM ����');
%xlabel('t(s)');
%grid on;


for i = 1:Len
    ParagraphN(i) = Code(i,2)*4 + Code(i,3)*2 + Code(i,4) + 1;
    
    Quan_Unit(i) = Code(i,5)*8 + Code(i,6)*4 + Code(i,7)*2 + Code(i,8);
   
    Mark(i) = Start_Level(ParagraphN(i));
    
    Quan_Value(i) = Quan_Interval(ParagraphN(i));
    
    sign = 1;
    if(Code(i,1) == 0)
        sign = -1;
    end
    Signal_trans(i) = sign * (Mark(i) + Quan_Value(i) * Quan_Unit(i));
end

for i = 1:Len
    Signal_trans(i) = 10 * (Signal_trans(i)/2048);
end

figure(5)
subplot(2,1,1);
plot(t,Signal_trans);
xlabel('t(s)');
title('PCM ��ԭ����ź�');
grid;
subplot(2,1,2);

plot(t,Signal_m);
title('�����ԭʼ�ź�');
xlabel('t(s)');
grid;

% ----------------------------����������------------------------------------
da=0;
for i=1:length(t)
    dc=(y(i)-Signal_trans(i))^2/length(t);
    da=da+dc;
end
fprintf('�����ʣ�%.6f\n',da);%������λС��



