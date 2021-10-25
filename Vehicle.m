classdef Vehicle
    properties
        
        LeadCar
        LeadCarLeft
        LeadCarRight
        Lane
        SelfLaneChange
        z
        p
        v
        v0
        
        zStraight
        v0Straight
        
        zLeft
        v0Left
        
        zRight
        v0Right
        
        F
        id
        vd
        Fr
        Th
        
        LaneChangeThreshold
        
    end
    
    methods
        
        function v = V(obj, x)
            v = (x(2,:) - obj.vd)^2;
        end
        
        function v = LfV(obj, x)
            v = -2*(x(2) - obj.vd)*obj.Fr*x(2);
        end
        
        function v = LgV(obj, x)
            v = 2*(x(2) - obj.vd);
        end
        
        function v = B(obj, x)
            v = x(3) - obj.Th*x(2);
        end
        
        function v = LfB(obj, x)
            v = obj.Fr*obj.Th*x(2) + obj.v0 - x(2);
        end
        
        function v = LgB(obj, x)
            v = - obj.Th;
        end
        
        function obj = Vehicle(X0, lane)
            obj.Fr = 0.0;
            obj.Th = 5;
            obj.p = X0(1);
            obj.v = X0(2);
            obj.vd = 10;
            obj.Lane = lane;
            obj.SelfLaneChange = true;
            obj.LaneChangeThreshold = 25;
        end
        
        function x = isnan(obj)
            x = false;
        end
        
        function obj = tick(obj, h)
            if ~isnan(obj.LeadCar)
                obj.zStraight = obj.LeadCar.p - obj.p;
                obj.v0Straight = obj.LeadCar.v;
            else
                obj.zStraight = inf;
                obj.v0Straight = inf;
            end
            
            if ~isnan(obj.LeadCarLeft)
                obj.zLeft = obj.LeadCarLeft.p - obj.p;
                obj.v0Left = obj.LeadCarLeft.v;
            else
                obj.zLeft = inf;
                obj.v0Left = inf;
            end
            
            if ~isnan(obj.LeadCarRight)
                obj.zRight = obj.LeadCarRight.p - obj.p;
                obj.v0Right = obj.LeadCarRight.v;
            else
                obj.zRight = inf;
                obj.v0Right = inf;
            end
            
            if obj.SelfLaneChange == false
                obj.v0 = obj.v0Straight;
                obj.z = obj.zStraight;
                X = [obj.p; obj.v; obj.z];
                obj.F = VehiclectrlCbfClfQp(obj, X, 0);
                obj.v = obj.v + obj.F*h - obj.Fr*obj.v;
                obj.p = obj.p + obj.v*h;
            else
                obj.v0 = obj.v0Straight;
                obj.z = obj.zStraight;
                X = [obj.p; obj.v; obj.z];
                FStraight = VehiclectrlCbfClfQp(obj, X, 0);
                
                obj.v0 = obj.v0Left;
                obj.z = obj.zLeft;
                X = [obj.p; obj.v; obj.z];
                FLeft = VehiclectrlCbfClfQp(obj, X, 0);
                
                obj.v0 = obj.v0Right;
                obj.z = obj.zRight;
                X = [obj.p; obj.v; obj.z];
                FRight = VehiclectrlCbfClfQp(obj, X, 0);
                Forces = [FStraight, FLeft, FRight];
                
                minPosForce = min(Forces(Forces >= 0));
                maxNegForce = max(Forces(Forces < 0));
                
                if obj.zStraight > obj.LaneChangeThreshold
                    obj.F = FStraight;
                else
                    if ~isempty(minPosForce)
                        obj.F = minPosForce;
                    else
                        obj.F = maxNegForce;
                    end
                end
                
                obj.v = obj.v + obj.F*h - obj.Fr*obj.v;
                obj.p = obj.p + obj.v*h;
                
                if obj.F == FStraight
                elseif obj.F == FLeft
                    obj.Lane = obj.Lane - 1;
                elseif obj.F == FRight
                    obj.Lane = obj.Lane + 1;
                end
                
            end
        end
    end
end

