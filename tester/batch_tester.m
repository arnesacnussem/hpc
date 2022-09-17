function [isEquals, err_amounts] = batch_tester(batch, func, codeMat, H, table)

    for i = 1:length(batch)
        errs = cell2mat(batch(i));
        modify = modifyCode(codeMat, errs);
        cwOut = func(modify, H, table);

        isEquals(i) = isequal(codeMat, cwOut);
        err_amounts(i) = length(errs);
    end

end

function [codeModified] = modifyCode(code, errs)
    codeModified = code;

    for pos = errs
        codeModified(pos) = 1 - codeModified(pos);
    end

end
