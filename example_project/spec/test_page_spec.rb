require 'spec_helper'

describe "We will do some dummy things like" do
  before(:each) do
    @page = MyTestPage.open_page
  end

  context "Angry iframe test" do
    before(:each) do
      @b = engine
      dance_with browser: @page.the_iframe
    end

    after(:each) do
      dance_with browser: @b
    end

    it "Looking into iframe" do
      the_iframe = TheIframe.new
      expect(the_iframe.github_link.text).to eq "GITHUB link"
    end
  end

  it "touching every single element at the test page" do
    expect(@page.numbers[1].text).to eq "Two"
    @page.form_fill
    expect(@page.confirmation_message_exact.present?).to be true
    @page.second_button.click
    expect(@page.title_exact.present?).to be true
  end

end
