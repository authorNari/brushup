# -*- coding: utf-8 -*-
# ホスト名と IP アドレスのハッシュ
$hosts = {
  "lv0" => "192.168.77.10",
  "lv1" => "192.168.77.11",
  "lv2" => "192.168.77.12",

  "w101" => "192.168.77.101",
}

# ゲートウェイ
set :gateway, "210.251.121.180"

# ロードバランサ
role :lv, $hosts["lv1"], $hosts["lv2"]

# Web サーバ
role :web, $hosts["w101"]

# データベースサーバ
role :db, $hosts["lv0"], :primary => true

# ストレージサーバ
role :storage, $hosts["lv0"]

# アプリケーションサーバ
role :app, $hosts["w101"]

# 物理的な全てのサーバ
role :server, $hosts["lv1"], $hosts["lv2"], $hosts["w101"]

# deploy 対象のサーバ
server "www.takao7.net", :web

task :create_shared_files do
  run "mkdir -p #{shared_path}/system/config"
end
after "deploy:setup", "create_shared_files"

task :symlink_database_yml do
  run "ln -nsf #{shared_path}/system/config/database.yml #{release_path}/config/database.yml"
end
after "deploy:update_code", "symlink_database_yml"

# for thin.
set :thin_cfg_path, "#{shared_path}/system/config/thin.cfg"

namespace :deploy do
  task :start, :roles => :app do
    run "if [ -e #{thin_cfg_path} ]; then thin --config #{thin_cfg_path} start; fi"
  end

  task :stop, :roles => :app do
    run "if [ -e #{thin_cfg_path} ]; then thin --config #{thin_cfg_path} stop; fi"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "if [ -e #{thin_cfg_path} ]; then thin --config #{thin_cfg_path} restart; fi"
  end
end

# Local Variables:
# mode: ruby
# End:
