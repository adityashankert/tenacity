module Tenacity
  # Tenacity relationships on DataMapper objects require that certain columns
  # exist on the associated table, and that join tables exist for one-to-many
  # relationships.  Take the following class for example:
  #
  #   class Car
  #     include DataMapper::Resource
  #     include Tenacity
  #
  #     property :id, Serial
  #     property :driver_id, String
  #
  #     t_has_many    :wheels
  #     t_has_one     :dashboard
  #     t_belongs_to  :driver
  #   end
  #
  #
  # == t_belongs_to
  #
  # The +t_belongs_to+ association requires that a property exist in the table
  # to hold the id of the assoicated object.
  #
  #
  # == t_has_one
  #
  # The +t_has_one+ association requires no special column in the table, since
  # the associated object holds the foreign key.
  #
  #
  # == t_has_many
  #
  # The +t_has_many+ association requires that a join table exist to store the
  # associations.  The name of the join table follows ActiveRecord conventions.
  # The name of the join table in this example would be cars_wheels, since cars
  # comes before wheels when shorted alphabetically.
  #
  #   create_table :car_wheels do
  #     column :car_id, Integer
  #     column :wheel_id, String
  #   end
  #
  module DataMapper

    def self.setup(model)
      require 'datamapper'
      if model.included_modules.include?(::DataMapper::Resource)
        model.send :include, DataMapper::InstanceMethods
        model.extend DataMapper::ClassMethods
      end
    rescue LoadError
      # DataMapper not available
    end

    module ClassMethods #:nodoc:
      def _t_find(id)
        get(id)
      end

      def _t_find_bulk(ids)
        return [] if ids.nil? || ids.empty?
        all(:id => ids)
      end

      def _t_find_first_by_associate(property, id)
        first(property => id.to_s)
      end

      def _t_find_all_by_associate(property, id)
        all(property => id.to_s)
      end

      def _t_initialize_has_many_association(association)
        after :save do |record|
          record.class._t_save_associates(record, association)
        end
      end

      def _t_initialize_belongs_to_association(association)
        before :save do |record|
          record.class._t_stringify_belongs_to_value(record, association)
        end
      end

      def _t_delete(ids, run_callbacks=true)
        objects = _t_find_bulk(ids)
        if run_callbacks
          objects.each { |object| object.destroy }
        else
          objects.each { |object| object.destroy! }
        end
      end
    end

    module InstanceMethods #:nodoc:
      def _t_reload
        reload
      end

      def _t_clear_associates(association)
        self.repository.adapter.execute("delete from #{association.join_table} where #{association.association_key} = #{self.id}")
      end

      def _t_associate_many(association, associate_ids)
        self.transaction do
          _t_clear_associates(association)
          associate_ids.each do |associate_id|
            self.repository.adapter.execute("insert into #{association.join_table} (#{association.association_key}, #{association.association_foreign_key}) values (#{self.id}, '#{associate_id}')")
          end
        end
      end

      def _t_get_associate_ids(association)
        return [] if self.id.nil?
        self.repository.adapter.select("select #{association.association_foreign_key} from #{association.join_table} where #{association.association_key} = #{self.id}")
      end
    end

  end
end