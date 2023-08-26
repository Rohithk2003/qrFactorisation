create function subtract_column_rows(c1 double precision [], c2 double precision []) returns SETOF double precision language plpgsql as $ $ DECLARE i integer := 1;

j float;

BEGIN while i <= array_length(c1, 1) loop j = c1 [i] - c2 [i];

i := i + 1;

return next j;

end loop;

END $ $;

alter function subtract_column_rows(double precision [], double precision []) owner to postgres;