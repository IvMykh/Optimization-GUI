function main()
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

