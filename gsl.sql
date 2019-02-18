create or replace function gsl(
    table_name_arg    information_schema.sql_identifier,
    table_schema_arg  information_schema.sql_identifier = current_schema(),
    max_line_size         integer = 72
    )
returns text as $$
declare
    rec record;
    column_list text := '';
    line_size int := 0;
begin
   for rec in
      select column_name from information_schema.columns
         where table_schema = table_schema_arg and
               table_name = table_name_arg
         order by ordinal_position
   loop
       line_size := line_size + length(rec.column_name);
       if line_size > max_line_size then
          column_list = column_list || U&'\000A';
          line_size = 0;
       end if;
       column_list = column_list || rec.column_name || ', ';
   end loop;
   -- last comma added should not be there
   column_list = substr(column_list, 1, length(column_list)-2);
   raise info '%', column_list;
   return column_list;
end;
$$ language plpgsql;
