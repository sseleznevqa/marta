
module Marta
  # Constant missing is hijacked!
  def Object.const_missing(const)
    if !SettingMaster.learn_status
      raise NameError, "uninitialized constant #{const}"
    else
      data, data['vars'], data['meths'] = Hash.new, Hash.new, Hash.new
      SmartPageCreator.json_2_class(ReaderWriter.file_write(const.to_s, data))
    end
  end
end
