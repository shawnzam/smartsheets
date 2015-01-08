Rails.application.config.middleware.use OmniAuth::Builder do
    provider :smartsheet, '', nil, :smartsheet_secret => '', :scope => 'READ_SHEETS'
end