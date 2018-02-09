require_relative "output"
require "yaml"

class Infrastructure < Output
  def to_h
    @infrastructure ||= {
      base_dir: opts.instance_name,
      bind: "#{opts.apache_app_host_priv_ip}:#{opts.apache_port}",
      redis: opts.redis.each_with_index.map{|v, i| [i,v]}.to_h,
      db: {
        adapter: (db_adapter = "mysql2"),
        username: opts.db_user_name,
        password: opts.db_user_password,
        host: opts.target_db_hostname,
        port: (db_port = 3306),
        database: opts.db_name,
        url: "#{db_adapter}://#{opts.db_user_name}:#{opts.db_user_password}@#{opts.target_db_hostname}:#{db_port}/#{opts.db_name}"
      }
    }
  end

  def keys
    [
      :instance_name,
      :apache_app_host_priv_ip,
      :apache_port,
      :redis,
      :db_adapter,
      :db_user_name,
      :db_user_password,
      :target_db_hostname,
      :db_name
    ]
  end

  def to_s
    YAML.dump(to_h)
  end
end

