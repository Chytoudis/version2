#          /\ARuby/ 	Match "Ruby" at the start of a string

def compare_strings(text)

  property :myString, String, :length => 1024
  #property :forms,    String, :length => 256

  myString = text.to_s
  testString = String.new(myString)

  myString.each_char {|c| print c, '' }

    if myString.nil puts "Your " + text + " needs to be added in the header with data "

      while !(myString.('\Z')) do myString.sub(/, /, 1)  

	  puts myString  
   
      end	
    end
  end	