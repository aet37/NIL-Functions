function [f,pdf_x]=exp_dist(uitems,tau,seed1)
% Usage ... f=exp_dist(uitems,tau,seed1)

if nargin<3, seed1=sum(100*clock); end;

rand('seed',seed1);
u=rand([uitems 1]);

% pdf_x is the velocity axis
pdf_x(:,1)=[0:1/(uitems-1):1]';
pdf_x(:,2)=exp(-pdf_x(:,1)/tau);
pdf_x(:,2)=pdf_x(:,2)/trapz(pdf_x(:,1),pdf_x(:,2));
%plot(pdf_x(:,1),pdf_x(:,2))

f=ran_dist(pdf_x,u);

