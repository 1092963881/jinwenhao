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

% ԭʼ�ź�
figure(1);
subplot(2,1,1);
plot(t,xt);
title('ԭʼ�ź�');
xlabel('t(s)');
grid on;

subplot(2,1,2);
stem(t1,st,'.');
title('�����ź�');
grid on;

% PCM ����
pcm_encode = PCMcoding(xt);

figure(2);
stairs(pcm_encode);
axis([0 20 -0.1 1.1]);
title('PCM ����');
xlabel('t(s)');
grid on;

% PCM ����
pcm_decode = PCMdecoding(pcm_encode, max);
figure(3);
subplot(2,1,1);
plot(t, pcm_decode);
title('PCM ����');
xlabel('t(s)');
grid on;

subplot(2,1,2);
plot(t,xt);
title('ԭʼ�ź�');
xlabel('t(s)');

% ����ʧ���
da=0; 
for i=1:length(t)
    dc=(st(i)-pcm_decode(i))^2/length(t);
    da=da+dc;
end
fprintf('ʧ����ǣ�%.6f\n',da);

figure(4);
stairs(pcm_encode);
axis([0 20 -0.1 1.1]);
title('PCM ����');
xlabel('t(s)');
grid on;

figure
stairs(-pcm_encode);
axis([0 20 -1 0.1]);
title('ȡ�����');
xlabel('t(s)');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

st1=pcm_encode;
st2=-pcm_encode;

%�ز��ź�
s1=cos(2*pi*30*t1);
s2=cos(2*pi*30*t1);
subplot(413),plot(s1);
title('�ز��ź�s1');
subplot(414),plot(s2);
title('�ز��ź�s2');
 
%����
F1=st1.*s1;%�����ز�1
F2=st2.*s2;%�����ز�2
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
title('2FSK�ź�');%���ط��������ź���������Ԫ֮����λ��һ������
 
%����
nosie=rand(1,j);
fsk=e_fsk+nosie;
subplot(414);
plot(t,fsk);
title('���������ź�')
 
%��ɽ��
st1=fsk.*s1; %���ز�1���
[f,sf1] = T2F(t,st1);%����Ҷ�任
[t,st1] = lpf(f,sf1,2*fm);%ͨ����ͨ�˲���
figure(3);
subplot(311);
plot(t,st1);
title('�������ź���s1��˺���');
st2=fsk.*s2;%���ز�2���
[f,sf2] = T2F(t,st2);%ͨ����ͨ�˲���
[t,st2] = lpf(f,sf2,2*fm);
subplot(312);
plot(t,st2);
title('�������ź���s2��˺���');
 
%�����о�
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
title('�����о�����')
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



figure;
s0=0; s1=5;
P0=0.5; % ��Դ��0�ĸ���
P1=1-P0;

A2_over_sigma2_dB=-5:0.5:20; % ��������ȷ�Χ��dB��
A2_over_sigma2=10.^(A2_over_sigma2_dB./10);
sigma2=s1^2./A2_over_sigma2; % �������Χ
N=1e5; % ��Դ���г���
for k=1:length(sigma2)
 %��·����
n1=sqrt(sigma2(k)).*randn(1,N); 
n2=sqrt(sigma2(k)).*randn(1,N); 
y1=s1+n1; % ���ջ���·��������Ϊ1�������
y2=n2;
Y=(y1>y2); % �о����
%�о�Ϊ0���ʾ����
err(k)=(sum(Y<1))./N; % ������ͳ��
end

semilogy(A2_over_sigma2_dB,err,'o');hold on; % ������

for k=1:length(sigma2) % ���ۼ���
r=s1^2/(sigma2(k)*2);
Pe1=0.5-0.5*erf((sqrt(0.5*r))); % ��1������
Pe0=0.5-0.5*erf((sqrt(0.5*r))); % ��0������

Pe(k)=Pe1; % ƽ��������,�ȸ���ʱ����Pe1�Ĵ�����
end

semilogy(A2_over_sigma2_dB,Pe); % ��������
xlabel('A^2/\sigma^2 (dB)');
ylabel('������P_e');
legend('������','��������');




