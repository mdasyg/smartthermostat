module DevicesHelper
  def create_properties_prefix(model)
    # new_or_existing = model.new_record? ? 'new' : 'existing'

    new_or_existing = :fix_me

    prefix = "device[#{new_or_existing}_property]"
  end
end
