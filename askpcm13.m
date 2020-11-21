clear all;
clc;
A=3.5;
f=2000;
w=2*pi*f;
fs=8*10^3;
T=1/fs;
t=0:0.00000001:0.004;
y=A*sin(w*t);% �����ź�

figure(4);
plot(t,y);
legend('ԭʼ�����ź�');

n=1:100;% �����ĸ���
fs=8*10^3;T=1/fs; 
Y(n)=1; 
figure(5) 
stem(n,Y(n)); 
axis([0 50 0 1]); 
xlabel('n'); 
ylabel(' ���� '); 
legend(' ���������ź� '); 
n=1:100; 
fs=8*10^3;T=1/fs; 
s=A*sin(w*n*T); 
figure(1) 
stem(n,s);% ʱ���������ź�ͼ
axis([0 100 -4 4]); 
xlabel('n'); 
ylabel(' ���� '); 
legend(' ʱ������ź�ͼ '); 
f=n./(100*T); 
y1=abs(fft(s)); 
figure(2) 
plot(f,y1); 
xlabel('f'); 
ylabel(' ��Ƶ '); 
legend(' �����ź�Ƶ�� '); 
s1=s./max(s);% ��һ��
s2=s1./(1/2048); 
for i=1:100 %c �� pcm��100*8 
 y=s2(i); 
 u=[0 0 0 0 0 0 0 0 ]; 
 if(y>0)% ��ֵ���ж�
 u(1)=1; 
else 
 u(1)=0; 
end 
y=abs(y); 
if(y>=0&&y<16)% �������ж�
 u(2)=0;
 u(3)=0;
 u(4)=0;
 step=1;
 st=0; 
elseif(y>=16&&y<32)
u(2)=0;
u(3)=0;
u(4)=1;
step=1;
st=16; 
elseif(y>=32&&y<64) 
 u(2)=0;
 u(3)=1;
 u(4)=0;
 step=2;
 st=32; 
elseif(y>=64&&y<128) 
 u(2)=0;
 u(3)=1;
 u(4)=1;
 step=4;
 st=64; 
elseif(y>=128&&y<256) 
 u(2)=1;
 u(3)=0;
 u(4)=0;
 step=8;
 st=128; 
elseif(y>=256&&y<512) 
 u(2)=1;
 u(3)=0;
 u(4)=1;
 step=16;
 st=256; 
elseif(y>=512&&y<1024) 
 u(2)=1;
 u(3)=1;
 u(4)=0;
 step=32;
 st=512; 
elseif(y>=1024&&y<=2048) 
 u(2)=1;u(3)=1;
 u(4)=1;
 step=64;
 st=1024; 
end 
if(y<2048)% �������ж�
 t=floor((y-st)/step); 
 p=dec2bin(t,4)-48; 
 u(5:8)=p(1:4); 
else 
 u(5:8)=[1 1 1 1]; 
end 
c(i,1:8)=u(1:8); 
end

m=c;%����
 m1=m.';
 m1=reshape(m1,2,400);
 m1=m1.'; 
 m2=bi2de(m1,'left-msb'); 
 m2(m2==0)=-1;
 m2(m2==2)=-3; 

c1=c.';
c7=c; 
c1=reshape(c1,4,200);
c1=c1.';%c1=200*4, ǰ���ж�Ӧ c��һ��
c2=encode(c1,7 ,4,'hamming/binary');%(7,4)hamming �ŵ����� 200*7 
c3=encode(c7,15,8,'cyclic/binary');%(15,8) ѭ�������
tx1=c2;
tx1(tx1==0)=-1;
tx2=c3;
tx2(tx2==0)=-1;% ����
errorbit=0; 
 dB=-25:5:25; 
 
 for q=1:11 
 
 biterrors=0;
 biterrors1=0;
 biterrors2=0; 
 
 r1=10.^(dB(q)/10); 
 r1=0.5./(r1); 
 sigma=sqrt(r1);% ��׼��
 qq2=m2+sigma*randn(400,1);% ������
 qq2((qq2>=0)&(qq2<2))=1;% �о������
 qq2(qq2>=2)=3; 
 qq2((qq2>=-2)&(qq2<0))=-1; 
 qq2(qq2<-2)=-3;
 qq2(qq2==-3)=2; 
 qq2(qq2==-1)=0; 
 m3=de2bi(qq2,2,'left-msb');
 m3=m3.'; 
 m3=reshape(m3,8,100);
 m3=m3.';% ��m3��� 8��100�еľ���
 errors=zeros(100,8);
 errors(m3~=c)=1;% ���ִ����� error Ϊ1 
 errors=reshape(errors,1,800);% �Ѿ����� 1��800�еľ���
 biterrors=sum(errors); 
 bit1(q)=biterrors/(100*8); 
 rx1=tx1+sigma*randn(200,7);% ������
 rx2=tx2+sigma*randn(100,15);% ������
 rx1(rx1>=0)=1;rx1(rx1<0)=0;% �о������
 rx2(rx2>=0)=1;rx2(rx2<0)=0; 
 c22=decode(rx1,7,4,'hamming/binary');%hamming �ŵ����� 200*4 
 c33=decode(rx2,15,8,'cyclic/binary');% ѭ������
 errors1=zeros(200,4); 
 errors2=zeros(100,8); 
 errors1(c22~=c1)=1;% ���ִ�������ֵΪ 1 
 errors2(c33~=c7)=1;% ���ִ�������ֵΪ 1 
 errors1=reshape(errors1,1,800); % �Ѿ����� 1��800�еľ���
 errors2=reshape(errors2,1,800);% �Ѿ����� 1��800�еľ���
 biterrors1=sum(errors1);% ͳ�ƴ���
 biterrors2=sum(errors2);% ͳ�ƴ���
 errorbit(q)=biterrors1/(100*8); 
 errorbit2(q)=biterrors2/(100*8);% ������
 end 
figure(3) 
semilogy(dB,errorbit,':ro'); 
hold 
semilogy(dB,bit1,'--bs'); 
semilogy(dB,errorbit2,'-.g*'); 
grid; 
legend(':ro ���� ','--bs ���ŵ����� ','-.g* ѭ���� '); 
xlabel('dB'); 
ylabel(' ������ ')