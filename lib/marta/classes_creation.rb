module Marta

  private

  #
  # That module is responsible for user dialog on itit of an unknown class
  #
  # The same way Marta is able to create methods she can create classes in
  # a learn mode from unknown constants.
  # I suggest that in common each class generated that way is a pageobject.
  module ClassesCreation

    private

    # We are asking user about unknown classes
    def page_edit(const, data=Hash.new)
      data['vars'] = inject('page', const, data['vars'])
      json_2_class(file_write(const.to_s, data))
      data['vars']
    end
  end
end
