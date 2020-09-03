class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception  # from v4, needed in v6?
  STANDARD_MODE = "standard_mode"
  TRM = TAXONOMIC_REVIEW_MODE = "taxonomic_review_mode"
  before_action :set_debug,
                :start_timer,
                :check_system_broadcast,
                :authenticate,
                :check_authorization,
                :set_mode
  around_action :user_tagged_logging

  rescue_from ActionController::InvalidAuthenticityToken, with: :show_login_page
  rescue_from CanCan::AccessDenied do |_exception|
    logger.error("Access Denied")
    head :forbidden
  end

  def show_login_page
    logger.info("Show login page - invalid authenticity token.")
    if request.format == "text/javascript"
      logger.info('JavaScript request with invalid authenticity token\
                  - expired session?')
    else
      redirect_to start_sign_in_path, notice: "Please try again."
    end
  end

  protected

  def check_authorization
    pseudo_action = if params[:tab].present?
                      params[:tab]
                    else
                      params[:action]
                    end
    logger.info("check_authorization: pseudo_action: #{pseudo_action}")
    authorize!(params[:controller], pseudo_action)
  end

  def authenticate
    if session[:username].blank?
      ask_user_to_sign_in
    else
      continue_user_session
    end
  end

  # Continue in current mode from session
  # Default to standard mode if session not set
  # Force reviewers into review mode regardless of session
  # Set booleans
  def set_mode
    @mode = session[:mode] ||= STANDARD_MODE
    @mode = session[:mode] = TRM unless can? 'standard_mode', 'use'
    @standard_mode = @mode == STANDARD_MODE
    @taxonomic_review_mode = !@standard_mode
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
    unless request.format == "text/javascript" || request.format == "application/json"
      logger.error("Rejecting a non-JavaScript request (format: #{request.format}) Is Firebug console on?")
      return false
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

  def empty_search
    @search = Search::Empty.new(params)
  end

  def set_debug
    @debug = false
  end

  def start_timer
    @start_time = Time.now
  end

  def check_system_broadcast
    @system_broadcast = ""
    file_path = Rails.configuration.try('path_to_broadcast_file')||''
    if File.exist?(file_path)
      logger.debug("System broadcast file exists at #{file_path}")
      file = File.open(file_path, "r")
      @system_broadcast = file.readline unless file.eof?
    end
  rescue => e
    logger.error("Problem with system broadcast.")
    logger.error(e.to_s)
  end

  def user_tagged_logging
    logger.tagged(username || 'Anonymous') do
      yield
    end
  end
end
