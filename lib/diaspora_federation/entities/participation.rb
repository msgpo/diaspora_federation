module DiasporaFederation
  module Entities
    # participation is sent to subscribe a user on updates for some post
    #
    # @see Validators::Participation
    class Participation < Entity
      # @!attribute [r] guid
      #   @see HCard#guid
      #   @return [String] guid
      property :guid

      # @!attribute [r] target_type
      #   a string describing a type of the target to subscribe on
      #   @return [String] target type
      property :target_type

      include Relayable

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who subscribes on a post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end