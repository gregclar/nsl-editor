
class Loader::Name::MakeOneInstance::MakeOneMisappInstance
  def initialize(loader_name, match, user, job)
    @tag = "#{self.class} for #{loader_name.simple_name} (#{loader_name.record_type})"
    @loader_name = loader_name
    @match = match
    @user = user
    @job = job
  end

  def create
    Rails.logger.debug("create_or_find_relationship_instance for id: #{@loader_name.simple_name} ##{@loader_name.id}")
    if @match.relationship_instance_id.present?
      entry = "#{Constants::DECLINED_INSTANCE}: relationship instance already "
      entry += "noted (##{@match.relationship_instance_id}) for "
      entry += "#{@loader_name.simple_name} ##{@loader_name.id}"
      log_to_table(entry)
      return Loader::Name::Match::DECLINED
    end
    if misapp_already_attached?
      record_misapp_already_there(@user)
      entry = "#{Constants::DECLINED_INSTANCE}: misapp already there for "
      entry += "#{@loader_name.simple_name} ##{@loader_name.id}"
      log_to_table(entry)
      return Loader::Name::Match::DECLINED
    end
    if @loader_name.parent.preferred_match.use_existing_instance == true
      entry = "#{Constants::DECLINED_INSTANCE}: parent is using existing instance for "
      entry += "#{@loader_name.simple_name} ##{@loader_name.id}"
      log_to_table(entry)
      return Loader::Name::Match::DECLINED
    end
    return create_misapp_instance
  rescue => e
    entry = "Failed to create instance for #{@loader_name.simple_name} "
    entry += "##{@loader_name.id} - error in do_one_loader_name: #{e.to_s}"
    log_to_table(entry)
    #return Loader::Name::Match::ERROR
    raise
  end

  def misapp_already_attached?
    return false if @loader_name.parent.loader_name_matches.blank?
    return false if @loader_name.parent.loader_name_matches.first.try('standalone_instance_id').blank?

    instances = Instance.where(name_id: @match.name_id)
                        .where(cites_id: @match.instance_id)
                        .where(cited_by_id: @loader_name.parent.loader_name_matches.first.try('standalone_instance_id'))
    return !instances.blank?
  end
      
  def record_misapp_already_there
    instances = Instance.where(name_id: @match.name_id)
                        .where(cites_id: @match.instance_id)
                        .where(cited_by_id: @loader_name.parent.loader_name_matches.first.try('standalone_instance_id'))
    @match.relationship_instance_found = true
    @match.relationship_instance_id = instances.first.id
    @match.created_by = @match.updated_by = "bulk for #{@user}"
    @match.save!
    return true
  end

  def create_misapp_instance
    if @loader_name.parent.loader_name_matches.first.try('standalone_instance_id').blank?
      entry = "#{Constants::DECLINED_INSTANCE}: loader name parent has no standalone instance so cannot proceed "
      entry += "#{@loader_name.simple_name} ##{@loader_name.id}"
      log_to_table(entry)
      return [0,1,0]
    else  
      new_instance = Instance.new
      new_instance.draft = false
      new_instance.cited_by_id = @loader_name.parent.loader_name_matches.first.standalone_instance_id
      new_instance.reference_id = @loader_name.parent.loader_name_matches.first.standalone_instance.reference_id
      new_instance.cites_id = @match.instance_id
      new_instance.name_id = @match.instance.name_id
      throw "No relationship instance type id for #{id} #{@loader_name.simple_name}" if @match.relationship_instance_type_id.blank?
      new_instance.instance_type_id = @match.relationship_instance_type_id
      new_instance.created_by = new_instance.updated_by = "bulk for #{@user}"
      new_instance.save!
      note_misapp_created(new_instance)
      return [1,0,0]
    end
  rescue => e
    entry = "MakeOneMisappInstance#create_misapp_instance: #{e.to_s}"
    Rails.logger.error(entry)
    entry = "#{Constants::FAILED_INSTANCE}: #{e.to_s}"
    log_to_table(entry)
    return [0,0,1]
  end

  def note_misapp_created(instance)
    @match.relationship_instance_created = true
    @match.relationship_instance_id = instance.id
    @match.updated_by = "bulk for #{@user}"
    @match.save!
    log_to_table("#{Constants::CREATED_INSTANCE} for loader_name " +
                 "##{@loader_name.id} #{@loader_name.simple_name}")
  end

  def log_to_table(entry)
    BulkProcessingLog.log("Job ##{@job}: #{entry}","for #{@user}")
  rescue => e
    Rails.logger.error("Couldn't log to table: #{e.to_s}")
  end
end
