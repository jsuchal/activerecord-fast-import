module ActiveRecord #:nodoc:
  class Base
    # Deletes all rows in table very fast, but without calling +destroy+ method
    # nor any hooks.
    def self.truncate_table
      connection.execute("TRUNCATE TABLE #{quoted_table_name}")
    end

    # Disables key updates for model table
    def self.disable_keys
      connection.execute("ALTER TABLE #{quoted_table_name} DISABLE KEYS")
    end

    # Enables key updates for model table
    def self.enable_keys
      connection.execute("ALTER TABLE #{quoted_table_name} ENABLE KEYS")
    end

    # Disables keys, yields block, enables keys.
    def self.with_keys_disabled
      disable_keys
      yield
      enable_keys
    end

    # Loads data from file(s) using MySQL native LOAD DATA INFILE query, disabling
    # key updates for even faster import speed
    #
    # ==== Parameters
    # * +files+ file(s) to import
    # * +options+ (see <tt>load_data_infile</tt>)
    def self.fast_import(files, options = {})
      files = [files] unless files.is_a? Array
      with_keys_disabled do
        load_data_infile_multiple(files, options)
      end
    end

    # Loads data from multiple files using MySQL native LOAD DATA INFILE query
    def self.load_data_infile_multiple(files, options = {})
      files.each do |file|
        load_data_infile(file, options)
      end
    end

    # Loads data from file using MySQL native LOAD DATA INFILE query
    #
    # ==== Parameters
    # * +file+ the file to import
    # * +options+ 
    def self.load_data_infile(file, options = {})
      sql = "LOAD DATA LOCAL INFILE '#{file}' "
      sql << "#{options[:insert_method]} " if options[:insert_method]
      sql << "INTO TABLE #{quoted_table_name} "
      sql << "CHARACTER SET #{options[:charset_name]} " if options[:charset_name]
      
      fields = ""
      fields << "TERMINATED BY '#{options[:fields_terminated_by]}' " if options[:fields_terminated_by]
      fields << "OPTIONALLY ENCLOSED BY '#{options[:fields_optionally_enclosed_by]}' " if options[:fields_optionally_enclosed_by]
      fields << "ESCAPED BY '#{options[:fields_escaped_by]}' " if options[:fields_escaped_by]

      sql << "FIELDS #{fields} " unless fields.empty?      
      sql << "LINES TERMINATED BY '#{options[:lines_terminated_by]}' " if options[:lines_terminated_by]
      sql << "IGNORE #{options[:ignore_lines]} LINES " if options[:ignore_lines]
      sql << "(" + options[:columns].join(', ') + ") " if options[:columns]
      if options[:mapping]
        mappings = []
        options[:mapping].each_pair do |column, mapping|
          mappings << "#{column} = #{mapping}"
        end
        sql << "SET #{mappings.join(', ')} " if mappings.size > 0
      end
      sql << ";"
      connection.execute(sql)
    end
  end
end