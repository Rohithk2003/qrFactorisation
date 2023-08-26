create function iterate_through_columns() returns void language plpgsql as $ $ declare column_ record;

query_text varchar;

v float [];

v_index integer := 1;

v_iterating_value float;

i integer := 1;

j integer := 1;

second_loop_index integer := 1;

updated_values float [];

valuesfromprojection float;

index_updated_array integer := 1;

q_table_columns varchar [] := Array ['c1','c2','c3','c4','c5'];

r_value float;

temp float;

BEGIN execute 'drop table  q_table';

execute 'drop table  r_table';

execute 'create table if not exists r_table (c1 double precision,c2 double precision,c3 double precision,c4 double precision,c5 double precision)';

execute 'create table if not exists q_table (c1 double precision,c2 double precision,c3 double precision,c4 double precision,c5 double precision)';

for column_ in
SELECT
    *
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = N'iris' loop query_text := 'select ' || column_.column_name || ' from iris';

v := ARRAY [] :: float [];

updated_values := ARRAY [] :: float [];

index_updated_array := 1;

second_loop_index := 1;

v_index := 1;

for v_iterating_value in execute query_text loop v [v_index] = v_iterating_value;

v_index := v_index + 1;

end loop;

for second_loop_index in j..(i - 1) loop index_updated_array := 1;

for valuesfromprojection in
select
    *
from
    find_projection(
        cast(column_.column_name as varchar),
        q_table_columns [second_loop_index]
    ) loop raise notice 'projection values for %,%',
    valuesfromprojection,
    i;

updated_values [index_updated_array] = valuesfromprojection;

index_updated_array := index_updated_array + 1;

end loop;

v_index := 1;

raise notice 'value of v is % % % % %',
v,
i,
column_.column_name,
q_table_columns [second_loop_index],
updated_values;

for v_iterating_value in
select
    *
from
    subtract_column_rows(v, updated_values) loop raise notice 'subtracted values for %,%',
    v_iterating_value,
    i;

v [v_index] := v_iterating_value;

v_index := v_index + 1;

end loop;

end loop;

for temp in
select
    *
from
    normalize_(v) loop raise notice 'vale of normalized is % , %',
    temp,
    i;

query_text := 'insert into q_table (' || quote_ident(q_table_columns [i]) || ') values (' || temp || ')';

execute query_text;

end loop;

second_loop_index := 1;

j := 1;

for second_loop_index in j..i loop r_value := dotproduct(
    cast(column_.column_name as varchar),
    'iris',
    q_table_columns [second_loop_index],
    'q_table'
);

raise notice 'r value is % % % %',
r_value,
i,
column_.column_name,
q_table_columns [second_loop_index];

execute 'insert into r_table(' || quote_ident(q_table_columns [i]) || ') values(' || r_value || ')';

end loop;

i := i + 1;

end loop;

end;

$ $;

alter function iterate_through_columns() owner to postgres;