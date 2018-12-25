classdef Adjoint < SensitivityHelper
    methods
        function this = Adjoint(b)
            this = this@SensitivityHelper(b);
            this.initPrime();
        end
        function initPrime(this)
            if this.j == 1
                 if strcmp(this.method, 'constant')
                     this.rPrime = @(x) 0;
                 else
                     val = this.b(2:end) - this.b(1:end-1);
                     this.rPrime = @(x) this.interpolate(...
                         x, val, 'constant');
                 end
            else
                rSym = sym(this.r);
                rPrimeSym = diff(rSym);
                this.rPrime = matlabFunction(rPrimeSym);
            end
        end
        function oIndex = psiOmega(this, i)
           switch i
               case 0
                   oIndex = this.optO;
               case 1
                   oIndex = this.limO;
           end
        end
        
        function dm = odeAM(this, x, m, i)
            y = this.y(x, [1 2]);
            dm = zeros(2, 1);
            dm(1) = m(2);
            dm(2) = -this.r(x)*m(2) + this.rPrime(x)*m(1) + ...
                (this.g1(x) + this.g3(x)*3*y(1)^2)*m(1);
            dp = 0;
            if Helper.inRegion(x, this.Omega(this.psiOmega(i)))
                switch i
                    case 0
                    	dp = 2*this.gammaY*(y(1)-this.yd);
                    case 1
                        dp = 2*this.gammaY*...
                            (abs(this.y(x)-this.yMax)+...
                                 this.y(x)-this.yMax).*(...
                            sign(this.y(x)-this.yMax)+1);
                end
            end
            dm(2) = dm(2) - dp;
        end
        function res = bcAM(this, m0, mE)
            res = zeros(2, 1);
            bcExp = @(m, x) [-m(2) - m(1)*this.r(x); m(1)];
            type0 = ~this.bcType(1,:);
            typeE = ~this.bcType(2,:);
            res(1) = type0 * bcExp(m0, this.x0);
            res(2) = typeE * bcExp(mE, this.xE);
        end
        function mu = mu(~, x, sol)
            muVec = deval(sol, x);
            mu = muVec(1,:);
        end
        function dp = dPsiIntY(this, x, sol, i)
            y = this.y(x, [1 2]);
            mult = {-y(2,:), -y(1,:), -y(1,:).^3, 1};
            dp = this.dudb(x, i).*this.mu(x, sol).*mult{this.j};
        end
        function dp = dPsi0db(this, sol, i)
            dp = Helper.Integrate(...
                    this.Omega(0),...
                    @(x)this.dPsiIntY(x, sol, i)) + ...
                this.gammaU * Helper.Integrate(...
                    this.Omega(0),...
                    @(x) 2*this.u(x).*this.dudb(x, i));
        end
        function dp = dPsi1db(this, sol, i)
            dp = Helper.Integrate(...
                    this.Omega(0),...
                    @(x)this.dPsiIntY(x, sol, i));
        end
        function grad = Gradient(this, index)
            if ~isempty(this.cacheGrad{index+1})
                grad = this.cacheGrad{index+1};
            else
                bRange = 1:length(this.b);
                if ~isempty(this.cacheSens) &&...
                    length(this.cacheSens) > index &&...
                   ~isempty(this.cacheSens{index+1})
                    sol = this.cacheSens{index+1};
                else
                    init = bvpinit(this.Omega, [0 0]);
                    sol = bvp4c(@(x,m)this.odeAM(x,m,index),...
                        @this.bcAM, init);
                    this.cacheSens{index+1} = sol;
                end
                switch index
                    case 0
                        psiBi = @(i)this.dPsi0db(sol, i);
                    case 1
                        psiBi = @(i)this.dPsi1db(sol, i);
                end
                grad = arrayfun(psiBi, bRange);
                this.cacheGrad{index+1}= grad;
            end
        end
    end
    
    properties
       rPrime = @(x) 0;
    end
    
end