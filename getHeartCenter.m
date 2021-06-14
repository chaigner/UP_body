% function to get the heart position of each B1+ dataset 
%
% Created by Christoph S. Aigner, PTB, June 2021.
% Email: christoph.aigner@ptb.de

function [transpos, corpos, sagpos] = getHeartCenter(c_subj)

transpos=32;
corpos=53;
sagpos=46;

if c_subj==1 
transpos=36;
corpos=53;
sagpos=46;
end

if c_subj==2 
    transpos=32;
    corpos=56;
    sagpos=49;
end
if c_subj==3
    transpos=32;
    corpos=56;
    sagpos=45;
end
if c_subj==4
    transpos=32;
    corpos=56;
    sagpos=44;
end
if c_subj==5
    transpos=24;
    corpos=56;
    sagpos=41;
end
if c_subj==6
    transpos=32;
    corpos=53;
    sagpos=47;
end
if c_subj==7
    transpos=32;
    corpos=56;
    sagpos=42;
end
if c_subj==8
    transpos=28;
    corpos=53;
    sagpos=48;
end
if c_subj==10
    transpos=32;
    corpos=53;
    sagpos=42;
end
if c_subj==11
    transpos=32;
    corpos=53;
    sagpos=48;
end
if c_subj==12
    transpos=32;
    corpos=53;
    sagpos=48;
end
if c_subj==15
    transpos=32;
    corpos=56;
    sagpos=40;
end

if c_subj==16
    transpos=32;
    corpos=56;
    sagpos=41;
end
if c_subj==17
    transpos=32;
    corpos=56;
    sagpos=42;
end
if c_subj==19
    transpos=32;
    corpos=56;
    sagpos=40;
end
if c_subj==21
    transpos=32;
    corpos=56;
    sagpos=42;
end
if c_subj==22
    transpos=32;
    corpos=56;
    sagpos=48;
end

if c_subj==23
    transpos=32;
    corpos=56;
    sagpos=49;
end
if c_subj==24
    transpos=28;
    corpos=56;
    sagpos=46;
end
if c_subj==26
    transpos=32;
    corpos=56;
    sagpos=48;
end
if c_subj==27
    transpos=37;
    corpos=56;
    sagpos=43;
end
if c_subj==28
    transpos=37;
    corpos=56;
    sagpos=44;
end
if c_subj==29
    transpos=37;
    corpos=56;
    sagpos=43;
end
end