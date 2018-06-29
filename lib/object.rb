
#
# Object class is Hijacked by Marta in order to catch not defined constants
#
#
puts "NN"
class Object
  class << self
    # We are saving old const_missing to marta_const_missing
    alias_method :marta_const_missing, :const_missing
  end

  #Our own constant missing process
  def self.const_missing(const)
    if !SettingMaster.learn_status
      self.marta_const_missing(const)
    else
      data, data['vars'], data['meths'] = Hash.new, Hash.new, Hash.new
      SmartPageCreator.json_2_class(ReaderWriter.file_write(const.to_s, data))
    end
  end
end
puts "DD"
