#!/usr/bin/env sh

ruby -I lib test/test_util.rb

ruby -I lib test/test_geometry.rb

ruby -I lib test/test_grid.rb