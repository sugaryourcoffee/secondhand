class StaticPagesController < ApplicationController
  skip_before_filter :authorize

  def home
    if params[:set_locale]
      redirect_to root_path(locale: params[:set_locale])
    else
      @news = News.
        where("released = ? and promote_to_frontpage = ?", true, true).last
      @event = Event.find_by(active: true)
    end
  end

  def help
  end

  def about
  end

  def privacy_statement
    respond_to do |format|
      format.pdf do
        send_file "public/privacy-statement-de.pdf", content_type: Mime::PDF
      end
    end
  end

  def contact
    @message = Message.new(message_params) # params[:message])
  end

  def message
    @message = Message.new(message_params) # params[:message])
    unless @message.valid?
      render 'contact'
    else
      UserMailer.user_request(@message).deliver_now
      redirect_to root_path, notice: I18n.t('.contact_success') 
    end
  end

  private

    def message_params
      return nil unless params[:message]
      params.require(:message).permit(:subject, :category, :message, 
                                      :email, :copy_me)
    end
end
