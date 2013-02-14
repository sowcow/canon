require_relative 'canon'
require_relative 'lib/selector'
require_relative 'lib/file_works'
require_relative 'lib/html'
include HTML

require 'moneta'
require 'ruby-progressbar'

# previous_of_a_kind is adding nil only once
# missing nils of attributes??? test them?
# can attribute name collide with :text, :name etc ?
=begin
MAJJHIMA  7473330
DIGHA     12333718
ANGUTTARA 48169606
SAMYUTTA  53233954
=end
END{

  def time_of
    t = Time.now
    yield
    Time.now - t
  end

  def test_storages
    pages = WTP.all_pages.sample(25)
    rm path = 'test-storages/'
    mkpath path

    storages = [ # HashFile.size < LevelDB.size, consistency?
      [:HashFile,     {dir: path+'File.db'}],
      [:LevelDB,  {dir:  path+'LevelDB.db'}],
      [:TDB, {file: path+'TDB.db'}]
      # lib*-dev to install      
    ]
    # [:Daybreak, {file: path+'Daybreak.db'}], # too large   # [:GDBM, {file: path+'GDBM.db'}],        # crashes + large    # [:PStore,   {file: path+'PStore.db'}],  # slow    # [:Sqlite,   {file: path+'Sqlite.db'}], # slow

    htmls = pages.map { |x| x[:html] }
    storages.each { |storage| puts storage[0]; feed htmls, Moneta.new(*storage) }
    # puts storages.map { |storage| puts [storage[0], time_of{ feed htmls, Moneta.new(*storage) }] }
    # my_feed pages
  end

  def my_feed pages, db
    rm db
    htmls = pages.map { |x| x[:html] }
    feed htmls, Moneta.new(:LevelDB, :dir => db)
  end

  def feed_all # > 4 days
    my_feed WTP.all_pages, 'output/all_pages'
  end
  def feed_digha # 05:52:00?
    my_feed WTP.get.only!(DIGHA).all_pages, 'output/digha'
  end
  def feed_majhima # 00:20:10/01:01:04/01:00:41
    my_feed WTP.get.only!(MAJJHIMA).all_pages, 'output/majjhima'
  end
  def feed_4_nikayas # unknown
    my_feed WTP.get.only!(FOUR_NIKAYAS).all_pages, 'output/four_nikayas'
  end  

  feed_majhima
}
# 245.8s - only split - all
# HashFile: 4285.0s 9.8Mb

# redefine them and return nil to filter crappy classes or ids with numeration
class Selector
  # def klass; node[:class] =~ /\d/ ? (warn node[:class];nil) : node[:class] end
  # ENDH3  not so often! #/\d/
  # OK_CLASS
  # def klass; node[:class] =~ /\d/ ? (warn node[:class];nil) : node[:class] end

  # YES - handy work! 
  ODD_ID = /^([ph]_\d.*\d)|(block-tipitaka-\d+)|(block-user-\d+)|(block-block-\d+)$/
  # def id; node[:id] =~ ODD_ID ? nil : (node[:id] =~ /\d/ ? (warn(node[:id]);node[:id]) : node[:id]) end
  # faster?:
  def id; (given = node[:id]) =~ ODD_ID ? nil : given end
end

def selector node; Selector[node].to_s end

def show_selectors htmls, output, count = 50
  all_selectors = htmls.sample(count).map do |html|
    split(html).map { |node| selector(node) }
  end.flatten.uniq.sort_by &:size
  File.write output, all_selectors.join(?\n)
end

def feed htmls, store

  progress = ProgressBar.create format: '%a %e [%B] %p%%', total: htmls.count

  htmls.each do |html|

    split(html).each do |node|
      selector = selector(node)

      if store.key? selector
        # first_of_a_kind = false
        # previous_of_a_kind = store[selector].keys.count
        previous_of_a_kind = 1
      else
        # first_of_a_kind = true
        previous_of_a_kind = 0 # first of a kind selector

        store[selector] = {}
        store[:tables] = [] unless store.key? :tables # once a feed...
        store[:tables] = store[:tables] << selector # a = a << b
      end

      attributes = store[selector]
      node_attributes = attributes(node)
      missing = (attributes.keys - node_attributes.map(&:first)).map { |attr| [attr, nil] }

      # puts 'xz:',attributes.keys
      # p 'xz:'+(attributes.keys - node_attributes.map(&:first)).to_s
      # p 'm: '+ missing.to_s
      # p 'a: '+ node_attributes.to_s
      # p '+: '+ (node_attributes + missing).to_s
      # exit if [*1..10].sample == 1
      
      (node_attributes + missing).each do |attribute,value| # << tag_name, text, to_html !

        # attributes[attribute] = [] unless attributes[attribute]
        unless attributes[attribute] # not yet known attribute
          attributes[attribute] = []
          previous_of_a_kind.times { attributes[attribute] << nil } # all previous elements had nil on this attribute
        end
        attributes[attribute] << value

      end
      store[selector] = attributes
    end
    # store.adapter.backend.compact
    progress.increment
  end

  store.close  
end