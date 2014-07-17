require 'openssl'

module RESTinPeace
  class SSLConfigCreator
    def initialize(config, verify = :peer)
      @config = config
      @verify = verify
    end

    def faraday_options
      {client_cert: client_cert, client_key: client_key, ca_file: ca_cert_path, verify_mode: verify_mode}
    end

    def client_cert
      OpenSSL::X509::Certificate.new(open_file(client_cert_path))
    end

    def client_cert_path
      path(@config[:client_cert])
    end

    def client_key
      OpenSSL::PKey::RSA.new(open_file(client_key_path))
    end

    def client_key_path
      path(@config[:client_key])
    end

    def ca_cert_path
      path(@config[:ca_chain])
    end

    def verify_mode
      case @verify
      when :peer
        OpenSSL::SSL::VERIFY_PEER
      else
        raise "Unknown verify variant '#{@verify}'"
      end
    end

    private

    def open_file(file)
      File.open(file)
    end

    def path(file)
      File.join(file)
    end
  end
end
