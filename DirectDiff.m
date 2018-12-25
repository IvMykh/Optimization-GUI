classdef DirectDiff < SensitivityHelper
    methods
        function this = DirectDiff(b, m)
            this = this@SensitivityHelper(b, m);
        end
        
        function dm = odeDDM(this, x, m, i)
            y = this.y(x, [1 2]);
            dm = zeros(2, 1);
            
            dm(1) = m(2);
            dm(2) = this.u(x)*m(2) + this.g1(x)*m(1) + ...
                this.g3(x)*m(1)*3*y(1)^2;
            
            mult = {y(2), y(1), y(1)^3, -1};
            dm(2) = dm(2) + this.dudb(x, i)*mult{this.j};
        end
        function res = bcDDM(this, m0, mE)
            res = zeros(2, 1);
            res(1) = this.bcType(1,:) * m0;
            res(2) = this.bcType(2,:) * mE;
        end
        function dp = dPsi0db(this, dydb, i)
            dp = this.gammaY * Helper.Integrate(...
                    this.Omega(this.optO),...
                    @(x) 2*(this.y(x)-this.yd).*...
                        deval(dydb(i),x,1))+...
                this.gammaU * Helper.Integrate(...
                    this.Omega(0),...
                    @(x) 2*this.u(x).*this.dudb(x, i));
        end
        function dp = dPsi1db(this, dydb, i)
            dp = Helper.Integrate(...
                    this.Omega(this.limO),...
                    @(x) 2*(abs(this.y(x)-this.yMax)+...
                                this.y(x)-this.yMax).*(...
                           sign(this.y(x)-this.yMax)+1).*...
                        deval(dydb(i),x, 1));
        end
        function grad = Gradient(this, index)
            if ~isempty(this.cacheGrad{index+1})
                grad = this.cacheGrad{index+1};
            else
                bRange = 1:length(this.b);
                if ~isempty(this.cacheSens)
                    dydb = this.cacheSens{1};
                else
                    init = bvpinit(this.Omega, [0 0]);
                    bvpBi = @(i)bvp4c(@(x,m)this.odeDDM(x,m,i),...
                        @this.bcDDM, init);
                    dydb = arrayfun(bvpBi, bRange);
                    this.cacheSens = {dydb};
                end
                switch index
                    case 0
                        psiBi = @(i)this.dPsi0db(dydb, i);
                    case 1
                        psiBi = @(i)this.dPsi1db(dydb, i);
                end
                grad = arrayfun(psiBi, bRange);
                this.cacheGrad{index+1}= grad;
            end
        end
    end
end