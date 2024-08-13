# frozen_string_literal: true

require 'graphql-hive/sampler/sampling_context'

module GraphQL
  class Hive
    module Sampler
      # Dynamic sampling for operations reporting
      class DynamicSampler
        include GraphQL::Hive::Sampler::SamplingContext

        def initialize(client_sampler, at_least_once_sampling)
          @sampler = client_sampler
          @tracked_operations = {}
          @key_generator = (at_least_once_sampling.keygen || DEFAULT_SAMPLE_KEY if at_least_once_sampling.enabled)
        end

        def sample?(operation)
          sample_context = get_sample_context(operation)

          if @key_generator
            operation_key = @key_generator.call(sample_context)
            unless @tracked_operations.key?(operation_key)
              @tracked_operations[operation_key] = true
              return true
            end
          end

          SecureRandom.random_number <= @sampler.sample?(sample_context)
        end
      end
    end
  end
end
