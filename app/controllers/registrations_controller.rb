class RegistrationsController < Devise::RegistrationsController

  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    respond_with_navigational(resource) {
      redirect_to after_sign_out_path_for(resource_name), notice: 'Your nembrot.org account has been deleted.'
    }
  end
end
