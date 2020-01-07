class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception  # from v4, needed in v6?
  #before_action :set_debug,
                #:start_timer,
                #:check_system_broadcast,
  before_action :authenticate
                #:check_authorization
  #around_action :user_tagged_logging

  def authenticate
    if session[:username].blank?
      ask_user_to_sign_in
    else
      continue_user_session
    end
  end

  private

  def ask_user_to_sign_in
    session[:url_after_sign_in] = request.url
    respond_to do |format|
      format.html {redirect_to start_sign_in_url, notice: "Please sign in."}
      format.json {render partial: "layouts/no_session.js"}
      format.js {render partial: "layouts/no_session.js"}
    end
  end

  def continue_user_session
    @current_user = User.new(username: session[:username],
                             full_name: session[:user_full_name],
                             groups: session[:groups])
    logger.info("User is known: #{@current_user.username}")
    set_working_draft_session
  end
  
  def set_working_draft_session
    @working_draft = nil
    if session[:draft].present? && TreeVersion.exists?(session[:draft]["id"])
      version = TreeVersion.find(session[:draft]["id"])
      if version.published
        session[:draft] = nil
      else
        @working_draft = version
      end
    end
  end
  
  def hide_details
    @no_search_result_details = true
  end

  attr_reader :current_user

  def username
    @current_user.username
  rescue
    'no current user'
  end

  # Could not get this to work with a guard clause.
  def javascript_only
    logger.debug("format: #{request.format}")
    unless request.format == "text/javascript"
      logger.error('Rejecting a non-JavaScript request and re-directing \
                   to the search page. Is Firebug console on?')
      render text: "JavaScript only", status: :service_unavailable
    end
  end

  def pick_a_tab(default_tab = "tab_show_1")
    @tab = if params[:tab].present? && params[:tab] != "undefined"
             params[:tab]
           else
             default_tab
           end
  end

  def pick_a_tab_index
    @tab_index = (params[:tabIndex] || "1").to_i
  end
end
