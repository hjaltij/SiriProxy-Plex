# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-plex"
  s.version     = "0.0.3" 
  s.authors     = ["hjaltij"]
  s.email       = ["hjalti@hjaltijakobsson.com"]
  s.homepage    = "http://www.hjaltijakobsson.com"
  s.summary     = %q{An Remote for Plex}
  s.description = %q{This plugin lets you control Plex Media Center (www.plexapp.com) from Siri}

  s.rubyforge_project = "siriplex"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
