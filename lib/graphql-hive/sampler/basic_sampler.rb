# frozen_string_literal: true

require 'graphql-hive/sampler/sampling_context'

module GraphQL
  class Hive
    module Sampler
      # Basic sampling for operations reporting
      class BasicSampler
        include GraphQL::Hive::Sampler::SamplingContext

        def initialize(client_sample_rate = 1, at_least_once_sampling)
          @sample_rate = client_sample_rate
          @tracked_operations = {}
          @key_generator = (at_least_once_sampling.keygen || DEFAULT_SAMPLE_KEY if at_least_once_sampling[:enabled])
        end

        def sample?(operation)
          if @key_generator
            sample_context = get_sample_context(operation)
            operation_key = @key_generator.call(sample_context)

            unless @tracked_operations.key?(operation_key)
              @tracked_operations[operation_key] = true
              return true
            end
          end

          SecureRandom.random_number <= @sample_rate
        end
      end
    end
  end
end
