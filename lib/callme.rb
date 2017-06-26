require 'ext/vendored_activesupport'
require 'callme/version'

require 'callme/const_loaders/native'
require 'callme/args_validator'
require 'callme/errors'
require 'callme/inject'
require 'callme/container'

require 'callme/dep_metadata'
require 'callme/deps_metadata_storage'

require 'callme/scopes'
require 'callme/scopes/singleton_scope'
require 'callme/scopes/prototype_scope'
require 'callme/scopes/request_scope'

require 'callme/dep_factory'
