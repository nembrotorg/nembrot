class RegistrationsController < Devise::RegistrationsController

  def destroy
    resource.soft_delete
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end
end
