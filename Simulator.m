classdef Simulator
    
    properties
        Vehicles
        Lane
    end
    
    methods
        function obj = Simulator(vehicles)
            obj.Vehicles = vehicles;
            obj.Lane = cell(length(obj.Vehicles), 3);
            for i = 1:length(obj.Vehicles)
                vehicle = obj.Vehicles{i};
                obj.Lane(i,:) = {vehicle, vehicle.p, i};
            end
        end
        
        function obj = tick(obj, h)
            obj.Lane = sortrows(obj.Lane, 2, 'descend');
            obj.Lane{1,1}.LeadCar = nan;
            obj.Lane{1,1} = obj.Lane{1,1}.tick(h);
            for i = 2:length(obj.Vehicles)
                obj.Lane{i,1}.LeadCar = obj.Lane{i-1,1};
                obj.Lane{i,1} = obj.Lane{i,1}.tick(h);
            end
        end
        
        function V = get_vehicle(obj, i)
            V = obj.Lane{cell2mat(obj.Lane(:,3)) == i, 1};
        end
        
    end
end

