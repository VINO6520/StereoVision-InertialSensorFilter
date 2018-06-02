clearvars -except s
clc,close all
if isempty(instrfind)~=1
	fclose(instrfind)% �ر�����ռ�õĴ���
end

global gyrobuff gyrostatic count

baudrate = 9600;
portnames = seriallist;
for i = 1:length(portnames)
	if portnames(i) ~= "COM1"
		portname = portnames(i);
		break
	end
end
% ��������OBJ
sport=serial(portname,'BaudRate',baudrate);
% s.status %����״̬
fopen(sport)%�򿪴���
% fwrite(s,255)%���ͣ��ò���
cmd = [];

% ����200��
% for i = 1:1
dt = 0.03;
data = [];
count = 0;
gyrobuff = [];
gyrostatic = [];
beta = 0.95;
acc_before = 0;
gyro_before = 0;
xg_before = 0;
yg_before = 0;
figure(1)
axis([0 50 -10 10])
acc_plotbuff =[];
gyro_plotbuff = [];
x_est_plotbuff = [];
y_est_plotbuff = [];


while(1)
	cmd = [];
	while(1)
		ch = fread(sport,1,'uchar');% ����֡ͷ1�ֽ�
		if ch == 36%'$'
			cmd = [cmd;ch];
			ch = fread(sport,29,'uchar');% ����18���ֽڣ���У��
			if ch(1) == 85&&ch(2) == 170% ����У�鴦��
				cmd = [cmd;ch];
				break;
			end
		else
			cmd = [];
		end
	end
	%����֡
	data = framedec(cmd);
	[acc_now,gyro_now]=data_process1(data);
	% ���ٶ�һ�׹����˲�
	acc_now = acc_before*(1-beta)+beta*acc_now;
	gyro_now = gyro_before*(1-beta)+beta*gyro_now;
	acc_now = acc_now./sqrt(acc_now'*acc_now);
	if size(acc_plotbuff,2)<50
		acc_plotbuff = [acc_plotbuff,acc_now];
		gyro_plotbuff = [gyro_plotbuff,gyro_now];
	else
		acc_plotbuff = acc_plotbuff(:,2:end);
		gyro_plotbuff = gyro_plotbuff(:,2:end);
		acc_plotbuff = [acc_plotbuff,acc_now];
		gyro_plotbuff = [gyro_plotbuff,gyro_now];
	end
	figure(1)
	subplot(2,2,1)
	ylim([-1 10])
	axis([0 size(acc_plotbuff,2) -10 10])
	axis manual
	plot(1:size(acc_plotbuff,2),acc_plotbuff(1,:),'r',...
		1:size(acc_plotbuff,2),acc_plotbuff(2,:),'g',...
		1:size(acc_plotbuff,2),acc_plotbuff(3,:),'b');
	subplot(2,2,2)
	ylim([-5 5])
	axis([0 size(gyro_plotbuff,2) -5 5])
	axis manual
	plot(1:size(gyro_plotbuff,2),gyro_plotbuff(1,:),'r',...
		1:size(gyro_plotbuff,2),gyro_plotbuff(2,:),'g',...
		1:size(gyro_plotbuff,2),gyro_plotbuff(3,:),'b');
	
	% �����˲�
	[x_est,y_est] = hubulvbo(acc_now,gyro_now);
	if size(acc_plotbuff,2)<50
		x_est_plotbuff = [x_est_plotbuff,x_est];
		y_est_plotbuff = [y_est_plotbuff,y_est];
	else
		x_est_plotbuff = x_est_plotbuff(:,2:end);
		y_est_plotbuff = y_est_plotbuff(:,2:end);
		x_est_plotbuff = [x_est_plotbuff,x_est];
		y_est_plotbuff = [y_est_plotbuff,y_est];
	end
	subplot(2,2,3)
	axis manual
	plot(1:length(x_est_plotbuff),x_est_plotbuff/pi*180,'r',...
		1:length(x_est_plotbuff),y_est_plotbuff/pi*180,'b');
	dcm = angle2dcm( x_est, y_est, 0 );
	% �������˲���
	
	
	drawnow limitrate

	acc_before = acc_now;
	gyro_before = gyro_now;
end
%% CLOSE
fclose(sport);%�رմ���
fclose(instrfind);

function [x_est,y_est] = hubulvbo(acc_now,gyro_now)
global count
xa = atan(acc_now(2)./acc_now(3));
ya = -asin(acc_now(1));
if count == 1
	x_est = xa(1);
	y_est = ya(1);
	dw = zeros(3,1);
else
	dw = Omega(gyro_now(1),gyro_now(2))*gyro_now;
end

alpha = 0.8 ;

x_est = (x_est + dw(1)*dt).*alpha+(1-alpha).*xa;
y_est = (y_est + dw(2)*dt).*alpha+(1-alpha).*ya;
end

function [acc_now,gyro_now] = data_process1(data)
global gyrobuff gyrostatic count
acc = [data.accx;data.accy;data.accz];
gyro = [data.gyrox;data.gyroy;data.gyroz];
acc = floor(acc/4)*4;
acc_now = floor(acc/4)*4;
acc_now = acc_now/(2^16-1)*16*9.8;
% AD����
acc_now = acc_now*2;
if size(gyrobuff,2)<4
	gyrobuff = [gyrobuff,gyro];
else
	gyrobuff = gyrobuff(:,2:end);
	gyrobuff = [gyrobuff,gyro];
end
gyro_now = mean(gyrobuff,2);
if count<200
	gyrostatic = [gyrostatic,gyro_now];
	count = count + 1;
end
gyro_now = gyro_now - mean(gyrostatic,2);
gyro_now = gyro_now/(2^16-1)*2000*pi/180;
% AD����
gyro_now = gyro_now*2;
end



function [outputs] = ushort2short(a)
if a>2^15
	b = -(bitxor(a,hex2dec('ffff'))+1);
	outputs = b;
else
	outputs = a;
end

end
function [outputs] = uint2int(a)

if a>2^31
	b = -(bitxor(a,hex2dec('ffffffff'))+1);
	outputs = b;
else
	outputs = a;
end

end
function out = framedec(indata)
sp = 1;
off = 3;% ���ݶ���ʼƫ����
out.accx = uint2int(indata(sp+off+3)*(2^24)+indata(sp+off+2)*(2^16)+indata(sp+off+1)*256+indata(sp+off));off = off + 4;
out.accy = uint2int(indata(sp+off+3)*(2^24)+indata(sp+off+2)*(2^16)+indata(sp+off+1)*256+indata(sp+off));off = off + 4;
out.accz = uint2int(indata(sp+off+3)*(2^24)+indata(sp+off+2)*(2^16)+indata(sp+off+1)*256+indata(sp+off));off = off + 4;
out.gyrox = uint2int(indata(sp+off+3)*(2^24)+indata(sp+off+2)*(2^16)+indata(sp+off+1)*256+indata(sp+off));off = off + 4;
out.gyroy = uint2int(indata(sp+off+3)*(2^24)+indata(sp+off+2)*(2^16)+indata(sp+off+1)*256+indata(sp+off));off = off + 4;
out.gyroz = uint2int(indata(sp+off+3)*(2^24)+indata(sp+off+2)*(2^16)+indata(sp+off+1)*256+indata(sp+off));off = off + 4;
end
function out = Omega(x,y)
% out = [1 tan(y)*sin(x) tan(y)*cos(x);
% 	0 cos(x) -sin(x);
% 	0 sin(x)/cos(y) cos(x)/cos(y)];
out = [1 tan(y)*sin(x) tan(y)*cos(x);
	0 cos(x) -sin(x);
	0 sin(x)/cos(y) cos(x)];
end