#
# Author:: Steven Danna <steve@opscode.com>
# Copyright:: Copyright (c) 2011 Opscode, Inc
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

provides "languages/r"

require_plugin "languages"

r = Mash.new

def run_r(r_code)
  # Using Rscript to make post processing a bit easier.
  # As a consequence, this will only work on R > 2.5 and
  # may not work on Windows
  cmd = "echo \"#{r_code}\" | Rscript --no-save --no-restore -"
  run_command(:no_status_check => true, :command => cmd)
end

status, stdout, stderr = run_command(:no_status_check => true, :command => "R --version")

if status == 0
  if stdout.split("\n")[0] =~ /version (\d+\.\d+\.\d+)/
    r[:version] = $1
  end
end

if ! r[:version].nil?

  # Get installed packages (name, version, and build-version)
  status, stdout, stderr = run_r("write.table(installed.packages()[,c(1,3,12)], col.names=FALSE, row.names=FALSE, quote=FALSE, sep=' ')")
  if status == 0
    r[:packages] = Array.new
    stdout.split("\n").each do |line|
      this_package = line.split(' ')
      r[:packages] << { "name" => this_package[0], "version" => this_package[1], "built" => this_package[2] }
    end
  end

  # Get capabilities
  status, stdout, stderr = run_r("write.table(capabilities(), col.names=FALSE, quote=FALSE, sep=' ')")
  if status == 0
    r[:capabilities] = Hash.new
    stdout.split("\n").each do |line|
      cap = line.split(' ')
      r[:capabilities][cap[0]] = (cap[1] == "TRUE")
    end
  end

  languages[:r] = r
end
