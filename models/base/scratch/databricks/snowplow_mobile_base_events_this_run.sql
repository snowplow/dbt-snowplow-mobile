{{
   config(
     tags=["this_run"]
   )
 }}

  {%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_mobile_base_sessions_this_run'),
                                                                           'start_tstamp',
                                                                           'end_tstamp') %}

  {% set session_id = snowplow_mobile.get_session_id_path_sql(relation_alias='a') %}

  with prep as (

    select
    -- screen view events
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.id::STRING AS screen_view_id,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.name::STRING AS screen_view_name,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_id::STRING AS screen_view_previous_id,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_name::STRING AS screen_view_previous_name,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_type::STRING AS screen_view_previous_type,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.transition_type::STRING AS screen_view_transition_type,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.type::STRING AS screen_view_type,
    -- screen context
    {% if var('snowplow__enable_screen_context', false) %}
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].id::STRING AS screen_id,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].name::STRING AS screen_name,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].activity::STRING AS screen_activity,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].fragment::STRING AS screen_fragment,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].top_view_controller::STRING AS screen_top_view_controller,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].type::STRING AS screen_type,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].view_controller::STRING AS screen_view_controller,
    {% else %}
      cast(null as {{ type_string() }}) as screen_id, --could rename to screen_view_id and coalesce with screen view events.
      cast(null as {{ type_string() }}) as screen_name,
      cast(null as {{ type_string() }}) as screen_activity,
      cast(null as {{ type_string() }}) as screen_fragment,
      cast(null as {{ type_string() }}) as screen_top_view_controller,
      cast(null as {{ type_string() }}) as screen_type,
      cast(null as {{ type_string() }}) as screen_view_controller,
    {% endif %}
    -- mobile context
    {% if var('snowplow__enable_mobile_context', false) %}
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].device_manufacturer::STRING AS device_manufacturer,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].device_model::STRING AS device_model,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].os_type::STRING AS os_type,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].os_version::STRING AS os_version,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].android_idfa::STRING AS android_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].apple_idfa::STRING AS apple_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].apple_idfv::STRING AS apple_idfv,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].carrier::STRING AS carrier,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].open_idfa::STRING AS open_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].network_technology::STRING AS network_technology,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].network_type::STRING AS network_type,
    {% else %}
      cast(null as {{ type_string() }}) as device_manufacturer,
      cast(null as {{ type_string() }}) as device_model,
      cast(null as {{ type_string() }}) as os_type,
      cast(null as {{ type_string() }}) as os_version,
      cast(null as {{ type_string() }}) as android_idfa,
      cast(null as {{ type_string() }}) as apple_idfa,
      cast(null as {{ type_string() }}) as apple_idfv,
      cast(null as {{ type_string() }}) as carrier,
      cast(null as {{ type_string() }}) as open_idfa,
      cast(null as {{ type_string() }}) as network_technology,
      cast(null as {{ type_string() }}) as network_type,
    {% endif %}
    -- geo context
    {% if var('snowplow__enable_geolocation_context', false) %}
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude::FLOAT AS device_latitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].longitude::FLOAT AS device_longitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude_longitude_accuracy::FLOAT AS AS device_latitude_longitude_accuracy,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitude::FLOAT AS device_altitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude_accuracy::FLOAT AS AS device_altitude_accuracy,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].bearing::FLOAT AS AS device_bearing,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].speed::FLOAT AS device_speed,
    {% else %}
      cast(null as {{ type_float() }}) as device_latitude,
      cast(null as {{ type_float() }}) as device_longitude,
      cast(null as {{ type_float() }}) as device_latitude_longitude_accuracy,
      cast(null as {{ type_float() }}) as device_altitude,
      cast(null as {{ type_float() }}) as device_altitude_accuracy,
      cast(null as {{ type_float() }}) as device_bearing,
      cast(null as {{ type_float() }}) as device_speed,
    {% endif %}
    -- app context
    {% if var('snowplow__enable_application_context', false) %}
      a.contexts_com_snowplowanalytics_mobile_application_1[0].build::STRING AS build,
      a.contexts_com_snowplowanalytics_mobile_application_1[0].version::STRING AS version,
    {% else %}
      cast(null as {{ type_string() }}) as build,
      cast(null as {{ type_string() }}) as version,
    {% endif %}
    -- session context
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_id::STRING AS session_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_index::INT AS session_index,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].previous_session_id::STRING AS previous_session_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].user_id::STRING AS device_user_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].first_event_id::STRING AS session_first_event_id,
    -- select all from events except non-mobile fields.
    a.app_id,
    a.platform,
    a.etl_tstamp,
    a.collector_tstamp,
    a.dvce_created_tstamp,
    a.event,
    a.event_id,
    a.txn_id,
    a.name_tracker,
    a.v_tracker,
    a.v_collector,
    a.v_etl,
    a.user_id,
    a.user_ipaddress,
    a.user_fingerprint,
    a.domain_userid,
    a.domain_sessionidx,
    a.network_userid,
    a.geo_country,
    a.geo_region,
    a.geo_city,
    a.geo_zipcode,
    a.geo_latitude,
    a.geo_longitude,
    a.geo_region_name,
    a.ip_isp,
    a.ip_organization,
    a.ip_domain,
    a.ip_netspeed,
    a.page_url,
    a.page_title,
    a.page_referrer,
    a.page_urlscheme,
    a.page_urlhost,
    a.page_urlport,
    a.page_urlpath,
    a.page_urlquery,
    a.page_urlfragment,
    a.refr_urlscheme,
    a.refr_urlhost,
    a.refr_urlport,
    a.refr_urlpath,
    a.refr_urlquery,
    a.refr_urlfragment,
    a.refr_medium,
    a.refr_source,
    a.refr_term,
    a.mkt_medium,
    a.mkt_source,
    a.mkt_term,
    a.mkt_content,
    a.mkt_campaign,
    a.se_category,
    a.se_action,
    a.se_label,
    a.se_property,
    a.se_value,
    a.tr_orderid,
    a.tr_affiliation,
    a.tr_total,
    a.tr_tax,
    a.tr_shipping,
    a.tr_city,
    a.tr_state,
    a.tr_country,
    a.ti_orderid,
    a.ti_sku,
    a.ti_name,
    a.ti_category,
    a.ti_price,
    a.ti_quantity,
    a.pp_xoffset_min,
    a.pp_xoffset_max,
    a.pp_yoffset_min,
    a.pp_yoffset_max,
    a.useragent,
    a.br_name,
    a.br_family,
    a.br_version,
    a.br_type,
    a.br_renderengine,
    a.br_lang,
    a.br_features_pdf,
    a.br_features_flash,
    a.br_features_java,
    a.br_features_director,
    a.br_features_quicktime,
    a.br_features_realplayer,
    a.br_features_windowsmedia,
    a.br_features_gears,
    a.br_features_silverlight,
    a.br_cookies,
    a.br_colordepth,
    a.br_viewwidth,
    a.br_viewheight,
    a.os_name,
    a.os_family,
    a.os_manufacturer,
    a.os_timezone,
    a.dvce_type,
    a.dvce_ismobile,
    a.dvce_screenwidth,
    a.dvce_screenheight,
    a.doc_charset,
    a.doc_width,
    a.doc_height,
    a.tr_currency,
    a.tr_total_base,
    a.tr_tax_base,
    a.tr_shipping_base,
    a.ti_currency,
    a.ti_price_base,
    a.base_currency,
    a.geo_timezone,
    a.mkt_clickid,
    a.mkt_network,
    a.etl_tags,
    a.dvce_sent_tstamp,
    a.refr_domain_userid,
    a.refr_dvce_tstamp,
    a.domain_sessionid,
    a.derived_tstamp,
    a.event_vendor,
    a.event_name,
    a.event_format,
    a.event_version,
    a.event_fingerprint,
    a.true_tstamp

  from {{ var('snowplow__events') }} as a
  inner join {{ ref('snowplow_mobile_base_sessions_this_run') }} as b
  on {{ session_id }} = b.session_id

  where a.collector_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'b.start_tstamp') }}
  and a.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__days_late_allowed", 3), 'a.dvce_created_tstamp') }}
  and a.collector_tstamp >= {{ lower_limit }}
  and a.collector_tstamp <= {{ upper_limit }}
  {% if var('snowplow__derived_tstamp_partitioned', true) and target.type == 'bigquery' | as_bool() %} -- BQ only
    and a.derived_tstamp >= {{ snowplow_utils.timestamp_add('hour', -1, lower_limit) }}
    and a.derived_tstamp <= {{ upper_limit }}
  {% endif %}
  and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
  and a.platform in ('{{ var("snowplow__platform")|join("','") }}') -- filters for 'mob' by default

  qualify row_number() over (partition by a.event_id order by a.collector_tstamp, a.etl_tstamp) = 1

  )

  select
    *,
    row_number() over(partition by session_id order by derived_tstamp) as event_index_in_session

  from prep
