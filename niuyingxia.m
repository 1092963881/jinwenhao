%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>初始化数据>>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
clc,clear,close all;
fs = 3000000;
Time_Hold_On1 = 0.0005;%每个码元的持续时间
Time_Hold_On = Time_Hold_On1*2;%两个码元的持续时间
Num_Unit = fs*Time_Hold_On;% fs * Time_Hold_On;%每两个码元的取样个数-3000

one_Level = zeros ( 1, Num_Unit );
two_Level = ones ( 1, Num_Unit );
three_Level = 2*ones ( 1, Num_Unit );
four_Level = 3*ones ( 1, Num_Unit );

A = 1;				                                % the default ampilitude is 1
w1 =30000;                                             %初始化载波频率
w2 =60000;
w3=90000;
w4=120000;
%>>>>>>>>>>>>>>>产生码元>>>>>>>>>>>>>>>>
num=10;%总共10个数
code=rand(1,num);
code(code>0.5)=1;
code(code<=0.5)=0;
Sign_Set=code;
% Sign_Set=[0,0,1,1,0,1,1,0,1,0,1,0,1,0,0,1]
Lenth_Of_Sign_Set = length ( Sign_Set );  %计算信号长度

%>>>>>>>>>>>>>>>画初始码元图>>>>>>>>>>>>>>>>>
t1 = 0 : 1/(2*fs) : Time_Hold_On1 * Lenth_Of_Sign_Set- 1/(2*fs);
orign=zeros ( 1, Num_Unit * Lenth_Of_Sign_Set);
for i = 1 : Lenth_Of_Sign_Set
    orign( (i-1)*Num_Unit + 1 : i*Num_Unit) = Sign_Set(i);
end
figure
plot(t1,orign);

%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>串并转换>>>>>>>>>>>>>>>
%---------------------------------------------------
j=1;
for I=1:2:Lenth_Of_Sign_Set                            %信号分离成两路信号
    Sign_Set1(j)= Sign_Set(I);Sign_Set2(j)=Sign_Set(I+1);%奇数位放在set1里，偶数位放在set2里
    j=j+1;
end

Lenth_Of_Sign = length ( Sign_Set1 );     %8位
st = zeros ( 1, Num_Unit * Lenth_Of_Sign/2 );
sign_orign = zeros ( 1, Num_Unit * Lenth_Of_Sign/2 );%
sign_result = zeros ( 1, Num_Unit * Lenth_Of_Sign/2 );
t = 0 : 1/fs : Time_Hold_On * Lenth_Of_Sign- 1/fs;


%---------------------------------------------------
%>>>>>>>>>>>产生基带信号>>>>>>>>>>>>
%---------------------------------------------------
for I = 1 : Lenth_Of_Sign
    if ((Sign_Set1(I) == 0)&(Sign_Set2(I) == 0))                        %00为1电平
        sign_orign( (I-1)*Num_Unit + 1 : I*Num_Unit) = one_Level;
    elseif ((Sign_Set1(I) == 0)&(Sign_Set2(I) == 1))                     %01为2电平
        sign_orign( (I-1)*Num_Unit + 1 : I*Num_Unit) = two_Level;
    elseif ((Sign_Set1(I) == 1)&(Sign_Set2(I) == 1))                     %11为3电平
        sign_orign( (I-1)*Num_Unit + 1 : I*Num_Unit) = three_Level;
    else                                                         %10为4电平
        sign_orign( (I-1)*Num_Unit + 1 : I*Num_Unit) = four_Level;
    end
end

%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>产生频带信号>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
for I = 1 : Lenth_Of_Sign
    if ((Sign_Set1(I) == 0)&(Sign_Set2(I) == 0))                     %00为载波w1
        st((I-1)*Num_Unit + 1 : I*Num_Unit) = A * cos ( 2 * pi * w1 * t( (I-1)*Num_Unit + 1 : I*Num_Unit ) );
    elseif ((Sign_Set1(I) == 0)&(Sign_Set2(I) == 1))                 %01为载波w2
        st( (I-1)*Num_Unit + 1 : I*Num_Unit) = A * cos ( 2 * pi * w2 * t((I-1)*Num_Unit + 1 : I*Num_Unit ) );
    elseif ((Sign_Set1(I) == 1)&(Sign_Set2(I) == 1))                   %11为载波w3
        st( (I-1)*Num_Unit + 1 : I*Num_Unit) = A * cos ( 2 * pi * w3 * t((I-1)*Num_Unit + 1 : I*Num_Unit ) );
    else                                                       %10为载波w4
        st( (I-1)*Num_Unit + 1 : I*Num_Unit) = A * cos ( 2 * pi * w4 * t( (I-1)*Num_Unit + 1 :I*Num_Unit ) );
    end
end

%---------------------------------------------------
%>>>>>>>>>>>>>>>画初始信号图>>>>>>>>>>>>>>>>>
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
%>>>>>>>>.给信号加入高斯白噪声》》》》》》》》
st = awgn(st,40);
figure
plot ( t, st );
%---------------------------------------------------
%>>>>>>>>>>>>>>>带通滤波器>>>>>>>>>>>>>>
%---------------------------------------------------
%- design the bandpass [ 250 250 ]
wp = [ 2*pi*25000 2*pi*35000 ];          %通带
ws = [ 2*pi*5000 2*pi*50000 ];            %阻带
[N,wn]=buttord(wp,ws,1,30,'s');
[b,a]=butter( N,wn,'bandpass','s');
[bz,az]=impinvar(b,a,fs);             %映射为数字的

dt1 = filter(bz,az,st);                     %带通取出频率w1
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
dt2 = filter(bz,az,st);                         %带通取出频率w2
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
dt3 = filter(bz,az,st);                 %带通取出频率w3
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
%>>>>>>>>>>>>>>>>>>>相干解调>>>>>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
dt1  = dt1 .* cos ( 2 * pi * w1 * t );           %解调载波1
dt2  = dt2 .* cos ( 2 * pi * w2 * t );           %解调载波2
dt3  = dt3 .* cos ( 2 * pi * w3 * t );           %解调载波3
dt4  = dt4 .* cos ( 2 * pi * w4 * t );           %解调载波4

s2=dt2;

[f,sf2]=T2F(t,s2);
figure(7777);
subplot(1,1,2);
plot(t,sf2,'r');
title('载波1调制后信号频谱');







figure
subplot( 2, 2, 1 )
plot(t,dt1);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '30000Hz分量相干解调后的波形' );
grid

subplot( 2, 2, 2 )
plot(t,dt2);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '60000Hz分量相干解调后的波形' );
grid;
subplot( 2, 2, 3 )
plot(t,dt3);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '90000Hz分量相干解调后的波形' );
grid
subplot( 2, 2, 4 )
plot(t,dt4);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '120000Hz分量相干解调后的波形' );
grid

%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>>低通滤波器>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
[N,Wn] = buttord( 2*pi*5000, 2*pi*15000,3,25,'s');      %临界频率采用角频率表示
[b,a]=butter(N,Wn,'s');
[bz,az]=impinvar(b,a,fs);                       %映射为数字的

dt1 = filter(bz,az,dt1);
dt2 = filter(bz,az,dt2);
dt3 = filter(bz,az,dt3);
dt4 = filter(bz,az,dt4);

figure
subplot( 2, 2, 1 )
plot(t,dt1);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '30000Hz分量低通滤波后的波形' );
grid

subplot( 2, 2, 2 )
plot(t,dt2);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '60000Hz分量低通滤波后的波形' );
grid;

subplot( 2, 2, 3 )
plot(t,dt3);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '90000Hz分量低通滤波后的波形' );
grid

subplot( 2, 2, 4 )
plot(t,dt4);
axis( [ 0 , Time_Hold_On *( Lenth_Of_Sign + 1), - (A / 2), A + (A / 2) ] );
title ( '120000Hz分量低通滤波后的波形' );
grid
%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>>抽样判决>>>>>>>>>>>>>>>>>>>>
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
title ( '解调出来的波形' );
grid
%---------------------------------------------------
%>>>>>>>>>>>>>>>>>>>并串转换>>>>>>>>>>>>>>>>>>>>
%---------------------------------------------------
signdemo=[];
for I=1:Lenth_Of_Sign
    signdemo=[signdemo,a(I),b(I)];
    
end
%>>>>>>>>>>>>>>>>>>>>>画解调码元图>>>>>>>>>>>>>>>>>>>>>
%>>>>>>>>>>>>>>>画初始码元图>>>>>>>>>>>>>>>>>
result=zeros ( 1, Num_Unit * Lenth_Of_Sign_Set);
for i = 1 : Lenth_Of_Sign_Set
    result( (i-1)*Num_Unit + 1 : i*Num_Unit) = signdemo(i);
end
figure
plot(t1,result);

% >>>>>>>>>>>>>>计算误码率模块>>>>>>>>>>>>>>>>
c=signdemo==Sign_Set; %误码矩阵
num_zero= sum(c(:)==0);
errorRate=num_zero/num;
