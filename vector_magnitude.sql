create function vector_mag_calc(column_name character varying) returns double precision language plpgsql as $ $ declare query_text varchar := 'select ' || quote_ident(column_name) || ' from q_table where ' || quote_ident(column_name) || ' is not null';

sum double precision := 0;

i double precision;

begin for i in execute query_text loop sum := sum + i * i;

end loop;

sum := sqrt(sum);

return sum;

end;

$ $;

alter function vector_mag_calc(varchar) owner to postgres;