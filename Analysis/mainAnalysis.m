% dimensional conversions
g_2_lb = 453.592; % grams per lbf
cm_2_in = 2.54; % cm per inch
ftlbfpersec_2_W = .74; % ftlbf/s per Watt

% link constants
dens = 1.18 * (cm_2_in ^ 3) / g_2_lb;
t_L = .125; % link thickness, in
wid_L = 1; % link width, in

% motor constants
stallT = 10; % kg-cm
opAngVel = 60 * pi / (.2 * 180); % rad/sec

w_L = dens * t_L * wid_L * 2; % weight per link length, assumes support on both sides, lbf/in
w_m = 90 / g_2_lb; % weight per motor, lbf/motor
d_f = 2; % dynamic load factor
u_f = 1.15; % load uncertainty factor

% joint values, tuneable
q0 = 0;     % revolute, radians
q1 = 0;     % revolute, radians
q2 = 0;     % revolute, radians
q3 = 0;     % revolute, radians
q4 = 0;     % revolute, radians
q5 = 0;     % prismatic, inches

% link lengths, inches, tuneable
L0   = 2;
L1   = 2;
L2   = 2;
L3   = 2;
L4   = 2;
L5_y = .5; 
L5_z = 2;
L6   = 1;

% end effector pose in end effector Csys
P_ee = [0 ; 0 ; 0 ; 1];

% forward kinematics from base to end effector
P_b = T_b_ee(q0, q1, q2, q3, q4, q5, L0, L1, L2, L3, L4, L5_y, L5_z, L6) * P_ee;

% worst case motor holding torque

% joint limits
qRev_limLow = -pi/3; % radians
qRev_limUpp = pi/3; % radians
qPrs_limLow = 0; % inches
qPrs_limUpp = 1; % inches

% arm worst-case load calcs (lbf)
W_5_ee = ((L6 + qPrs_limUpp) * w_L + w_m) * d_f * u_f;
W_4_ee = W_5_ee + ((L5_y + L5_z) * w_L + w_m) * d_f * u_f;
W_3_ee = W_4_ee + (L4*w_L + w_m) * d_f * u_f;
W_2_ee = W_3_ee + (L3*w_L + w_m) * d_f * u_f;
W_1_ee = W_2_ee + (L2*w_L + w_m) * d_f * u_f; 
W_0_ee = W_1_ee + (L1*w_L + w_m) * d_f * u_f;
W_b_ee = W_0_ee + (L0*w_L + w_m) * d_f * u_f;

qRange = qRev_limLow:pi/240:qRev_limUpp;
torque = zeros(1, length(qRange));

% max torque load
ctr = 1;
for q = qRange
    P_b = T_b_ee(q0, q, q2, q3, q4, q5, L0, L1, L2, L3, L4, L5_y, L5_z, L6) * P_ee;
    moment_arm = sqrt(P_b(1)^2 + P_b(2)^2)/2; % inches
    torque(ctr) = moment_arm*W_1_ee; 
    ctr = ctr + 1;
end

figure(1);
plot(qRange, torque)
xlabel('Range of q_1 (radians)');
ylabel('Max dynamic motor torque load in pose (lbf-in)');
title('Max dynamic motor torque w.r.t. q_1 rotation');

% % joint iterator resolution
% qRev_stp = pi/2; % radians
% qPrs_stp = .5; % inches
% 
% i = 1;
% for q0_val = qRev_limLow:qRev_stp:qRev_limUpp % revolute
%     for q1_val = qRev_limLow:qRev_stp:qRev_limUpp % revolute
%         for q2_val = qRev_limLow:qRev_stp:qRev_limUpp % revolute
%             for q3_val = qRev_limLow:qRev_stp:qRev_limUpp % revolute
%                 for q4_val = qRev_limLow:qRev_stp:qRev_limUpp % revolute
%                     for q5_val = qRev_limLow:qRev_stp:qRev_limUpp % revolute
%                         for q6_val = qPrs_limLow:qPrs_stp:qPrs_limUpp % prismatic
%                             
%                             % compute transforms from link frame to EE frame
%                             b_T_ee = T_b_ee(q0_val, q1_val, q2_val, q3_val, q4_val, q5_val, L0, L1, L2, L3, L4, L5_y, L5_z, L6);
%                             T_0_ee = inv(T_b_0(q0_val,L0))*b_T_ee;
%                             T_1_ee = inv(T_b_1(q0_val,q1_val,L0,L1))*b_T_ee;
%                             T_2_ee = inv(T_b_2(q0_val,q1_val,q2_val,L0,L1,L2))*b_T_ee;
%                             T_3_ee = inv(T_b_3(q0_val,q1_val,q2_val,q3_val,L0,L1,L2,L3))*b_T_ee;
%                             T_4_ee = inv(T_b_4(q0_val,q1_val,q2_val,q3_val,q4_val,L0,L1,L2,L3,L4))*b_T_ee;
%                             mat_T_5_ee = T_5_ee(q5,L6);
%                             
%                             % take only rotation component
%                             baseVec_0_ee = [T_0_ee(1:4, 1:3) [0 ; 0 ; 0 ; 1]]*P_ee;
%                             baseVec_1_ee = [T_1_ee(1:4, 1:3) [0 ; 0 ; 0 ; 1]]*P_ee;
%                             baseVec_2_ee = [T_2_ee(1:4, 1:3) [0 ; 0 ; 0 ; 1]]*P_ee;
%                             baseVec_3_ee = [T_3_ee(1:4, 1:3) [0 ; 0 ; 0 ; 1]]*P_ee;
%                             baseVec_4_ee = [T_4_ee(1:4, 1:3) [0 ; 0 ; 0 ; 1]]*P_ee;
%                             baseVec_5_ee = [mat_T_5_ee(1:4, 1:3) [0 ; 0 ; 0 ; 1]]*P_ee;
%                             
%                             T_0_ee
%                             
%                             % moment arm (in), assumes that moment arm is half-length
%                             arm_0_ee = sqrt(baseVec_0_ee(1)^2 + baseVec_0_ee(2)^2) / 2;
%                             arm_1_ee = sqrt(baseVec_1_ee(1)^2 + baseVec_1_ee(2)^2) / 2;
%                             arm_2_ee = sqrt(baseVec_2_ee(1)^2 + baseVec_2_ee(2)^2) / 2;
%                             arm_3_ee = sqrt(baseVec_3_ee(1)^2 + baseVec_3_ee(2)^2) / 2;
%                             arm_4_ee = sqrt(baseVec_4_ee(1)^2 + baseVec_4_ee(2)^2) / 2;
%                             arm_5_ee = sqrt(baseVec_5_ee(1)^2 + baseVec_5_ee(2)^2) / 2;
%                             
%                             % holding torque (lbf-in) 
%                             T_0 = arm_0_ee * W_0_ee;
%                             T_1 = arm_1_ee * W_1_ee;
%                             T_2 = arm_2_ee * W_2_ee;
%                             T_3 = arm_3_ee * W_3_ee;
%                             T_4 = arm_4_ee * W_4_ee;
%                             T_5 = arm_5_ee * W_5_ee;
%                             
%                             % total power consumption (W)
%                             P(i) = (T_0 + T_1 + T_2 + T_3 + T_4 + T_5) * opAngVel / ftlbfpersec_2_W;
%                             i = i + 1;
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end

