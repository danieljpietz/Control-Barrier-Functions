classdef Vehicle
    properties
        
        LeadCar
        Lane
        p
        v
        z
        F
        
        v0
        vd 
        Fr
        Th
        
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
            obj.Th = 1;
            obj.p = X0(1);
            obj.v = X0(2);
            obj.vd = 10;
            obj.Lane = lane;
        end
        
        function x = isnan(obj)
            x = false;
        end
        
        function obj = tick(obj, h)
            if ~isnan(obj.LeadCar)
                obj.z = obj.LeadCar.p - obj.p;
                obj.v0 = obj.LeadCar.v;
            else
                obj.z = inf;
                obj.v0 = inf;
            end
            
            
            X = [obj.p; obj.v; obj.z];
            obj.F = VehiclectrlCbfClfQp(obj, X, 0);
            obj.v = obj.v + obj.F*h - obj.Fr*obj.v;
            obj.p = obj.p + obj.v*h;
            
        end
        
        function outputArg = method1(obj,inputArg)
            outputArg = obj.Property1 + inputArg;
        end
    end
end

