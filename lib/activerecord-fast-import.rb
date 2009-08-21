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

    # Loads data from file using MySQL native LOAD DATA INFILE query, disabling
    # key updates for even faster import speed
    #
    # ==== Parameters
    # * +file+ file(s) to import
    # * +options+ (see <tt>load_data_infile</tt>)
    def self.fast_import(files, options = {})
      files = [files] unless files.is_a? Array
      enable_keys
      files.each {|file| load_data_infile(file, options)}
      disable_keys
    end

    # Loads data from file using MySQL native LOAD DATA INFILE query
    #
    # ==== Parameters
    # * +file+ the file to import
    # * +options+ 
    def self.load_data_infile(file, options = {})
      sql = "LOAD DATA LOCAL INFILE '#{file}' INTO TABLE #{quoted_table_name} "
      sql << "FIELDS TERMINATED BY '#{options[:fields_terminated_by]}' " if options[:fields_terminated_by]
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