require 'spec_helper'

describe "We will do some dummy things like" do
  before(:each) do
    @page = MyTestPage.open_page
  end
  it "touching every single element at the test page" do
    @page.form_fill
    expect(@page.confirmation_message_exact.present?).to be true
  end
end
