create function dotproduct(
    column1 character varying,
    first_table character varying,
    column2 character varying,
    second_table character varying
) returns double precision language plpgsql as $ $ DECLARE c3 float := 0;

query_text varchar := 'SELECT ' || quote_ident(column1) || ' FROM ' || first_table || ' where ' || quote_ident(column1) || ' is not null';

query_text_second varchar := 'select ' || quote_ident(column2) || ' from ' || second_table || ' where ' || quote_ident(column2) || ' is not null';

first_query_result float [];

first_query_iterator float;

first_query_index integer := 1;

second_query_result float [];

second_query_iterator float;

second_query_index integer := 1;

BEGIN raise notice 'query text boith is % %',
query_text,
query_text_second;

for first_query_iterator in execute query_text loop first_query_result [first_query_index] := first_query_iterator;

first_query_index := first_query_index + 1;

end loop;

for second_query_iterator in execute query_text_second loop second_query_result [second_query_index] := second_query_iterator;

second_query_index := second_query_index + 1;

end loop;

raise notice '% % %',
first_query_result,
column1,
query_text;

first_query_index := 1;

second_query_index := 1;

while first_query_index <= array_length(first_query_result, 1) loop c3 := c3 + first_query_result [first_query_index] * second_query_result [second_query_index];

first_query_index := first_query_index + 1;

second_query_index := second_query_index + 1;

end loop;

return c3;

end;

$ $;

alter function dotproduct(varchar, varchar, varchar, varchar) owner to postgres;