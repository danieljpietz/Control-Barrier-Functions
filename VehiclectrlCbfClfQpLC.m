%% Author: Jason Choi (jason.choi@berkeley.edu)
function [u, slack, B, V, feas, comp_time] = VehiclectrlCbfClfQpLC(obj, x, u_ref)

clf_rate = 10;
cbf_rate = 10;
slack = 2e-4;

tstart = tic;
V = obj.V(x);
LfV = obj.LfV(x);
LgV = obj.LgV(x);

B = obj.B(x);
LfB = obj.LfB(x);
LgB = obj.LgB(x);


udim = length(u_ref);
with_slack = true;
%% Constraints: A[u; slack] <= b
if with_slack
    % CLF and CBF constraints.
    A = [LgV, -1;
        -LgB, 0];
    b = [-LfV - clf_rate * V;
        LfB + cbf_rate * B];
else
    % CLF and CBF constraints.
    A = [LgV; -LgB];
    b = [-LfV - clf_rate * V;
        LfB + cbf_rate * B];
end

weight_input = eye(udim);
if with_slack
    % cost = 0.5 [u' slack] H [u; slack] + f [u; slack]
    H = [weight_input, zeros(udim, 1);
        zeros(1, udim), slack];
    f_ = [-weight_input * u_ref; 0];
    [u_slack, ~, exitflag, ~] = quadprog(H, f_, A, b, [], [], [], [], [], optimset('Display','off'));
    if exitflag == -2
        feas = 0;
        disp("Infeasible QP. CBF constraint is conflicting with input constraints.");
    else
        feas = 1;
    end
    u = u_slack(1:udim);
    slack = u_slack(end);
else
    % cost = 0.5 u' H u + f u
    H = weight_input;
    f_ = -weight_input * u_ref;
    [u, ~, exitflag, ~] = quadprog(H, f_, A, b, [], [], [], [], [], optimset('Display','off'));
    if exitflag == -2
        feas = 0;
        disp("Infeasible QP. CBF constraint is conflicting with input constraints.");
    else
        feas = 1;
    end
    slack = [];
end
comp_time = toc(tstart);
end