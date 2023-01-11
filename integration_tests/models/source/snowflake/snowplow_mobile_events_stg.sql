/* page view context is given as json string in csv. Had to flatten it first to be able to rename the keys as the loader/transformer
leaves the fields in camel case for Snowflake unlike for other warehouses. Parse json */

with prep as (
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
    parse_json(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
    parse_json(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1) as contexts_com_snowplowanalytics_snowplow_client_session_1,
    parse_json(contexts_com_snowplowanalytics_snowplow_geolocation_context_1_1_0) as contexts_com_snowplowanalytics_snowplow_geolocation_context_1

from {{ ref('snowplow_mobile_events') }}
)

, flatten as (

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
    unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0]:id::varchar AS id,
    unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0]:name::varchar AS name,
    unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0]:previous_id::varchar AS previousId,
    unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0]:previous_name::varchar AS previousName,
    unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0]:previous_type::varchar AS previousType,
    unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0]:transition_type::varchar AS transitionType,
    unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0]:type::varchar AS type,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0]:first_event_id::varchar AS firstEventId,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0]:previous_session_id::varchar AS previousSessionId,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0]:session_id::varchar AS sessionId,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0]:session_index::varchar AS sessionIndex,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0]:user_id::varchar AS userId,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0]:event_index::varchar AS eventIndex,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0]:storage_mechanism::varchar AS storageMechanism,
    contexts_com_snowplowanalytics_snowplow_client_session_1[0]:first_event_timestamp::varchar AS firstEventTimestamp,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:latitude::float AS latitude,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:longitude::float AS longitude,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:latitude_longitude_accuracy::float AS latitudeLongitudeAccuracy,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:altitude::float AS altitude,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:altitude_accuracy::float AS altitudeAccuracy,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:bearing::float AS bearing,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:speed::float AS speed,
    contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:timestamp::int AS timestamp

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
    object_construct('id',id,'name',name,'previousId',previousId,'previousName',previousName,'previousType',previousType,'transitionType',transitionType,'type',type) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
    parse_json('[{"firstEventId":"'||firstEventId||'", "previousSessionId":"'||previousSessionId||'", "sessionId":"'||sessionId||'", "sessionIndex":"'||sessionIndex||'", "userId":"'||userId||'", "eventIndex":"'||eventIndex||'", "storageMechanism":"'||storageMechanism||'", "firstEventTimestamp":"'||firstEventTimestamp||'"}]' ) as contexts_com_snowplowanalytics_snowplow_client_session_1,
    to_variant([OBJECT_CONSTRUCT_KEEP_NULL('latitude', latitude, 'longitude', longitude, 'latitudeLongitudeAccuracy', latitudeLongitudeAccuracy, 'altitude', altitude, 'altitudeAccuracy', altitudeAccuracy, 'bearing', bearing,'speed', speed,'timestamp', timestamp)]) as contexts_com_snowplowanalytics_snowplow_geolocation_context_1

from flatten

where {{ edge_cases_to_ignore() }} --filter out any edge cases we havent yet solved for but are included in the test dataset.
