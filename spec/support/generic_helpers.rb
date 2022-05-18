module GenericHelpers
  
  def stub_credential(**credentials)
    allow(Rails.application).to receive(:credentials).and_return(
      OpenStruct.new(**credentials)
    )
  end
end