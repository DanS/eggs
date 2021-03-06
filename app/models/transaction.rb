# == Schema Information
#
# Table name: transactions
#
#  id              :integer(4)      not null, primary key
#  date            :date
#  amount          :float
#  description     :string(255)
#  member_id       :integer(4)
#  order_id        :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  debit           :boolean(1)
#  balance         :float
#  subscription_id :integer(4)
#

class Transaction < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :order

  before_create :zero_nil_amount, :calculate_balance

  liquid_methods :amount, :description, :paypal_transaction_id, :debit, :balance,
                 :subscription

  def after_initialize
    self.debit = false if !self.debit
  end

  def zero_nil_amount
    self.amount = 0 if self.amount == nil
  end

  def calculate_balance
    if !balance
      last = Transaction.find_all_by_subscription_id(subscription.id, :order => 'date ASC').last
      if last
        self.balance = last.balance + (debit ? -amount : amount)
      else
        self.balance = debit ? -amount : amount
      end
    end
  end

  def deliver_credit_notification!
    template = EmailTemplate.find_by_identifier_and_farm_id("transaction_notification", self.subscription.farm.id)
    template.deliver_to(self.subscription.member.email_address, :transaction => self) if template
  end

end
