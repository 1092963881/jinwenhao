clear all;
clc;
T=0.0005;
t=-0.01:T:0.01;
fs=2000;
sdt=1/fs;
t1=-0.01:sdt:0.01;
xt=cos(2*pi*30*t)+sin(2*pi*120*t);
st=cos(2*pi*30*t1)+sin(2*pi*120*t1);
max = max(abs(st));

% 原始信号
figure(1);
subplot(2,1,1);
plot(t,xt);
title('原始信号');
xlabel('t(s)');
grid on;

subplot(2,1,2);
stem(t1,st,'.');
title('抽样信号');
grid on;

% PCM 编码
pcm_encode = PCMcoding(xt);

figure(2);
stairs(pcm_encode);
axis([0 20 -0.1 1.1]);
title('PCM 编码');
xlabel('t(s)');
grid on;

% PCM 译码
pcm_decode = PCMdecoding(pcm_encode, max);
figure(3);
subplot(2,1,1);
plot(t, pcm_decode);
title('PCM 译码');
xlabel('t(s)');
grid on;

subplot(2,1,2);
plot(t,xt);
title('原始信号');
xlabel('t(s)');

% 计算失真度
da=0; 
for i=1:length(t)
    dc=(st(i)-pcm_decode(i))^2/length(t);
    da=da+dc;
end
fprintf('失真度是：%.6f\n',da);

figure(4);
stairs(pcm_encode);
axis([0 20 -0.1 1.1]);
title('PCM 编码');
xlabel('t(s)');
grid on;

figure
stairs(-pcm_encode);
axis([0 20 -1 0.1]);
title('取反后的');
xlabel('t(s)');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

st1=pcm_encode;
st2=-pcm_encode;

%载波信号
s1=cos(2*pi*30*t1);
s2=cos(2*pi*30*t1);
subplot(413),plot(s1);
title('载波信号s1');
subplot(414),plot(s2);
title('载波信号s2');
 
%调制
F1=st1.*s1;%加入载波1
F2=st2.*s2;%加入载波2
figure(2);
subplot(411);
plot(t,F1);
title('F1=s1*st1');
subplot(412);
plot(t,F2);
title('F2=s2*st2');
e_fsk=F1+F2;
subplot(413);
plot(t,e_fsk);
title('2FSK信号');%键控法产生的信号在相邻码元之间相位不一定连续
 
%加噪
nosie=rand(1,j);
fsk=e_fsk+nosie;
subplot(414);
plot(t,fsk);
title('加噪声后信号')
 
%相干解调
st1=fsk.*s1; %与载波1相乘
[f,sf1] = T2F(t,st1);%傅里叶变换
[t,st1] = lpf(f,sf1,2*fm);%通过低通滤波器
figure(3);
subplot(311);
plot(t,st1);
title('加噪后的信号与s1相乘后波形');
st2=fsk.*s2;%与载波2相乘
[f,sf2] = T2F(t,st2);%通过低通滤波器
[t,st2] = lpf(f,sf2,2*fm);
subplot(312);
plot(t,st2);
title('加噪后的信号与s2相乘后波形');
 
%抽样判决
for m=0:i-1
    if st1(1,m*500+250)>st2(1,m*500+250)
        for j=m*500+1:(m+1)*500
            at(1,j)=1;
        end
    else
        for j=m*500+1:(m+1)*500
            at(1,j)=0;
        end
    end
end
subplot(313);
plot(t,at);
axis([0,5,-1,2]);
title('抽样判决后波形')
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



figure;
s0=0; s1=5;
P0=0.5; % 信源发0的概率
P1=1-P0;

A2_over_sigma2_dB=-5:0.5:20; % 仿真信噪比范围（dB）
A2_over_sigma2=10.^(A2_over_sigma2_dB./10);
sigma2=s1^2./A2_over_sigma2; % 噪声方差范围
N=1e5; % 信源序列长度
for k=1:length(sigma2)
 %两路噪声
n1=sqrt(sigma2(k)).*randn(1,N); 
n2=sqrt(sigma2(k)).*randn(1,N); 
y1=s1+n1; % 接收机两路：在输入为1的情况下
y2=n2;
Y=(y1>y2); % 判决输出
%判决为0则表示错误
err(k)=(sum(Y<1))./N; % 误码率统计
end

semilogy(A2_over_sigma2_dB,err,'o');hold on; % 仿真结果

for k=1:length(sigma2) % 理论计算
r=s1^2/(sigma2(k)*2);
Pe1=0.5-0.5*erf((sqrt(0.5*r))); % 发1出错率
Pe0=0.5-0.5*erf((sqrt(0.5*r))); % 发0出错率

Pe(k)=Pe1; % 平均错误率,等概率时等于Pe1的错误率
end

semilogy(A2_over_sigma2_dB,Pe); % 理论曲线
xlabel('A^2/\sigma^2 (dB)');
ylabel('错误率P_e');
legend('仿真结果','理论曲线');




