
module Loader::Name::Match::MakeOneInstance::CreateSynonymyInstance
  extend ActiveSupport::Concern
  def create_or_find_synonymy_instance(user, job)
    Rails.logger.debug("create_or_find_relationship_instance for id: #{loader_name.simple_name} ##{loader_name.id}")
    if relationship_instance_id.present?
      entry = "#{Loader::Name::Match::DECLINED_INSTANCE} -: relationship instance already "
      entry += "noted (##{relationship_instance_id}) for "
      entry += "#{loader_name.simple_name} ##{loader_name.id}"
      log_to_table(entry, user, job)
      return Loader::Name::Match::DECLINED
    end
    if loader_name.parent.preferred_match.blank?
      entry = "#{Loader::Name::Match::DECLINED_INSTANCE} -: parent has no preferred match"
      entry += " #{loader_name.simple_name} ##{loader_name.id}"
      log_to_table(entry, user, job)
      return Loader::Name::Match::DECLINED
    end
    if loader_name.parent.preferred_match.use_existing_instance == true
      entry = "#{Loader::Name::Match::DECLINED_INSTANCE} -: parent is using existing instance for "
      entry += "#{loader_name.simple_name} ##{loader_name.id}"
      log_to_table(entry, user, job)
      return Loader::Name::Match::DECLINED
    end
    if synonym_already_attached?
      record_synonym_already_there
      entry = "#{Loader::Name::Match::DECLINED_INSTANCE} -: synonym already there for "
      entry += "#{loader_name.simple_name} ##{loader_name.id}"
      log_to_table(entry, user, job)
      return Loader::Name::Match::DECLINED
    end
    return create_relationship_instance(user, job)
  rescue => e
    entry = "#{Loader::Name::Match::ERROR_INSTANCE} - for #{loader_name.simple_name} "
    entry += "##{loader_name.id} - error in do_one_loader_name: #{e.to_s}"
    log_to_table(entry, user, job)
    return Loader::Name::Match::ERROR
  end

  def synonym_already_attached?
    return false if loader_name.parent.loader_name_matches.blank?
    return false if loader_name.parent.loader_name_matches.first.try('standalone_instance_id').blank?

    instances = Instance.where(name_id: name_id)
                        .where(cites_id: instance_id)
                        .where(cited_by_id: loader_name.parent.loader_name_matches.first.try('standalone_instance_id'))
    return !instances.blank?
  end
      
  def record_synonym_already_there
    instances = Instance.where(name_id: name_id)
                        .where(cites_id: instance_id)
                        .where(cited_by_id: loader_name.parent.loader_name_matches.first.try('standalone_instance_id'))
    self.relationship_instance_found = true
    self.relationship_instance_id = instances.first.id
    self.created_by = self.updated_by = "bulk"
    self.save!
    return true
  end

  # 
  def create_relationship_instance(user, job)
    Rails.logger.debug('create_relationship_instance start')
    if loader_name.parent.loader_name_matches.first.try('standalone_instance_id').blank?
      Rails.logger.debug('loader name parent has no standalone instance so cannot create relationship instance')
      entry = "#{Loader::Name::Match::DECLINED_INSTANCE} - loader name parent" +
      " has no standalone instance so cannot proceed " +
      "#{loader_name.simple_name} ##{loader_name.id}"
      log_to_table(entry, user, job)
      return Loader::Name::Match::DECLINED
    else
      Rails.logger.debug('qfter three')
    end
    Rails.logger.debug('Going on to create relationship instance')
    new_instance = Instance.new
    new_instance.draft = false
    new_instance.cited_by_id = loader_name.parent.loader_name_matches.first.standalone_instance_id
    new_instance.reference_id = loader_name.parent.loader_name_matches.first.standalone_instance.reference_id
    new_instance.cites_id = instance_id
    new_instance.name_id = instance.name_id
    throw "No relationship instance type id for #{id} #{loader_name.simple_name}" if relationship_instance_type_id.blank?
    new_instance.instance_type_id = relationship_instance_type_id
    new_instance.created_by = new_instance.updated_by = "#{user}"
    new_instance.save!
    note_created(new_instance, user, job)
    return Loader::Name::Match::CREATED
  rescue => e
    entry = "LoaderNameMatch#create_relationship_instance: #{e.to_s}"
    logger.error(entry)
    log_to_table(entry, user, job)
    return Loader::Name::Match::ERROR
  end

  def note_created(instance, user, job)
    self.relationship_instance_created = true
    self.relationship_instance_id = instance.id
    self.updated_by = "job for #{user}"
    self.save!
    log_to_table("#{Loader::Name::Match::CREATED_INSTANCE} - synonymy for " +
                 "##{loader_name.id} #{loader_name.simple_name}",
                 user, job)
  end

  def log_to_table(entry, user, job)
    BulkProcessingLog.log("Job ##{job}: #{entry}","Bulk job for #{user}")
  rescue => e
    Rails.logger.error("Couldn't log to table: #{e.to_s}")
  end
end
