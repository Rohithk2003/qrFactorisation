create function find_projection(
    column1 character varying,
    column2 character varying
) returns SETOF double precision language plpgsql as $ $ DECLARE numerator float := dotproduct(column1, 'iris', column2, 'q_table');

denominator float := vector_mag_calc(column2);

query_text varchar := 'select ' || quote_ident(column2) || ' from q_table where ' || quote_ident(column2) || ' is not null';

record_var float;

multiplying float;

temp float;

BEGIN denominator := denominator * denominator;

multiplying := numerator / denominator;

for record_var in execute query_text loop temp := record_var * multiplying;

return next temp;

end loop;

end;

$ $;

alter function find_projection(varchar, varchar) owner to postgres;