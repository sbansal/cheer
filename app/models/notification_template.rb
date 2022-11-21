class NotificationTemplate < ApplicationRecord
  DUPLICATE_TEMPLATE_TITLE = 'When duplicate transactions are found.'
  REFUNDS_TEMPLATE_TITLE = 'When refunds are issued.'
  FEE_CHARGED_TEMPLATE_TITLE = 'When a fee is charged to your account.'
  SALARY_POSTED_TEMPLATE_TITLE = 'When your salary is posted to your account.'
  EMAIL_SUMMARY_TEMPLATE_TITLE = 'Weekly email summary of your Net Worth and Cashflow.'

  DUPLICATE_TEMPLATE_TYPE = 'duplicate'
  REFUNDS_TEMPLATE_TYPE = 'refund'
  FEE_CHARGED_TEMPLATE_TYPE = 'fee_charged'
  SALARY_POSTED_TEMPLATE_TYPE = 'payroll'
  EMAIL_SUMMARY_TEMPLATE_TYPE = 'financial_summary'

  def self.find_duplicate_template
    NotificationTemplate.find_by(template_type: DUPLICATE_TEMPLATE_TYPE)
  end

  def self.find_refunds_template
    NotificationTemplate.find_by(template_type: REFUNDS_TEMPLATE_TYPE)
  end

  def self.find_fee_charged_template
    NotificationTemplate.find_by(template_type: FEE_CHARGED_TEMPLATE_TYPE)
  end

  def self.find_salary_posted_template
    NotificationTemplate.find_by(template_type: SALARY_POSTED_TEMPLATE_TYPE)
  end

  def self.find_email_summary_template
    NotificationTemplate.find_by(template_type: EMAIL_SUMMARY_TEMPLATE_TYPE)
  end
end
