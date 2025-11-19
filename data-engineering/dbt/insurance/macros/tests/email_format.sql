{% test email_format(model, column_name) %}

with invalid as (
    select {{ column_name }} as email_value
    from {{ model }}
    where {{ column_name }} is not null
      and not (
          {{ column_name }} ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      )
)

select count(*) as failures
from invalid

{% endtest %}
