# Marta

Marta is a pretty new way to write selenium tests for WEB applications using Watir. Main idea is very similar to cucumber. In Cucumber you are writing test and then defining a code behind it. In Marta you are writing code and then defining classes/pageobjects and methods/elements behind it thru your browser window.

Also Marta is providing a little more stability when locating elements on the page.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'marta'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install marta

## Usage

1. Be sure that you have [Chromedriver](https://sites.google.com/a/chromium.org/chromedriver/) installed as well as [Chrome browser](https://www.google.com/chrome/browser/desktop/). It should work with any browser but it's definitely working in Chrome :)
2. Write the code
```ruby
require 'marta'
include Marta
dance_with
your_page = Your_Page.new
your_page.open_page
your_page.your_element.click
```
3. Run it in terminal with parameter LEARN=1 approximately like:

    $ LEARN=1 ruby path_to_your_test.rb

4. Take a look at the browser window: Marta will ask you to define Your_Page class. You can add variables for the class there.
5. Add *url* variable with the url of desired page as a default value.
6. Confirm.
7. Then page will be opened and you will be asked about your_element.
8. Just click the element and confirm the selection (twice)
9. Now you can run the test without LEARN parameter and it will work.

**So you are `writing code in pageobject pattern` style.**

**Where each `class is` meant to be a `pageobject`.**

**Where each `method` except reserved (method_edit, engine, open_page, new, class, etc.) `can be a class variable or` should represent `an element at the page`.**

**At first `run` (with `learning mode enabled`) you are `defining Pages and elements` via web interface.**

**After that you can `run your code without learning` and it should pass.**

**`Stability` of the scheme `is ensured by` Marta's `ability to find elements` even `if` some `attributes were changed`.**

## FAQ
**Q: What if some attributes of elements will be changed?**

*A: First of all at the defining stage you can exclude dynamic attributes. Also Marta has special Black Magic algorithm that will try to find the most similar element anyway.*

*NOTE: Exclude attributes with empty values as well. In later versions Marta will filter them out automatically.*

**Q: What if I can locate element only by dynamic attributes like account_id?**

*A: For example you have a pack of html elements with only one attribute that differs: account_id_attribute. First at the stage of page defining create a class variable account_id = "123". After that you can dynamically change it in your code like*
```ruby
your_page.account_id = "456"
```
*And when defining an element you can use it in value field of account_id_attribute like #{@account_id}. See couple examples in example_project (Ruby checkbox, item1 and 2 radio buttons)*

**Q: I want to use firefox. How could I?**

*A: dance_with is accepting parameter :browser like*
```ruby
dance_with browser: Watir::Browser.new(:firefox)
```

**Q: How Marta stores data?**

*A: Marta creates a json files in the default folder with name = Marta_s_pageobjects'. You can force Marta to use other folder like*
```ruby
dance_with folder: 'path/to/your/folder'
```

**Q: I want to turn learning mode on\off in the code. How?**

*A:*
```ruby
dance_with learn: true or false
```
*Note: it may not work inside of the previously defined class. In that case use:*
```ruby
your_page.method_edit('newelementname')
```

**Q: Sometimes Marta is looking for lost element for too long. What can I do about it?**

*A: You can set tolerancy parameter. Larger = longer*
```ruby
dance_with tolerancy: 1024# is the default value
```
*That logic will be changed to more understandable soon. I hope.*

**Q: How can I get Watir browser instance if I want for example execute_script or find element without Marta?**

*A: Like that*
```ruby
engine.execute_script('your script')
#or
your_page.engine.execute_script('your script')
#and
engine.element(id: 'will_be_located_without_Marta')
```

**Q: How can I find a collection of elements?**

*A: When defining an element you can set a collection checkbox at the top of the dialog. In that case Marta will return Watir::ElementCollection.*

**Q: How can I find not just an element but a Watir::Radio for example?**

*A: Marta automatically performs to_subtype for every element. So if your element is a radio button you will be able to use specific methods.*
```ruby
your_page.element_that_supposed_to_be_radio.set?
```
*ATTENTION. Until [Watir issue 537](https://github.com/watir/watir/issues/537) is not fixed it may work wrong. Sometimes.*

**Q: And what about elements under iframes?**

*A: First of all DO NOT USE switch_to! - it will not work. Please use:*
```ruby
dance_with browser: your_page.iframe_element
```
*After that Marta will look for elements inside iframe only. To switch back use:*
```ruby
dance_with browser: engine.browser
```
*Fixing switch_to! is planned. And as always you can:*
```ruby
your_page.iframe_element.text_field(id: 'ifield')
```

**Q: Marta is finding similar elements when she cannot find the element. But what if I need to check presence of the element and I am not interested in a similar one?**

*A: To prevent Marta from searching similar elements use methods with _exact at the end. Like.*
```ruby
your_page.important_element_exact.present?
#Once defined it can be called without exact as well
your_page.important_element.click
```

**Q: Is there any other way to strictly define an element?**

*A: You can click 'Set custom xpath' at element defining stage and set own xpath. In that case only that xpath will be used to find element. It is planned to add possibility to set custom css, id, name, etc.*

**Q: Why Watir? I want to use pure Selenium Webdriver or Capybara or something!**

*A: I like Watir. And I have no plans so far to implement something else.*

**Q: And what about Cucumber? Will it work with Marta?**

*A: I don't know. I am not a Cucumber fan and I have giant doubts that Marta and Cucumber will work together well. But you can try. Also I am thinking about it.*

**Q: Ok. With what WILL it work?**

*A: It should work with rspec and parallel_rspec. See example_project for example*

**Q: How can I design more object oriented and DRY tests using Marta**

*A: Create wrapping classes. Like*
```ruby
class Google_page < Marta_google_page
  def search(what)
    search_field.set what
    search_button.click
  end
end
g_page = Google_page.new
g_page.open_page
g_page.search "I am in love with selenium."
```
*You will define with Marta Marta_google_page class(do not forget to set an url!) and methods: search_field and search_button.*

**Q: What about an example?**

*A: It is placed in example_project folder. All elements are defined already (except one that is not in use by default). For a tour do*

    $ cd example_project
    $ ./tests_with_learning.sh

*Take a look at elements defining (especially when variables like #{i1} are used). Try to redefine elements. And see what attributes are used what are not. Also take a look at the ruby code. There are some comments.*

**Q: What else?**

*A: Nothing. Marta is under development. Her version is 0.26150 only. And I am not a professional developer. But I am training her on new tricks.*

## Internal Design

**That is not a real code. That is just an idea of internal structure. Feel free to criticize it**

```ruby
# Main module
module Marta

  # Helper module
  module OptionsAndPaths

    # Helper class. If it will be used for Marta module it has singleton
    # methods.
    class SettingMaster
      @@options = nil

      # Class can have different options for different threads
      def self.opts option
        @@options[Thread.current.object_id]
      end
    end
  end

  # Includes public methods for SmartPage
  module PublicMethods

    # Some methods that can be called almost always even from SmartPage like
    def open_page page
      # Marta opens page
    end

    # SmartPage hijacks method_missing as well in a learn mode
    def method_missing
      # We are doing things in a learn mode here
    end
  end

  # Injecting messages to the browser page
  module Injector

    private

    def inject something
      # Marta injecting dialogs to the page
    end
  end

  # Marta has a lot of modules...
  # module Something
  #   private
  #   Marta has many other private methods...
  # end

  # Marta hijacks const_missing for her learn mode
  # In the real world that stuff is in Json2Class module
  def const_missing
    if learn_mode
      c = class.new(SmartPage) do
        # We are creating new class here
        # adding of some public methods that can be used
        # adding custom variables
        if learn_mode
          def initialize *args
            # Showing user dialogs in browser
          end
          def method_missing *args
            # We can create methods dynamically
            # We will ask user about method\element in browser instance
          end
        end
      end
    else
      # We are showing error
    end
  end

  # Generated Pageobject classes will inherit from SmartPage
  class SmartPage
    include OptionsAndPaths, PublicMethods, Injector#, Something, and others
  end

  # If module is included we can call some methods.
  def dance_with option
    SettingMaster.opts = option
    # And other useful things here
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/marta. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
