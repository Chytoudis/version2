require 'prawn'

class Report < Prawn::Document
  
  def self.generate_report (user, solution)
    pdf = self.new
    pdf.text "Report", size: 24, style: :bold
    pdf.move_down 20
    pdf.text "Client Profile", size: 18, style: :bold

    profile = user.profile_details.keys.map do |detail|
      [
        detail,
        user.profile_details[detail]
      ]
    end
  
    pdf.table profile,
      width: 500,
      column_widths: { 0 => 150 },
      row_colors: ["DDDDDD", "FFFFFF"] do
        column(1).style :align => :right
      end
  
    pdf.move_down 40
    pdf.text "ICT Suggestion", size: 18, style: :bold
    items = [
      solution.solution_items.keys,
      arr = solution.solution_items.values.map do |value|
        if value.include? ","
          value.gsub! ',', "\n"
        else
          value
        end
      end
    ]
  
    pdf.table items, 
      column_widths: { 0 => 100, 1 => 100, 2 => 120, 3 => 80 },
      width: 500,
      row_colors: ["DDDDDD", "FFFFFF"] do
        row(0).style :align => :center
        row(1).style :align => :center
      end
    
    pdf.render 
  end
end