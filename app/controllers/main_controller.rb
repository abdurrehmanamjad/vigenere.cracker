class MainController < ApplicationController
  require 'prime'
  load "#{Rails.root}/lib/code.rb"
  
  skip_before_filter :verify_authenticity_token 
  
  def index
    
  end

  def keylen_friedman_analysis
    cipher_text = params[:cipher_text]
    keylen_range = params[:keylen_range].to_i unless params[:keylen_range].blank?
    
    key_lengths = friedmans_key_length_finder(cipher_text,keylen_range)
    respond_to do |format|
      format.json {render :json => key_lengths.to_json}
    end  
  end

  def attack
    cipher_text = params[:cipher_text]
    key_length = params[:key_length].to_i unless params[:key_length].blank?
    puts "expected key length: #{key_length}"
    puts "========================================"
    
    key_found = ""
    touples = touples_finder(cipher_text, key_length)
    
    touples.sort.each do |touple|
      puts "processing bucket of characters..."
      puts "=================================="
      puts touple.last
      key_found << alphabetic_subtitutions(touple.last).last
    end
    puts "========================================"
    puts "========================================"
    puts "========================================"
    puts "EXPECTED KEY :-D  #{key_found}"
    puts "========================================"
    puts "========================================"
    puts "========================================"
    
    puts "applying awesomeness to find plain text ;-) "
    puts "============================================"
    
    plain_text = vigenere_decipher(cipher_text, key_found)
    
    puts "========================"
    puts "========================"
    puts "========================"
    puts "EXPECTED PLAIN TEXT :-D "
    puts plain_text
    puts "========================"
    puts "========================"
    puts "========================"
    
    respond_to do |format|
      format.json {render :json => [key_found, plain_text].to_json }  
    end
  end

end
