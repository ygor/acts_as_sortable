require 'active_record'
require 'active_support/core_ext'

module ActsAsSortable #:nodoc:
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_sortable(*sortables)
      class_attribute :sortables
      self.sortables = (sortables || []).map(&:to_sym)
      
      scope :sorted, lambda {|*sorts|
        sorts = sorts[0] if !sorts.empty? && sorts[0].is_a?(Array)
        sorts.reject(&:nil?).inject(self.scoped) do |scope, sort|
          unless sort.empty?
            if sortables.empty? || sortables.include?(sort[:key].to_sym)
              if sort[:key].to_s.include?('.')
                assoc, column = sort[:key].to_s.split('.')
                reflect_on_association(assoc.to_sym) ? scope.joins(assoc.to_sym).order("`#{assoc.to_s.pluralize}`.`#{column}` #{sort[:dir]}") : scope
              elsif scope.respond_to?(sort[:key].to_sym) && ![:name, :id].include?(sort[:key].to_sym)
                scope.send(sort[:key].to_sym, sort[:dir].to_s)
              else
                scope.order("`#{self.name.downcase.pluralize}`.`#{sort[:key]}` #{sort[:dir]}")
              end
            else
              scope
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