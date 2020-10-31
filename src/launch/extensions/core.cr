require "./*"
require "../support/locale_formats"

# We are patching the String class and Number struct to extend the predicates
# available. This will allow to add friendlier methods for validation cases.

# :nodoc:
class String
  include Launch::Extensions::String
end

# :nodoc:
abstract struct Number
  include Launch::Extensions::Number
end

class HTTP::Server::Context
  include Launch::Extensions::HTTPServerContext
end
