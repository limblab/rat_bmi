function [angles,outputLabelNames] = find_joint_angles(kinmat,labels)
 
% labels = kindat.KinMatrixLabels;
% kinmat = kindat.rawKinMatrix;
 
% ankle angle to start with
KNEE = kinmat(:,find(strncmp(labels,'knee',4)));
HEEL = kinmat(:,find(strncmp(labels,'heel',4)));
FOOT = kinmat(:,find(strncmp(labels,'foot',4)));
TOE = kinmat(:,find(strncmp(labels,'toe',3)));
HIPMID = kinmat(:,find(strncmp(labels,'hip_mid',7)));
HIPTOP = kinmat(:,find(strncmp(labels,'hip_top',7)));
% outputLabelNames = ['Ankle     ';'Limb-foot ';'Hip       ';'Knee      ';'Toe-height'];
outputLabelNames = {'Ankle     ','Limb-foot ','Limb-toe  ','Limb-heel ','Hip       ','Knee      ','Toe-height'};
if isempty(HIPMID)
    HIPMID = kinmat(:,find(strncmp(labels,'hip_cent',8)));
end
 
v1 = KNEE-HEEL;
v2 = FOOT-HEEL;
angles.ankle = find_angle(v1(:,1:2),v2(:,1:2))';
idx = (angles.ankle < 0);
temp = idx.*(angles.ankle + 180) + ~idx.*angles.ankle;
angles.ankle = temp;

v1 = HIPTOP-HIPMID;  
v2 = FOOT-HIPMID;
angles.limbfoot = find_angle(v1(:,1:2),v2(:,1:2))';
idx = (angles.limbfoot < 0);
temp = idx.*(angles.limbfoot + 180) + ~idx.*angles.limbfoot;
angles.limbfoot = temp;

 
% if ~isempty(TOE)
%     v1 = HIPTOP-HIPMID;
%     v2 = TOE-HIPMID;
%     angles.limbtoe = find_angle(v1(:,1:2),v2(:,1:2))';
% end
%  
% v1 = HIPTOP-HIPMID;  
% v2 = HEEL-HIPMID;
% angles.limbheel = find_angle(v1(:,1:2),v2(:,1:2))';
 
v1 = HIPTOP-HIPMID;  
v2 = KNEE-HIPMID;
angles.hip = find_angle(v1(:,1:2),v2(:,1:2))';
idx = (angles.hip < 0);
temp = idx.*(angles.hip + 180) + ~idx.*angles.hip;
angles.hip = temp;


v1 = HIPMID-KNEE;
v2 = HEEL-KNEE;
angles.knee = find_angle(v1(:,1:2),v2(:,1:2))';
idx = (angles.knee < 0);
temp = idx.*(angles.knee + 180) + ~idx.*angles.knee;
angles.knee = temp;
 
 
angles.toeheight = TOE(:,2);

 
    
% h = atan2(norm(cross(N-H,S-H)),dot(N-H,S-H));
% n = atan2(norm(cross(S-N,H-N)),dot(S-N,H-N));
% s = atan2(norm(cross(H-S,N-S)),dot(H-S,N-S));
