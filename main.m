function main()
    function plotResults(problem, myTitle)    
        x = linspace(problem.x0, problem.xE, 500);
        y = problem.y(x);

        tName = '';
        if nargin == 2
            tName = [myTitle ': '];
        end
        figure('Name', sprintf('%sPsi0 = %f; Psi1 = %f', tName,...
           problem.criteria(), problem.constraint()));

        subplot(3, 1, 1);
        hold on
        plot(x,problem.u(x));
        hold off
        xlabel(' ')
        title('u(x)');

        subplot(3, 1, [2 3]); 
        hold on
        plot(x, y);

        optRange = problem.Omega(problem.optO)';
        line(optRange, repmat(problem.yd, size(optRange)),...
            'Color', 'r', 'LineStyle', '-.');

        limRange = problem.Omega(Helper.OtherIndex(problem.optO))';
        line(limRange, repmat(problem.yMax, size(limRange)),...
            'Color', 'b', 'LineStyle', '--');

        line(repmat(problem.Omega(1),2,1), repmat(get(gca,'YLim'),2,1)',...
            'Color', 'm', 'LineStyle', ':');
        hold off
        title('y(x)');
        xlabel('x');
    end

    clear;
    clc;

    tic;
    b0 = [
        1 
        1
     ];
    % FiniteDifferences
    % Adjoint
    % DirectDiff
    q = GeneralProblem(b0);
    q.optimize(false, true);
    %q.direct()
    q.b
    q.criteria()
    q.constraint()
    toc;

    plotResults(q, 'Title')
    
end

