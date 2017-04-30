module Environment
  def token
    ENV['BOT_TOKEN']
  end

  def tracker_id
    ENV['TRACKER_ID']
  end

  def webhook_path
    ENV['WEBHOOK_PATH']
  end
end
