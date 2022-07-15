function [Error_exist, Correctable, Error_site] = Hdecode(rec, H, table)
    syndrome = rem(rec * H', 2);
    Dsynd = bi2de(syndrome, 'left-msb');

    if Dsynd == 0
        Error_exist = 0;
        Correctable = 0;
        Error_site = 0;
    else
        Error_exist = 1;

        if ismember(Dsynd, table)
            Correctable = 1;
            Error_site = find(table == Dsynd);
        else
            Correctable = 0;
            Error_site = 0;
        end

    end

end
