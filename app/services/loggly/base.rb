class Loggly::Base
  SERVICE_NAME = ''

  def initialize(**opts)
    #   @booking = opts[:booking]
    #   @api_setting = opts[:api_setting]
    #   @country_code = booking.country_code || api_setting.requestor.country_code
    post_initialize(opts)
  end

  def post_initialize(_opts); end

  attr_reader :booking, :api_setting, :country_code

  def handle_failure(msg, params)
    #   Raven.send_event(
    #     message: "[Webhook][SFTP] Could not perform #{self.class::SERVICE_NAME}",
    #     extra: { error: msg, params: params }
    #   )
  end
end
