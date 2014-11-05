require 'active_record/connection_adapters/abstract/transaction'
module ActiveRecord
  module ConnectionAdapters
    class SavepointTransaction < OpenTransaction
      def perform_commit_with_transactional_fixtures
        commit_records if number == 1
        perform_commit_without_transactional_fixtures
      end

      alias_method_chain :perform_commit, :transactional_fixtures
    end
  end
end
