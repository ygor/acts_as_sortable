require 'active_record'
require 'active_support/core_ext'

module ActsAsSortable #:nodoc:
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_sortable(*sortables)
      class_attribute :sortables
      self.sortables = (sortables || []).map(&:to_sym)
      
      scope :sorted, lambda {|*sorts|
        if sorts.length == 1
          sorts = sorts.first if sorts.first.first.is_a?(Array)
        else
          sorts = sorts.in_groups_of(2) unless sorts.first.is_a?(Array)
        end
        sorts.inject(self.scoped) do |scope, sort|
          if !sort.empty? && (sortables.empty? || sortables.include?(sort.first.to_sym))
            if sort.first.to_s.include?('.')
              assoc, column = sort.first.to_s.split('.')
              association_reflection = reflect_on_association(assoc.to_sym)
              association_reflection ? scope.joins(assoc.to_sym).order("`#{association_reflection.table_name}`.`#{column}` #{sort.last}") : scope
            elsif scope.respond_to?(sort.first.to_sym) && ![:name, :id].include?(sort.first.to_sym)
              scope.send(sort.first.to_sym, sort.last.to_s)
            else
              scope.order("`#{self.table_name}`.`#{sort.first}` #{sort.last}")
            end
          else
            scope
          end
        end
      }
    end
  end
end

ActiveRecord::Base.send :include, ActsAsSortable