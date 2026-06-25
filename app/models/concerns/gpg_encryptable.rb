require 'open3'

module GpgEncryptable
  extend ActiveSupport::Concern

  class_methods do
    def gpg_encrypt(*attributes)
      attributes.each do |attr|
        # Create virtual attribute getter/setter (e.g., model.notes)
        attr_accessor attr

        # Encrypt before saving to database
        before_save do
          raw_value = send(attr)
          if raw_value.present?
            self.send("encrypted_#{attr}=", encrypt_data(raw_value))
          end
        end

        # Decrypt after pulling from database
        after_find do
          enc_value = send("encrypted_#{attr}")
          if enc_value.present?
            self.send("#{attr}=", decrypt_data(enc_value))
          end
        end
      end
    end
  end

  private

  def encrypt_data(data)
    recipient = Rails.application.credentials.dig(:gpg, :recipient_email)
    cmd = "gpg --batch --yes --trust-model always -ear #{recipient}"
    
    stdout, stderr, status = Open3.capture3(cmd, stdin_data: data.to_s)
    raise "GPG Encryption failed: #{stderr}" unless status.success?
    
    stdout
  end

  def decrypt_data(encrypted_data)
    passphrase = Rails.application.credentials.dig(:gpg, :passphrase)
    cmd = "gpg --batch --passphrase #{passphrase} --decrypt"
    
    stdout, stderr, status = Open3.capture3(cmd, stdin_data: encrypted_data)
    raise "GPG Decryption failed: #{stderr}" unless status.success?
    
    stdout
  end
end
