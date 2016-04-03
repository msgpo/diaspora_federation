module DiasporaFederation
  module Federation
    module Receiver
      # common functionality for receivers
      class AbstractReceiver
        include Logging

        # create a new receiver
        # @param [MagicEnvelope] magic_envelope the received magic envelope
        # @param [Object] recipient_id the identifier of the recipient of a private message
        def initialize(magic_envelope, recipient_id=nil)
          @entity = magic_envelope.payload
          @sender = magic_envelope.sender
          @recipient_id = recipient_id
        end

        # validate and receive the entity
        def receive
          validate_and_receive
        rescue => e
          logger.error "failed to receive #{entity.class}#{":#{entity.guid}" if entity.respond_to?(:guid)}"
          raise e
        end

        private

        attr_reader :entity, :sender, :recipient_id

        def validate_and_receive
          validate
          DiasporaFederation.callbacks.trigger(:receive_entity, entity, recipient_id)
          logger.info "successfully received #{entity.class}#{":#{entity.guid}" if entity.respond_to?(:guid)}" \
                      "from person #{sender}#{" for #{recipient_id}" if recipient_id}"
        end

        def validate
          raise InvalidSender, "invalid sender: #{sender}" unless sender_valid?
        end

        def sender_valid?
          if entity.respond_to?(:sender_valid?)
            entity.sender_valid?(sender)
          else
            sender == entity.author
          end
        end
      end
    end
  end
end
