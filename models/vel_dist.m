function [f,pdf_x]=vel_dist(uitems,pdfitems,tvratio,tau1,vmean,vspread,type,seed1)
% Usage ... f=vel_dist(uitems,pdfitems,tvratio,tau1,vmean,vspread,type,seed)

% Type definitions: [tisue vascular]
% 1- Fast Exponential, 1- Plugged flow (Gaussian)
% 2- Laminar flow (Linear)

if nargin<7, type=11; end;
if nargin<8, seed1=sum(clock); end;
rand('seed',seed1);

u=rand([uitems 1]);

% pdf_x is the velocity axis
pdf_x(:,1)=[0:1/(pdfitems-1):1]';

% pdf definition goes here (usually split into tissue pdf and vascular pdf...
% there are two possibilities which can be tested for the vascular pdf:
%  laminar and plugged flow...
% Laminar flow is relatively easy to describe #spins=2*pi*velocity;
% Plugged flow is modeled Gaussian for lack of a better method
% Tissue pdf is model as fast exponential decay for lack of a better method

if type(1)==2,
  % No other ideas here!
else,
  pdf_t=exp(-pdf_x(:,1)/tau1);
end;

if type(2)==2,
  pdf_v=2*pi*(1-pdf_x(:,1));
else,
  pdf_v=exp(-((pdf_x(:,1)-vmean)/vspread).^2);
end;

area_t=trapz(pdf_x(:,1),pdf_t);
area_v=trapz(pdf_x(:,1),pdf_v);
pdf_t=(tvratio/area_t)*(area_t+area_v)*pdf_t;
pdf_v=((1-tvratio)/(area_v))*(area_t+area_v)*pdf_v;
pdf_x(:,2)=pdf_t+pdf_v;
pdf_x(:,2)=pdf_x(:,2)/trapz(pdf_x(:,1),pdf_x(:,2));

f=ran_dist(pdf_x,u);

