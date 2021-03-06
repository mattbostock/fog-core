module Fog
  module Compute
    def self.[](provider)
      new(:provider => provider)
    end

    def self.new(attributes)
      attributes = attributes.dup # prevent delete from having side effects
      provider = attributes.delete(:provider).to_s.downcase.to_sym

      case provider
      when :gogrid
        require "fog/go_grid/compute"
        Fog::Compute::GoGrid.new(attributes)
      when :hp
        version = attributes.delete(:version)
        version = version.to_s.downcase.to_sym unless version.nil?
        if version == :v2
          require "fog/hp/compute_v2"
          Fog::Compute::HPV2.new(attributes)
        else
          Fog::Logger.deprecation "HP Cloud Compute V1 service will be soon deprecated. Please use `:version => v2` attribute to use HP Cloud Compute V2 service."
          require "fog/hp/compute"
          Fog::Compute::HP.new(attributes)
        end
      when :new_servers
        require "fog/bare_metal_cloud/compute"
        Fog::Logger.deprecation "`new_servers` is deprecated. Please use `bare_metal_cloud` instead."
        Fog::Compute::BareMetalCloud.new(attributes)
      when :baremetalcloud
        require "fog/bare_metal_cloud/compute"
        Fog::Compute::BareMetalCloud.new(attributes)
      when :stormondemand
        require "fog/storm_on_demand/compute"
        Fog::Compute::StormOnDemand.new(attributes)
      when :vcloud
        require "fog/vcloud/compute"
        Fog::Vcloud::Compute.new(attributes)
      when :vclouddirector
        require "fog/vcloud_director/compute"
        Fog::Compute::VcloudDirector.new(attributes)
      else
        if providers.include?(provider)
          require "fog/#{provider}/compute"
          begin
            Fog::Compute.const_get(Fog.providers[provider])
          rescue
            Fog.const_get(Fog.providers[provider])::Compute
          end.new(attributes)
        else
          raise ArgumentError, "#{provider} is not a recognized compute provider"
        end
      end
    end

    def self.providers
      Fog.services[:compute]
    end

    def self.servers
      servers = []
      providers.each do |provider|
        begin
          servers.concat(self[provider].servers)
        rescue # ignore any missing credentials/etc
        end
      end
      servers
    end
  end
end
