class ModeController < ApplicationController
  def toggle_mode
    logger.debug('ModeController#toggle_mode start')
    logger.debug("toggle_mode @mode: #{@mode}")
    logger.debug("toggle_mode ApplicationController::STANDARD_MODE: #{ApplicationController::STANDARD_MODE}")
    if @mode == ApplicationController::STANDARD_MODE.to_s
      logger.debug('toggle_mode changing to taxonomic review mode')
      @mode = session[:mode]  = ApplicationController::TAXONOMIC_REVIEW_MODE
    else
      logger.debug('toggle_mode changing to standard mode')
      @mode = session[:mode]  = ApplicationController::STANDARD_MODE
    end
    redirect_to controller: "search", action: "search"
  end
end
