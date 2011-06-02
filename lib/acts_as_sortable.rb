require 'active_record'

module ActsAsSortable #:nodoc:
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_sortable(*sortables)
      class_inheritable_array :sortables
      self.sortables = sortables.map(&:to_sym)
      extend SingletonMethods

      self.send(:relation).class_eval do
        extend SingletonMethods
        def sortables
          @klass.sortables
        end
      end
    end
  end

  module SingletonMethods
    def sorted(*sorts)
      if sorts.size.even?
        sorts.in_groups_of(2).inject(self) do |scope, sort|
          key, dir = sort
          if sortables.empty? || sortables.include?(key.to_sym)
            if key.to_s.include?('.')
              assoc, column = key.to_s.split('.')
              if reflect_on_association(assoc.to_sym)
                scope.joins(assoc.to_sym).order("`#{assoc.to_s.pluralize}`.`#{column}` #{dir}")
              else
                scope
              end
            elsif scope.respond_to?(key.to_sym) && ![:name, :id].include?(key.to_sym)
              scope.send(key.to_sym, dir.to_s)
            else
              scope.order("`#{self.name.downcase.pluralize}`.`#{key}` #{dir}")
            end
          else
            scope
          end
        end
      else
        self
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsSortable