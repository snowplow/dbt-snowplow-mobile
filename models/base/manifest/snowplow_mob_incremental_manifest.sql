{{ 
  config(
    materialized='incremental'
  ) 
}}

-- Boilerplate to generate table.
-- Table updated as part of end-run hook

with prep as (
  select
    cast(null as {{ dbt_utils.type_string() }}) model,
    cast(null as {{ dbt_utils.type_timestamp() }}) as last_success
)

select *

from prep

{% if is_incremental() %}
  where false
{% endif %}
