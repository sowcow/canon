require './split/all'
require './canon'
include Html2DB

pages = WTP.pages.first(5).map { |x| [x[:html], {part: x[:part]}] }

feed_pages pages, 'test-speed.db'