classdef Helper
    
    methods(Static)
        function int = Integrate(ranges, func)
            spaceSize = 25;
            int = 0;
            for range = ranges'
                interval = linspace(range(1), range(2), spaceSize);
                values = func(interval);
                int = int + trapz(interval, values);
            end
        end
        function g = GradientFDM(b, index, d)
            if nargin < 3
               d = 0.01; 
            end
            n = length(b);
            g = zeros(1, n);
            psi = GeneralProblem(b).Psi(index);
            for i = 1:n
                bD = b;
                bD(i) = bD(i) + d;
                psiD = GeneralProblem(bD).Psi(index);
                g(i) = (psiD - psi) / d;
            end
        end
        
        function f  = ConstInterp(interval, values, x)
            [~, index] = histc(x, interval);
            len = length(values);
            index(index > len) = len;
            f = values(index);
        end
        function index = OtherIndex(i)
           index = abs(i - 3); % 1->2 || 2->1 
        end
        function is = inRegion(x, region)
            is = any(region(:,1) <= x & x <= region(:,2));
        end
        
    end
    
    properties(Constant)
        Dirichlet = [1 0]
        Neumann = [0 1]
        Robin = [1 1]
    end
end