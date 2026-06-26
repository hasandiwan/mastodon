class PublicKeyExtractor
  def initialize(user)
    @user = user
  end
  
  def call
    return nil unless @user.private_key.present?
    
    begin
      GPGME::Key.import(@user.private_key)
      GPGME.export(@user.email)
    rescue GPGME::Error => e
      Rails.logger.error("Failed to extract public key: #{e.message}")
      nil
    end
  end
end
