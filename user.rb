require 'bcrypt'
require 'dm-core'
require 'data_mapper'
require './models/model'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, key: true
  property :username, String, length: 128
  property :password, BCryptHash
  property :is_author, Boolean
  property :is_admin, Boolean
  property :first_name, String
  property :last_name, String
  property :company_type, Integer
  property :range_of_customers, Integer
  property :range_of_transactions, Integer

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end
  
  def suggested_solution
    case self.company_type
    when 0
      if (self.range_of_customers == 0) && (self.range_of_transactions == 0)
        return Solution.get(1)
      elsif (self.range_of_customers == 0) && (self.range_of_transactions == 1)
        return Solution.get(2)
      elsif (self.range_of_customers == 1) && (self.range_of_transactions == 0)
        return Solution.get(2)
      else
        return Solution.get(3)
      end
      
    when 1
      if (self.range_of_customers == 0) && (self.range_of_transactions == 0)
        return Solution.get(4)
      elsif (self.range_of_customers == 0) && (self.range_of_transactions == 1)
        return Solution.get(4)
      elsif (self.range_of_customers == 1) && (self.range_of_transactions == 0)
        return Solution.get(5)
      else
        return Solution.get(5)
      end
      
    when 2
      if (self.range_of_customers == 0) && (self.range_of_transactions == 0)
        return Solution.get(6)
      elsif (self.range_of_customers == 0) && (self.range_of_transactions == 1)
        return Solution.get(7)
      elsif (self.range_of_customers == 1) && (self.range_of_transactions == 0)
        return Solution.get(8)
      else
        return Solution.get(9)
      end
      
    when 3
      if (self.range_of_customers == 0) && (self.range_of_transactions == 0)
        return Solution.get(6)
      elsif (self.range_of_customers == 0) && (self.range_of_transactions == 1)
        return Solution.get(7)
      elsif (self.range_of_customers == 1) && (self.range_of_transactions == 0)
        return Solution.get(8)
      else
        return Solution.get(9)
      end
      
    when 4
      if (self.range_of_customers == 0) && (self.range_of_transactions == 0)
        return Solution.get(1)
      elsif (self.range_of_customers == 0) && (self.range_of_transactions == 1)
        return Solution.get(2)
      elsif (self.range_of_customers == 1) && (self.range_of_transactions == 0)
        return Solution.get(2)
      else
        return Solution.get(3)
      end
      
    else
      if (self.range_of_customers == 0) && (self.range_of_transactions == 0)
        return Solution.get(4)
      elsif (self.range_of_customers == 0) && (self.range_of_transactions == 1)
        return Solution.get(4)
      elsif (self.range_of_customers == 1) && (self.range_of_transactions == 0)
        return Solution.get(5)
      else
        return Solution.get(5)
      end
    end
  end
  
  def type_for_company
    types = {
      0 => "Home Business (up to 10 employees)",
      1 => "Export Business (11-50 employees)",
      2 => "Telecom (51-200 eployees)",
      3 => "Banking (51-200 employees)",
      4 => "Retail (up to 10 employees)",
      5 => "Retail (11-50 employees)"
    }
    
    return types
  end
  
  def number_for_customers
    definitions = {
      0 => "up to 500",
      1 => "more than 500"
    }
    
    return definitions
  end
  
  def number_for_transactions
    definitions = {
      0 => "up to 100",
      1 => "more than 100"
    }
    
    return definitions
  end
  
  def profile_details
    details = {
      "First name" => self.first_name,
      "Last name" => self.last_name,
      "Type of Company" => type_for_company[self.company_type],
      "Number of Customers" => number_for_customers[self.range_of_customers],
      "Number of Transactions" => number_for_transactions[self.range_of_transactions]
    }
    
    return details
  end
end

DataMapper.finalize.auto_upgrade!