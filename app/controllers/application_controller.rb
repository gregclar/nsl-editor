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

  protected

  def show_login_page
    logger.error("Invalid Authenticity Token.")
    if request.format == "text/javascript"
      logger.error('JavaScript request with invalid authenticity token\
                  - expired session?')
      render :js => "alert('Your session may have expired. Please reload the whole page before continuing.');"
    else
      redirect_to start_sign_in_path, notice: "Please try again."
    end
  end

  def check_authorization
    controller = params[:controller]
    action = params[:tab].present? ? params[:tab] : params[:action]
    authorize!(controller, action)
  rescue CanCan::AccessDenied
    details = "is unauthorized for: #{controller} #{action}"
    logger.error("User #{@current_user.username} #{details}")
    raise
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
    logger.info("1. set_mode: session[:mode]: #{session[:mode]}; start")
    @mode = session[:mode] ||= STANDARD_MODE
    logger.info("2. set_mode: session[:mode]: #{session[:mode]}; default to standard mode")
    @mode = session[:mode] = TRM unless can? 'standard_mode', 'use'
    logger.info("3. set_mode: session[:mode]: #{session[:mode]}; fall back to TRM mode if cannot use standard mode")
    session[:mode] = @mode
    @standard_mode = @mode == STANDARD_MODE
    @taxonomic_review_mode = !@standard_mode
  end

  def set_mode_new_cannot_change_mode
    logger.info("set_mode - controller: #{params[:controller]}, action: #{params[:action]}")
    return if params[:controller] = 'mode' && params[:action] = 'toggle_mode'

    logger.debug("best mode: #{best_mode}")
    logger.info("1. set_mode: session[:mode]: #{session[:mode]}; start")
    @mode = session[:mode] ||= best_mode
    logger.debug("2. @mode: #{@mode}")
    @mode = best_mode unless can? session[:mode], 'use'
    logger.debug("3. @mode: #{@mode}")
    session[:mode] = @mode
    logger.debug("4. mode: session[:mode]: #{session[:mode]}")
    @standard_mode = @mode == STANDARD_MODE
    @taxonomic_review_mode = !@standard_mode
  end

  private

  def best_mode
    if can? 'standard_mode', 'use'
      STANDARD_MODE
    else
      TRM
    end
  end

  def ask_user_to_sign_in
    session[:url_after_sign_in] = request.url
    respond_to do |format|
      format.html {redirect_to start_sign_in_url, notice: "Please sign in."}
      format.json {render partial: "layouts/no_session.js"}
      format.js { js_render }
    end
  end

  def js_render
    if params[:extras_id] =~ /search-examples/ || params[:extras_id] =~ /search-help/
      logger.error("Handling unauth request for search-helpd or search-examples")
      render html: "<div class='embedded-notice'><b>Your session may have expired.  Please reload the whole page before continuing.</b></div><script>alert('login...';) </script>".html_safe
    elsif params[:tab].blank? 
      logger.error("Handling unauth request for a non-tab")
      render :js => "alert('Your session may have expired. Please reload the whole page before continuing.');", layout: true
    else
      logger.error("Handling unauth request for the rest, including tabs")
      render html: "<div class='embedded-notice'><b>Your session may have expired.  Please reload the whole page before continuing.</b></div><script>alert('login...';) </script>".html_safe
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
