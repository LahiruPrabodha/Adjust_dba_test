CREATE OR REPLACE FUNCTION format_min_max(anyelement, text) RETURNS text AS $$
DECLARE
  min_value anyelement;
  max_value anyelement;
  format_string text;
BEGIN
  min_value := NULL;
  max_value := NULL;
  format_string := $2;

  IF (format_string IS NULL) THEN
    format_string := '%s -> %s';
  END IF;

  IF (TG_OP = 'GROUP') THEN
    min_value := MIN(min_value, $1);
    max_value := MAX(max_value, $1);
    RETURN format(format_string, min_value::text, max_value::text);
  ELSE
    min_value := $1;
    max_value := $1;
    RETURN NULL;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE AGGREGATE min_max(anyelement) (
  SFUNC = format_min_max,
  STYPE = text,
  FINALFUNC = format_min_max
);

or


CREATE OR REPLACE FUNCTION min_to_max(anyarray)
RETURNS text AS $$
DECLARE
  min_value anyelement;
  max_value anyelement;
BEGIN
  min_value := array_min($1);
  max_value := array_max($1);
  RETURN min_value || ' -> ' || max_value;
END;
$$ LANGUAGE plpgsql;

CREATE AGGREGATE min_to_max_agg (anyelement) (
  SFUNC = array_append,
  STYPE = anyarray,
  FINALFUNC = min_to_max,
  INITCOND = '{}'
);
