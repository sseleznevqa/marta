require 'spec_helper'

describe Marta::SmartPage do
  it 'can open pages by url', :need_browser do
    marta_fire(:open_page, "about:blank")
    expect(@browser.url).to eq "about:blank"
  end

  it 'cannot open pages without any url' do
    message = "You should set url to use open_page"
    expect{marta_fire(:open_page)}.to raise_error(ArgumentError, message)
  end

  it 'can open page using predefined url', :need_browser do
    Test_object.new.open_page
    expect(@browser.url).to eq "about:blank"
  end
end
