vim-addon-errorformats
======================

Usage:
    :Errorformat ocaml_simple ruby

Why:
- less complicated quoting
- Allow to use multiple error formats at the same time.
  This is useful if you run rake (written in Ruby) to compile ocaml.

error format names (=keys):

  rtp_*: extracted from compiler/* files
  rest: provided in efms/ directory

You can register your own sources

TODO: Get rid of funcref# in all of my Vim related plugins and replace by viml lambdas
