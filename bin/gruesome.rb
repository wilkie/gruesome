#!/usr/bin/env ruby

$: << File.dirname(__FILE__) + '/../lib'

require 'gruesome'
require 'gruesome/cli'

Gruesome::CLI.run

