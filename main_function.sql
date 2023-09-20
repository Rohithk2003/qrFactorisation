create function qr_factorisation(current_table character varying) returns void
    language plpgsql
as
$$
DECLARE
    column_          varchar;
    column_no        integer   := 0;
    column_names     varchar[];
    query_text       text;
    required_columns varchar[] := ARRAY [] ::varchar[];
    i                integer   := 1;
    j                integer;
BEGIN
    drop table if exists t4;
    drop table if exists q_table;
    drop table if exists r_table;
    execute 'create temp table t4 (like ' || current_table || ')';
    execute 'create  table q_table (like ' || current_table || ')';
    for column_ in execute 'SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ' ||
                           quote_literal(current_table) ||
                           ''
        loop
            column_names[i] := column_;
            i := i + 1;
        end loop;
    for column_ in execute 'SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ' ||
                           quote_literal(current_table) ||
                           ''
        loop
            if (column_no::Integer = 0) then
                query_text := 'insert into q_table(' || quote_ident(column_names[1]) || ') SELECT ' ||
                              quote_ident(column_names[1]) || ' / SQRT(SUM(' || quote_ident(column_names[1]) || ' * ' ||
                              quote_ident(column_names[1]) || ') OVER ()) as ' || quote_ident(column_names[1]) ||
                              ' FROM ' ||
                              quote_ident(current_table);
                execute query_text;
            else
                for i in 1..column_no + 1
                    loop
                        required_columns[i] := column_names[i];
                    end loop;
                query_text := 'insert into t4(' || array_to_string(required_columns, ',') || ') select ' ||
                              array_to_string(required_columns[1:array_length(required_columns, 1) - 1], ',') ||
                              ',t1.' || quote_ident(column_) || ' from (select ' || quote_ident(column_) ||
                              ' , row_number() over () as rownum from ' || quote_ident(current_table) || ' ) as t1
                         join (select ' || array_to_string(required_columns, ',') ||
                              ' ,row_number() over () as rownum from q_table) as t2 on t1.rownum = t2.rownum ';
                execute query_text;
                delete from q_table;
                insert into q_table select * from t4;
                delete from t4;
                for i in 1..column_no
                    loop
                        query_text := 'insert into t4(' || array_to_string(required_columns, ',') ||
                                      ') with t(dot_) as (select sum(' ||
                                      required_columns[array_length(required_columns, 1)] || '*' ||
                                      quote_ident(required_columns[i]) || ') from q_table ) select ' ||
                                      array_to_string(required_columns[1:array_length(required_columns, 1) - 1], ',') ||
                                      ', (' || required_columns[array_length(required_columns, 1)] || '-' ||
                                      required_columns[i] || '*t.dot_)/ sqrt(sum(power(' ||
                                      required_columns[array_length(required_columns, 1)] || '-' ||
                                      required_columns[i] || '*t.dot_ ,2)' || ') over() ) ' || ' from q_table ,t';
                        execute query_text;
                        delete from q_table;
                        insert into q_table select * from t4;
                        delete from t4;
                    end loop;
            end if;
            column_no := column_no + 1;
        end loop;
    execute 'create  table r_table (like ' || current_table || ')';
    for i in 1..4
        loop
            query_text := 'insert into r_table select ';
            for j in 1..array_length(column_names, 1)
                loop
                    if (j = array_length(column_names, 1)) then
                        query_text := query_text || 'sum(q_table.' || quote_ident(column_names[i]) ||
                                      '*' || quote_ident(current_table) || '.' || column_names[j] || ')'::text;
                    else
                        query_text := query_text || 'sum(q_table.' || quote_ident(column_names[i]) ||
                                      '*' || quote_ident(current_table) || '.' || column_names[j] || '),'::text;
                    end if;
                end loop;
            query_text := query_text || ' from (select *, row_number() over () as rownum from ' || current_table ||
                          ') as ' || current_table || '
                                          join (select *, row_number() over () as rownum from q_table) as q_table
                                                on ' || current_table || '.rownum = q_table.rownum ' ::text;
            execute query_text;
        end loop;

end ;

$$;

alter function qr_factorisation(varchar) owner to postgres;

