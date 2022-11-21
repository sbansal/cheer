class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notification_template

  DUPLICATE_DESCRIPTION = 'Duplicate transaction found.'
  REFUNDS_DESCRIPTION = 'Credit posted to your account.'
  SALARY_DESCRIPTION = 'You got paid.'
  WEEKLY_SUMMARY_DESCRIPTION = 'Your weekly summary is ready.'
  FEE_CHARGED_DESCRIPTION = 'You were charged a fee.'
end
