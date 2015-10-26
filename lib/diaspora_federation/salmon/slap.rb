module DiasporaFederation
  module Salmon
    # +Slap+ provides class methods to create unencrypted Slap XML from payload
    # data and parse incoming XML into a Slap instance.
    #
    # A Diaspora*-flavored magic-enveloped XML message looks like the following:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
    #     <header>
    #       <author_id>{author}</author_id>
    #     </header>
    #     {magic_envelope}
    #   </diaspora>
    #
    # @example Generating a Salmon Slap
    #   author_id = "author@pod.example.tld"
    #   author_privkey = however_you_retrieve_the_authors_private_key(author_id)
    #   entity = YourEntity.new(attr: "val")
    #
    #   slap_xml = Slap.generate_xml(author_id, author_privkey, entity)
    #
    # @example Parsing a Salmon Slap
    #   slap = Slap.from_xml(slap_xml)
    #   author_pubkey = however_you_retrieve_the_authors_public_key(slap.author_id)
    #
    #   entity = slap.entity(author_pubkey)
    #
    class Slap
      attr_accessor :author_id, :magic_envelope, :cipher_params

      # Namespaces
      NS = {d: Salmon::XMLNS, me: MagicEnvelope::XMLNS}

      # Returns new instance of the Entity that is contained within the XML of
      # this Slap.
      #
      # The first time this is called, a public key has to be specified to verify
      # the Magic Envelope signature. On repeated calls, the key may be omitted.
      #
      # @see MagicEnvelope.unenvelop
      #
      # @param [OpenSSL::PKey::RSA] pubkey public key for validating the signature
      # @return [Entity] entity instance from the XML
      # @raise [ArgumentError] if the public key is of the wrong type
      def entity(pubkey=nil)
        return @entity unless @entity.nil?

        raise ArgumentError unless pubkey.instance_of?(OpenSSL::PKey::RSA)
        @entity = MagicEnvelope.unenvelop(magic_envelope, pubkey, @cipher_params)
        @entity
      end

      # Parses an unencrypted Salmon XML string and returns a new instance of
      # {Slap} populated with the XML data.
      #
      # @param [String] slap_xml Salmon XML
      # @return [Slap] new Slap instance
      # @raise [ArgumentError] if the argument is not a String
      # @raise [MissingAuthor] if the +author_id+ element is missing from the XML
      # @raise [MissingMagicEnvelope] if the +me:env+ element is missing from the XML
      def self.from_xml(slap_xml)
        raise ArgumentError unless slap_xml.instance_of?(String)
        doc = Nokogiri::XML::Document.parse(slap_xml)

        Slap.new.tap do |slap|
          author_elem = doc.at_xpath("d:diaspora/d:header/d:author_id", Slap::NS)
          raise MissingAuthor if author_elem.nil? || author_elem.content.empty?
          slap.author_id = author_elem.content

          slap.add_magic_env_from_doc(doc)
        end
      end

      # Creates an unencrypted Salmon Slap and returns the XML string.
      #
      # @param [String] author_id Diaspora* handle of the author
      # @param [OpenSSL::PKey::RSA] pkey sender private_key for signing the magic envelope
      # @param [Entity] entity payload
      # @return [String] Salmon XML string
      # @raise [ArgumentError] if any of the arguments is not the correct type
      def self.generate_xml(author_id, pkey, entity)
        raise ArgumentError unless author_id.instance_of?(String) &&
                                   pkey.instance_of?(OpenSSL::PKey::RSA) &&
                                   entity.is_a?(Entity)

        build_xml do |xml|
          xml.header {
            xml.author_id(author_id)
          }

          MagicEnvelope.new(pkey, entity).envelop(xml)
        end
      end

      def self.build_xml
        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.diaspora("xmlns" => Salmon::XMLNS, "xmlns:me" => MagicEnvelope::XMLNS) {
            yield xml
          }
        end
        builder.to_xml
      end

      def add_magic_env_from_doc(doc)
        @magic_envelope = doc.at_xpath("d:diaspora/me:env", Slap::NS).tap do |env|
          raise MissingMagicEnvelope if env.nil?
        end
      end
    end
  end
end
