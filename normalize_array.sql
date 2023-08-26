create function normalize_(data double precision []) returns SETOF double precision language plpgsql as $ $ declare i double precision := 1;

temp float;

sum float := 0;

len int := array_length(data, 1);

begin while i <= len loop sum := sum + data [i] * data [i];

i := i + 1;

end loop;

sum := sqrt(sum);

i := 1;

while i <= len loop temp := data [i] / sum;

i := i + 1;

return next temp;

end loop;

end;

$ $;

alter function normalize_(double precision []) owner to postgres;