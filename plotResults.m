function plotResults(problem, myTitle)    
    x = linspace(problem.x0, problem.xE, 500);
    y = problem.y(x);
    y0 = deval(problem.sol0, x, 1);
    
    %y0 = problem.sol0.y(1,:);

    tName = '';
    if nargin == 2
        tName = [myTitle ': '];
    end
    figure('Name', sprintf('%sPsi0 = %f; Psi1 = %f', tName,...
       problem.criteria(), problem.constraint()));

    subplot(3, 1, 1);
    hold on
    plot(x,problem.u(x));
    plot(x,problem.u0(x));
    legend('u(x)', 'u0(x)');
    hold off
    xlabel(' ')
    title('u(x)');

    subplot(3, 1, [2 3]); 
    hold on
    plot(x, y);
    plot(x, y0);
    
    optRange = problem.Omega(problem.optO)';
    line(optRange, repmat(problem.yd, size(optRange)),...
        'Color', 'r', 'LineStyle', '-.');

    limRange = problem.Omega(Helper.OtherIndex(problem.optO))';
    line(limRange, repmat(problem.yMax, size(limRange)),...
        'Color', 'b', 'LineStyle', '--');

    line(repmat(problem.Omega(1),2,1), repmat(get(gca,'YLim'),2,1)',...
        'Color', 'm', 'LineStyle', ':');
    
    legend('y(x)', 'y0(x)', 'yd', 'yMax')
    hold off
    title('y(x)');
    xlabel('x');
end
