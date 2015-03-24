module Service
  def self.build(application, data)
    if data && data['service']
      data['service'].map do |name, options|
        require "service/#{name.downcase}"

        const_get(
          constants.detect { |c| c.to_s.downcase == name.downcase }
        ).new(application: application, data: options)
      end
    else
      []
    end
  end
end
