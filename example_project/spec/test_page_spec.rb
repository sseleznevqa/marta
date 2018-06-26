require 'spec_helper'

describe "We will do some dummy things like" do
  before(:each) do
    @page = MyTestPage.open_page
  end
  it "touching every single element at the test page" do
    expect(@page.numbers[1].text).to eq "Two"
    @page.form_fill
    expect(@page.confirmation_message_exact.present?).to be true
    @page.second_button.click
    expect(@page.title_exact.present?).to be true
  end
end
