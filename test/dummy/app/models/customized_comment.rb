class CustomizedComment < ActiveRecord::Base

  acts_as_unsolicitable name_field: "first_name",
                        email_field: "email_address",
                        content_field: "body"

end
