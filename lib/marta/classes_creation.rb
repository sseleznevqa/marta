require 'marta/element_information'
require 'pry'
module Marta

  private

  #
  # That module is responsible for user dialog on itit of an unknown class
  #
  # The same way Marta is able to create methods she can create classes in
  # a learn mode from unknown constants.
  # I suggest that in common each class generated that way is a pageobject.
  module ClassesCreation

    include Server

    private

    # We are asking user about unknown classes
    def page_edit(const, data=Hash.new)

      hash = {title:"You are defining #{const} pageobject",
                subtitle:"Here you can add a vars with default variables",
                hints:["Be carefull. Read Readme."],
                links:[],
                vars:{}, # {"var" => "value"},
                checks:{collection: nil, dontlook: nil},
                buttons: [{title:"Konfirm", onclck:"", type:"submit"},
                          {title: "Add line", onclick:"marta_add_field()", type:"none"}]}
      hash[:vars] = data['vars']
      FormServlet.data = hash
            binding.pry
      data['vars'] = inject('page', const, data['vars'])
      json_2_class(file_write(const.to_s, data))
      data['vars']
    end
  end
end
