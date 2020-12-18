%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>��ʼ������>>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
clc,clear,close all;
fs = 3000000;
Time_Hold_On1 = 0.0005;%ÿ����Ԫ�ĳ���ʱ��
Time_Hold_On = Time_Hold_On1*2;%������Ԫ�ĳ���ʱ��
Num_Unit = fs*Time_Hold_On;% fs * Time_Hold_On;%ÿ������Ԫ��ȡ������-3000

one_Level = zeros ( 1, Num_Unit );
two_Level = ones ( 1, Num_Unit );
three_Level = 2*ones ( 1, Num_Unit );
four_Level = 3*ones ( 1, Num_Unit );

A = 1;				                                % the default ampilitude is 1
w1 =30000;                                             %��ʼ���ز�Ƶ��
w2 =60000;
w3=90000;
w4=120000;
%>>>>>>>>>>>>>>>������Ԫ>>>>>>>>>>>>>>>>
num=10;%�ܹ�10����
code=rand(1,num);
code(code>0.5)=1;
code(code<=0.5)=0;
Sign_Set=code;
% Sign_Set=[0,0,1,1,0,1,1,0,1,0,1,0,1,0,0,1]
Lenth_Of_Sign_Set = length ( Sign_Set );  %�����źų���

%>>>>>>>>>>>>>>>����ʼ��Ԫͼ>>>>>>>>>>>>>>>>>
t1 = 0 : 1/(2*fs) : Time_Hold_On1 * Lenth_Of_Sign_Set- 1/(2*fs);
orign=zeros ( 1, Num_Unit * Lenth_Of_Sign_Set);
for i = 1 : Lenth_Of_Sign_Set
    orign( (i-1)*Num_Unit + 1 : i*Num_Unit) = Sign_Set(i);
end
figure
plot(t1,orign);

%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>����ת��>>>>>>>>>>>>>>>
%---------------------------------------------------
j=1;
for I=1:2:Lenth_Of_Sign_Set                            %�źŷ������·�ź�
    Sign_Set1(j)= Sign_Set(I);Sign_Set2(j)=Sign_Set(I+1);%����λ����set1�ż��λ����set2��
    j=j+1;
end

Lenth_Of_Sign = length ( Sign_Set1 );     %8λ
st = zeros ( 1, Num_Unit * Lenth_Of_Sign/2 );
sign_orign = zeros ( 1, Num_Unit * Lenth_Of_Sign/2 );%
sign_result = zeros ( 1, Num_Unit * Lenth_Of_Sign/2 );
t = 0 : 1/fs : Time_Hold_On * Lenth_Of_Sign- 1/fs;


%---------------------------------------------------
%>>>>>>>>>>>���������ź�>>>>>>>>>>>>
%---------------------------------------------------
for I = 1 : Lenth_Of_Sign
    if ((Sign_Set1(I) == 0)&(Sign_Set2(I) == 0))                        %00Ϊ1��ƽ
        sign_orign( (I-1)*Num_Unit + 1 : I*Num_Unit) = one_Level;
    elseif ((Sign_Set1(I) == 0)&(Sign_Set2(I) == 1))                     %01Ϊ2��ƽ
        sign_orign( (I-1)*Num_Unit + 1 : I*Num_Unit) = two_Level;
    elseif ((Sign_Set1(I) == 1)&(Sign_Set2(I) == 1))                     %11Ϊ3��ƽ
        sign_orign( (I-1)*Num_Unit + 1 : I*Num_Unit) = three_Level;
    else                                                         %10Ϊ4��ƽ
        sign_orign( (I-1)*Num_Unit + 1 : I*Num_Unit) = four_Level;
    end
end

%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>����Ƶ���ź�>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
for I = 1 : Lenth_Of_Sign
    if ((Sign_Set1(I) == 0)&(Sign_Set2(I) == 0))                     %00Ϊ�ز�w1
        st((I-1)*Num_Unit + 1 : I*Num_Unit) = A * cos ( 2 * pi * w1 * t( (I-1)*Num_Unit + 1 : I*Num_Unit ) );
    elseif ((Sign_Set1(I) == 0)&(Sign_Set2(I) == 1))                 %01Ϊ�ز�w2
        st( (I-1)*Num_Unit + 1 : I*Num_Unit) = A * cos ( 2 * pi * w2 * t((I-1)*Num_Unit + 1 : I*Num_Unit ) );
    elseif ((Sign_Set1(I) == 1)&(Sign_Set2(I) == 1))                   %11Ϊ�ز�w3
        st( (I-1)*Num_Unit + 1 : I*Num_Unit) = A * cos ( 2 * pi * w3 * t((I-1)*Num_Unit + 1 : I*Num_Unit ) );
    else                                                       %10Ϊ�ز�w4
        st( (I-1)*Num_Unit + 1 : I*Num_Unit) = A * cos ( 2 * pi * w4 * t( (I-1)*Num_Unit + 1 :I*Num_Unit ) );
    end
end

%---------------------------------------------------
%>>>>>>>>>>>>>>>����ʼ�ź�ͼ>>>>>>>>>>>>>>>>>
%---------------------------------------------------
figure
subplot ( 2, 1, 1 )
plot ( t, sign_orign );
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1),-A/2, 3*A+A/2] );
title ( 'The original Signal' );
grid;

subplot ( 2, 1, 2 )
plot ( t, st );              % the signal after modulation
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), -A, A ] );
title ( 'the signal after modulation' );
grid;
figure
plot ( t, st );
%>>>>>>>>.���źż����˹����������������������
st = awgn(st,40);
figure
plot ( t, st );
%---------------------------------------------------
%>>>>>>>>>>>>>>>��ͨ�˲���>>>>>>>>>>>>>>
%---------------------------------------------------
%- design the bandpass [ 250 250 ]
wp = [ 2*pi*25000 2*pi*35000 ];          %ͨ��
ws = [ 2*pi*5000 2*pi*50000 ];            %���
[N,wn]=buttord(wp,ws,1,30,'s');
[b,a]=butter( N,wn,'bandpass','s');
[bz,az]=impinvar(b,a,fs);             %ӳ��Ϊ���ֵ�

dt1 = filter(bz,az,st);                     %��ͨȡ��Ƶ��w1
figure
subplot( 2, 2, 1 )
plot(t,dt1);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( 'The element of 30000 Hz' );

wp = [ 2*pi*55000 2*pi*65000 ];
ws = [ 2*pi*40000 2*pi*80000];
[N,wn]=buttord(wp,ws,1,30,'s');
[b,a]=butter( N,wn,'bandpass','s');
[bz,az]=impinvar(b,a,fs);
dt2 = filter(bz,az,st);                         %��ͨȡ��Ƶ��w2
subplot( 2, 2, 2 )
plot(t,dt2);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( 'The element of 60000 Hz' );
grid;

wp = [ 2*pi*85000 2*pi*95000];
ws = [ 2*pi*70000 2*pi*110000 ];
[N,wn]=buttord(wp,ws,1,30,'s');
[b,a]=butter( N,wn,'bandpass','s');
[bz,az]=impinvar(b,a,fs);
dt3 = filter(bz,az,st);                 %��ͨȡ��Ƶ��w3
subplot( 2, 2, 3 )
plot(t,dt3);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( 'The element of 90000 Hz' );

wp = [ 2*pi*115000 2*pi*125000];
ws = [ 2*pi*100000 2*pi*140000 ];
[N,wn]=buttord(wp,ws,1,30,'s');
[b,a]=butter( N,wn,'bandpass','s');
[bz,az]=impinvar(b,a,fs);
dt4 = filter(bz,az,st);
subplot( 2, 2, 4 )
plot(t,dt4);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( 'The element of 120000 Hz' );
%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>>��ɽ��>>>>>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
dt1  = dt1 .* cos ( 2 * pi * w1 * t );           %����ز�1
dt2  = dt2 .* cos ( 2 * pi * w2 * t );           %����ز�2
dt3  = dt3 .* cos ( 2 * pi * w3 * t );           %����ز�3
dt4  = dt4 .* cos ( 2 * pi * w4 * t );           %����ز�4

s2=dt2;

[f,sf2]=T2F(t,s2);
figure(7777);
subplot(1,1,2);
plot(t,sf2,'r');
title('�ز�1���ƺ��ź�Ƶ��');







figure
subplot( 2, 2, 1 )
plot(t,dt1);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '30000Hz������ɽ����Ĳ���' );
grid

subplot( 2, 2, 2 )
plot(t,dt2);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '60000Hz������ɽ����Ĳ���' );
grid;
subplot( 2, 2, 3 )
plot(t,dt3);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '90000Hz������ɽ����Ĳ���' );
grid
subplot( 2, 2, 4 )
plot(t,dt4);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '120000Hz������ɽ����Ĳ���' );
grid

%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>>��ͨ�˲���>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
[N,Wn] = buttord( 2*pi*5000, 2*pi*15000,3,25,'s');      %�ٽ�Ƶ�ʲ��ý�Ƶ�ʱ�ʾ
[b,a]=butter(N,Wn,'s');
[bz,az]=impinvar(b,a,fs);                       %ӳ��Ϊ���ֵ�

dt1 = filter(bz,az,dt1);
dt2 = filter(bz,az,dt2);
dt3 = filter(bz,az,dt3);
dt4 = filter(bz,az,dt4);

figure
subplot( 2, 2, 1 )
plot(t,dt1);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '30000Hz������ͨ�˲���Ĳ���' );
grid

subplot( 2, 2, 2 )
plot(t,dt2);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '60000Hz������ͨ�˲���Ĳ���' );
grid;

subplot( 2, 2, 3 )
plot(t,dt3);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '90000Hz������ͨ�˲���Ĳ���' );
grid

subplot( 2, 2, 4 )
plot(t,dt4);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '120000Hz������ͨ�˲���Ĳ���' );
grid
%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>>�����о�>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
for I = 1 : Lenth_Of_Sign
    if (dt1((2*I-1)*Num_Unit/2) > dt2((2*I-1)*Num_Unit/2))&&(dt1((2*I-1)*Num_Unit/2) > dt3((2*I-1)*Num_Unit/2))&&(dt1((2*I-1)*Num_Unit/2) > dt4((2*I-1)*Num_Unit/2))
        sign_result( (I-1)*Num_Unit + 1 : I*Num_Unit) = one_Level;
        a(I)=0;b(I)=0;
    elseif (dt2((2*I-1)*Num_Unit/2) > dt1((2*I-1)*Num_Unit/2))&&(dt2((2*I-1)*Num_Unit/2) > dt3((2*I-1)*Num_Unit/2))&&(dt2((2*I-1)*Num_Unit/2) > dt4((2*I-1)*Num_Unit/2))
        sign_result( (I-1)*Num_Unit + 1 : I*Num_Unit) = two_Level;
        a(I)=0;b(I)=1;
    elseif (dt3((2*I-1)*Num_Unit/2) > dt1((2*I-1)*Num_Unit/2))&&(dt3((2*I-1)*Num_Unit/2) > dt2((2*I-1)*Num_Unit/2))&&(dt3((2*I-1)*Num_Unit/2) > dt4((2*I-1)*Num_Unit/2))
        sign_result( (I-1)*Num_Unit + 1 : I*Num_Unit) =three_Level;
        a(I)=1;b(I)=1;
    else
        sign_result( (I-1)*Num_Unit + 1 : I*Num_Unit) =four_Level;
        a(I)=1;b(I)=0;
    end
end
figure
plot ( t, sign_result );
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), -A/2, 3*A+A/2 ] );
title ( '��������Ĳ���' );
grid
%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>>����ת��>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
signdemo=[];
for I=1:Lenth_Of_Sign
    signdemo=[signdemo,a(I),b(I)];
    
end
%>>>>>>>>>>>>>>>>>>>>>�������Ԫͼ>>>>>>>>>>>>>>>>>>>>>
%>>>>>>>>>>>>>>>����ʼ��Ԫͼ>>>>>>>>>>>>>>>>>
result=zeros ( 1, Num_Unit * Lenth_Of_Sign_Set);
for i = 1 : Lenth_Of_Sign_Set
    result( (i-1)*Num_Unit + 1 : i*Num_Unit) = signdemo(i);
end
figure
plot(t1,result);

% >>>>>>>>>>>>>>����������ģ��>>>>>>>>>>>>>>>>
c=signdemo==Sign_Set; %�������
num_zero= sum(c(:)==0);
errorRate=num_zero/num;
