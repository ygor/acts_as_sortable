require 'active_record'

module ActsAsSortable #:nodoc:
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_sortable(*sortables)
      class_inheritable_array :sortables
      self.sortables = sortables.map(&:to_sym)
      
      scope :sorted, lambda {|*sorts|
        sorts.in_groups_of(2).inject(self.scoped) do |scope, sort|
          key, dir = sort
          if sortables.empty? || sortables.include?(key.to_sym)
            if key.to_s.include?('.')
              assoc, column = key.to_s.split('.')
              reflect_on_association(assoc.to_sym) ? scope.joins(assoc.to_sym).order("`#{assoc.to_s.pluralize}`.`#{column}` #{dir}") : scope
            elsif scope.respond_to?(key.to_sym) && ![:name, :id].include?(key.to_sym)
              scope.send(key.to_sym, dir.to_s)
            else
              scope.order("`#{self.name.downcase.pluralize}`.`#{key}` #{dir}")
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