function [succeed] = batch_tester(batch, func, codeMat, H, table, syndt)
    succeed = 0;

    for i = 1:length(batch)
        errs = cell2mat(batch(i));
        modify = modifyCode(codeMat, errs);
        cwOut = func(modify, H, table, syndt);

        if isequal(codeMat, cwOut)
            succeed = succeed + 1;
        end

    end

end

function [codeModified] = modifyCode(code, errs)
    codeModified = code;

    for pos = errs
        codeModified(pos) = 1 - codeModified(pos);
    end

end