# frozen_string_literal: true

# Name scopes
module NameNamable
  extend ActiveSupport::Concern
  def apni_json
    logger.info("apni_json; service call unless cached...")
    Rails.cache.fetch("#{cache_key}/in_apni", expires_in: 1.minutes) do
      JSON.load(RestClient.get(Name::AsServices.in_apni_url(id), "Accept" => "text/json", read_timeout: 1))
    end
  rescue StandardError => e
    logger.error("Name#apni_json error: #{e}")
    raise
  end

  def apni?
    json = apni_json
    json["inAPNI"] == true
  rescue StandardError => e
    logger.error("Is this in APNI name error.")
    logger.error(e.to_s)
    false
  end

  def apni_family_json
    Rails.cache.fetch("#{cache_key}/apni_info", expires_in: 1.minutes) do
      JSON.load(RestClient.get(Name::AsServices.apni_family_url(id), "Accept" => "text/json", read_timeout: 1))
    end
  end

  def apni_family_name
    json = apni_family_json
    json["familyName"]["name"]["simpleName"]
  rescue StandardError => e
    logger.error("apni_family_name error: #{e}")
    "apni family unknown - service error: #{e}"
  end

  def get_names_json
    JSON.load(RestClient.get(Name::AsServices.name_strings_url(id), "Accept" => "text/json"))
  end

  # Use update_columns to avoid validation errors, stale object
  # errors and timestamp changes.
  def refresh_constructed_name_fields
    names_json = get_names_json
    if full_name != names_json["result"]["fullName"] ||
       full_name_html != names_json["result"]["fullMarkedUpName"] ||
       simple_name != names_json["result"]["simpleName"] ||
       simple_name_html != names_json["result"]["simpleMarkedUpName"]

      update_columns(full_name: names_json["result"]["fullName"],
                     full_name_html: names_json["result"]["fullMarkedUpName"],
                     simple_name: names_json["result"]["simpleName"],
                     simple_name_html:
                     names_json["result"]["simpleMarkedUpName"],
                     sort_name: names_json["result"]["sortName"])
      1
    else
      0
    end
  rescue StandardError => e
    logger.error("refresh_constructed_name_field! exception: #{e}")
    raise
  end

  def set_names!
    names_json = get_names_json
    reload
    self.full_name = names_json["result"]["fullName"]
    self.full_name_html = names_json["result"]["fullMarkedUpName"]
    self.simple_name = names_json["result"]["simpleName"]
    self.simple_name_html = names_json["result"]["simpleMarkedUpName"]
    self.sort_name = names_json["result"]["sortName"]
    save!(touch: false)
  rescue StandardError => e
    logger.error("set_names! exception: #{e}")
    logger.error("set_names! retrying...")
    retry_set_names!(names_json)
  end

  def retry_set_names!(names_json)
    reload
    self.full_name = names_json["result"]["fullName"]
    self.full_name_html = names_json["result"]["fullMarkedUpName"]
    self.simple_name = names_json["result"]["simpleName"]
    self.simple_name_html = names_json["result"]["simpleMarkedUpName"]
    self.sort_name = names_json["result"]["sortName"]
    save!(touch: false)
  rescue StandardError => e
    logger.error("retry_set_names! exception: #{e}")
    raise "Unable to set up the name via Services.  Please report this error to App Support."
  end
end
