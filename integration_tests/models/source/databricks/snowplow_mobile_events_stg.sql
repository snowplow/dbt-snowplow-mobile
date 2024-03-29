{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

-- page view context is given as json string in csv. Parse json
 {{ config(
  materialized='table',
  )
}}

with prep as (
 select
   *,
   from_json(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0, 'array<struct<id:string, name:string, previous_id:string, previous_name:string, previous_type:string, transition_type:string, type:string>>') as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
   from_json(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, 'array<struct<session_id:string, session_index:string, previous_session_id:string, user_id:string, first_event_id:string, event_index:string, storage_mechanism:string, first_event_timestamp:string>>') as contexts_com_snowplowanalytics_snowplow_client_session_1,
   from_json(contexts_com_snowplowanalytics_snowplow_geolocation_context_1_1_0, 'array<struct<latitude:FLOAT, longitude:FLOAT, latitude_longitude_accuracy:FLOAT, altitude:FLOAT, altitude_accuracy:FLOAT, bearing:FLOAT, speed:FLOAT, timestamp:INT>>') as contexts_com_snowplowanalytics_snowplow_geolocation_context_1

  from {{ ref('snowplow_mobile_events') }}
 )

 , struct_base as (

   select
   *
   except(unstruct_event_com_snowplowanalytics_mobile_screen_view_1),
   unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].id::STRING as id,
   unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].name::STRING as name,
   unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previous_id::STRING as previous_id,
   unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previous_name::STRING as previous_name,
   unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previous_type::STRING as previous_type,
   unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].transition_type::STRING as transition_type,
   unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].type::STRING as type

   from prep
 )


  select
    app_id,
    platform,
    etl_tstamp,
    collector_tstamp,
    dvce_created_tstamp,
    event,
    event_id,
    txn_id,
    name_tracker,
    v_tracker,
    v_collector,
    v_etl,
    user_id,
    user_ipaddress,
    user_fingerprint,
    domain_userid,
    domain_sessionidx,
    network_userid,
    geo_country,
    geo_region,
    geo_city,
    geo_zipcode,
    geo_latitude,
    geo_longitude,
    geo_region_name,
    ip_isp,
    ip_organization,
    ip_domain,
    ip_netspeed,
    page_url,
    page_title,
    page_referrer,
    page_urlscheme,
    page_urlhost,
    page_urlport,
    page_urlpath,
    page_urlquery,
    page_urlfragment,
    refr_urlscheme,
    refr_urlhost,
    refr_urlport,
    refr_urlpath,
    refr_urlquery,
    refr_urlfragment,
    refr_medium,
    refr_source,
    refr_term,
    mkt_medium,
    mkt_source,
    mkt_term,
    mkt_content,
    mkt_campaign,
    se_category,
    se_action,
    se_label,
    se_property,
    se_value,
    tr_orderid,
    tr_affiliation,
    tr_total,
    tr_tax,
    tr_shipping,
    tr_city,
    tr_state,
    tr_country,
    ti_orderid,
    ti_sku,
    ti_name,
    ti_category,
    ti_price,
    ti_quantity,
    pp_xoffset_min,
    pp_xoffset_max,
    pp_yoffset_min,
    pp_yoffset_max,
    useragent,
    br_name,
    br_family,
    br_version,
    br_type,
    br_renderengine,
    br_lang,
    br_features_pdf,
    br_features_flash,
    br_features_java,
    br_features_director,
    br_features_quicktime,
    br_features_realplayer,
    br_features_windowsmedia,
    br_features_gears,
    br_features_silverlight,
    br_cookies,
    br_colordepth,
    br_viewwidth,
    br_viewheight,
    os_name,
    os_family,
    os_manufacturer,
    os_timezone,
    dvce_type,
    dvce_ismobile,
    dvce_screenwidth,
    dvce_screenheight,
    doc_charset,
    doc_width,
    doc_height,
    tr_currency,
    tr_total_base,
    tr_tax_base,
    tr_shipping_base,
    ti_currency,
    ti_price_base,
    base_currency,
    geo_timezone,
    mkt_clickid,
    mkt_network,
    etl_tags,
    dvce_sent_tstamp,
    refr_domain_userid,
    refr_dvce_tstamp,
    domain_sessionid,
    derived_tstamp,
    event_vendor,
    event_name,
    event_format,
    event_version,
    event_fingerprint,
    true_tstamp,
    struct(id, name, previous_id, previous_name, previous_type, transition_type, type) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
    contexts_com_snowplowanalytics_snowplow_client_session_1,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1

  from struct_base

  where {{ edge_cases_to_ignore() }} --filter out any edge cases we havent yet solved for but are included in the test dataset.
