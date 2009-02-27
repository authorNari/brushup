module Brushup
end

require_dependency "brushup/formatting"
require_dependency "brushup/formatting/rdformatter"
require_dependency "brushup/formatting/textileformatter"

Brushup::Formatting.register(:default, Brushup::Formatting::DefaultFormatter)
Brushup::Formatting.register(:rd, Brushup::Formatting::RdFormatter)
Brushup::Formatting.register(:textile, Brushup::Formatting::TextileFormatter)
