#!/usr/bin/env ruby

require 'pdf-reader'
require 'RMagick'
require 'pry'

image_suffix = ".jpg"
verbose = true

relative_input_directory = "../raw_pdfs/"
relative_output_directory = "../output/"
pdfs = Dir.entries(relative_input_directory)

#PDF READER NOT WORKING, NEED THAT UP BEFORE MOVING FORWARD

pdfs.each do |individual_pdf|

  #for easy development; remove to do each one
  next unless individual_pdf == "Ethics .pdf"

  full_path = "#{relative_input_directory}#{individual_pdf}"
  no_suffix_file_name = "#{individual_pdf[0...-4]}"
  text_reader = PDF::Reader.new(full_path)

  #for each PDF, first pass determines which pages are questions
  is_question = Array.new(text_reader.page_count)
  csv_content = ""
  counter = 0 
  puts "Beginning text read loop" if verbose

  text_reader.pages.each do |page|
    text = page.text
    if (text.include?("copyright") or text.include?("copynght"))
      is_question[counter] = true
    else
      is_question[counter] = false
    end
    counter += 1
    puts "Page #{counter}" if verbose and (counter % 10 == 0)
  end

  #second pass should create image files 
  #create CSV for export, referring to what images will be called

  puts "Reading in PDF" if verbose
  image_reader = Magick::Image.read(full_path)
  puts "Beginning csv and image creation" if verbose
  (0..is_question.length-1).each do |n|
    if is_question[n]
      csv_content += "\n" unless csv_content.empty?
    elsif is_question[n-1]
      csv_content += ","
    end
    image_name = "#{no_suffix_file_name}-#{n}#{image_suffix}"
    csv_content += "<img src='#{image_name}'>"
    image_reader[n].write("#{relative_output_directory}#{image_name}")
    puts "Page #{n}" if verbose and (n % 10 == 0)
  end
  csv_content += "\n"

  File.open("#{relative_output_directory + no_suffix_file_name}.csv", "wb") { |f| f.write(csv_content) }
end

