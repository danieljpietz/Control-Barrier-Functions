function [LpQ] = Lie(P,Q)
    LpQ = sum(gradient(Q).*P);
end

