class SeedNotificationTemplates < ActiveRecord::Migration[7.0]
  def up
    NotificationTemplate.create([
      {
        title: 'When duplicate transactions are found.',
        frequency: 'daily',
      },
      {
        title: 'When refunds are issued.',
        frequency: 'daily',
      },
      {
        title: 'When a fee is charged to your account.',
        frequency: 'daily',
      },
      {
        title: 'When your salary is posted to your account.',
        frequency: 'daily',
      },
      {
        title: 'Weekly email summary of your Net Worth and Cashflow.',
        frequency: 'weekly',
      },
    ])
  end

  def down
    NotificationTemplate.delete_all
  end
end
