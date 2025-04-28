module RespondWithTurbo
  extend ActiveSupport::Concern

  def respond_to_action(success:, redirect_path:, fallback_partial:, turbo_stream_action: nil, target_dom_id: nil, locals: {})
    respond_to do |format|
      if success
        format.html { redirect_to redirect_path, notice: "Success!" }
        format.turbo_stream do
          if turbo_stream_action && target_dom_id
            render turbo_stream: turbo_stream.send(turbo_stream_action, target_dom_id, partial: fallback_partial, locals: locals)
          else
            head :ok
          end
        end
      else
        format.html { render fallback_partial, status: :unprocessable_entity, locals: locals }
        format.turbo_stream { render fallback_partial, status: :unprocessable_entity, locals: locals }
      end
    end
  end
end
