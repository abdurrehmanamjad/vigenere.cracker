class MainController < ApplicationController
  require 'prime'
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

  private
  
    def sub_strings(string)
      total_comparisons = 0
      all_factors_found = []
      matches = Hash.new
      
      hash = Hash.new([0,""])
      for i in 1..(string.length)
        for k in 0..(string.length-1-i)
          hash[string[k..k+i]] = [hash[string[k..k+i]][0] + 1 , hash[string[k..k+i]][1] + "#{k}|" ] 
          
          total_comparisons = total_comparisons +1
        end  
      end
      
      hash.each do |tupple|
        if tupple[1][0].to_i > 1
          positions = tupple[1][1].split("|")
          for i in 1..positions.size-1
            difference =  positions[i].to_i - positions[i-1].to_i
            factors = difference.prime_division
            all_factors_found << factors
            
            if tupple[0].size <= difference
              push_hash_long(difference,matches,factors)
            end
            total_comparisons = total_comparisons +1
          end
        else
          total_comparisons = total_comparisons +1
        end  
      end
      
      puts matches.sort_by{|k,v| v[:counter]}
      #puts all_factors_found
      puts total_comparisons
      
    end
    
    def iterate(string)
      
      size = string.size
      matches = Hash.new
      total_comparisons = 0
      all_factors_found = []  
      
      for i in 0..size
        for j in (i+1)..size-i
          length = j-i
          matched = false
          for k in (j+1)..size-length-1
            if string[i..j] == string[k..k+length]
              difference = k-i
              factors = difference.prime_division
              all_factors_found << factors
              push_hash_long(difference,matches,factors)
              matched = true
            end
            total_comparisons = total_comparisons +1
          end
          
          unless matched
            break
          end  
        end
      end
      
      
      
      puts matches.sort_by{|k,v| v[:counter]}
      #puts frequency_count_of_array_elements(all_factors_found.flatten!.sort!)
      #puts all_factors_found
      puts total_comparisons
    end
    
    def frequency_count_of_array_elements(array)
      hash = Hash.new(0)
      array.map { |v| hash[v] += 1 }
      return hash
    end
    
    def frequency_percentage_of_array_elements(array)
      hash = Hash.new(0)
      array.map { |v| hash[v] = ((hash[v] + 1.to_f)/26.to_f)/100 }
      return hash
    end
    
    def push_hash_long(string,hash,factors)
      unless hash[string].nil?
        hash[string] = {:counter => hash[string][:counter] + 1 , :prime_divisions => "#{factors}"}  
      else
        hash[string] = {:counter => 1 , :prime_divisions => "#{factors}"}  
      end
    end
    
    
    
    
    #iterate(string)
    
    #Result = "{1=>3739, 2=>1528, 3=>835, 4=>76, 5=>408, 6=>11, 7=>238, 8=>1, 9=>1, 11=>180, 13=>714, 17=>111, 19=>147, 23=>116, 29=>47, 31=>67, 37=>48, 41=>45, 43=>43, 47=>40, 53=>30, 59=>23, 61=>21, 67=>27, 71=>24, 73=>26, 79=>15, 83=>20, 89=>10, 97=>27, 101=>14, 103=>14, 107=>8, 109=>15, 113=>16, 127=>9, 131=>19, 137=>7, 139=>9, 149=>9, 151=>6, 157=>9, 163=>7, 167=>7, 173=>4, 179=>5, 181=>7, 191=>7, 193=>4, 197=>7, 199=>4, 211=>4, 223=>7, 227=>4, 229=>6, 233=>9, 239=>3, 241=>2, 251=>9, 257=>2, 263=>2, 269=>1, 271=>3, 277=>7, 281=>3, 283=>1, 293=>3, 307=>3, 311=>9, 313=>7, 317=>7, 331=>3, 337=>6, 347=>9, 349=>1, 353=>4, 359=>3, 367=>5, 373=>3, 379=>1, 389=>5, 397=>6, 401=>3, 409=>1, 419=>5, 421=>3, 431=>2, 433=>1, 439=>5, 443=>3, 449=>3, 457=>4, 461=>5, 463=>5, 467=>2, 479=>4, 487=>2, 491=>4, 499=>1, 503=>2, 509=>1, 521=>4, 523=>2, 547=>2, 557=>2, 569=>3, 571=>1, 577=>2, 587=>3, 593=>1, 599=>1, 601=>2, 607=>4, 631=>3, 641=>3, 643=>3, 647=>2, 653=>4, 659=>1, 661=>2, 673=>1, 677=>1, 683=>1, 691=>3, 701=>4, 709=>1, 719=>1, 727=>1, 733=>1, 739=>1, 743=>1, 761=>2, 769=>1, 773=>1, 787=>2, 797=>1, 811=>2, 821=>2, 823=>1, 827=>1, 829=>1, 839=>4, 853=>1, 857=>1, 859=>1, 863=>1, 877=>1, 881=>1, 883=>1, 907=>1, 929=>1, 947=>1, 953=>1, 967=>1, 977=>1, 997=>1, 1021=>1, 1031=>1, 1033=>1, 1039=>1, 1049=>11, 1051=>1, 1061=>1, 1063=>2, 1069=>4, 1093=>2, 1097=>1, 1109=>1, 1129=>1, 1151=>1, 1213=>3, 1217=>1, 1231=>1, 1277=>1, 1283=>1, 1307=>1, 1319=>1, 1373=>1, 1433=>1, 1439=>1, 1487=>1}"
    
    
    #unoptimised_comparisons = 242913649
    #optimised_comparisons = 1864586
    #computations_saved = 241049063
    
    
    #alphabet_places_hash = {"z"=>25, "y"=>24, "x"=>23, "w"=>22, "v"=>21, "u"=>20, "t"=>19, "s"=>18, "r"=>17, "q"=>16, "p"=>15, "o"=>14, "n"=>13, "m"=>12, "l"=>11, "k"=>10, "j"=>9, "i"=>8, "h"=>7, "g"=>6, "f"=>5, "e"=>4, "d"=>3, "c"=>2, "b"=>1, "a"=>0}
    
    #places_alphabet_hash = {16=>"q", 5=>"f", 22=>"w", 11=>"l", 0=>"a", 17=>"r", 6=>"g", 23=>"x", 12=>"m", 1=>"b", 18=>"s", 7=>"h", 24=>"y", 13=>"n", 2=>"c", 19=>"t", 8=>"i", 25=>"z", 14=>"o", 3=>"d", 20=>"u", 9=>"j", 15=>"p", 4=>"e", 21=>"v", 10=>"k"}
    
    #"abcdefghijklmnopqrstuvwxyz"
    
    english_data_frequency = {
                          'A'=>8.167, 'B'=>1.492, 'C'=>2.782, 'D'=>4.253, 'E'=>12.702,
                          'F'=>2.228, 'G'=>2.015, 'H'=>6.094, 'I'=>6.996, 'J'=>0.153,
                          'K'=>0.772, 'L'=>4.025, 'M'=>2.406, 'N'=>6.749, 'O'=>7.507,
                          'P'=>1.929, 'Q'=>0.095, 'R'=>5.987, 'S'=>6.327, 'T'=>9.056,
                          'U'=>2.758, 'V'=>0.978, 'W'=>2.360, 'X'=>0.150, 'Y'=>1.974,
                          'Z'=>0.074, 'max_val'=>12.702, 'indexofcoincidence'=>0.0667
                         }
    
    
    #cracked_text="fromthedancingmenbyarthurconandoylewejoinholmesashelikeyoucracksaciphertextevennowiwasinconsiderabledifficultybutahappythoughtputmeinpossessionofseveralotherlettersitoccurredtomethatiftheseappealscameasiexpectedfromsomeonewhohadbeenintimatewiththeladyinherearlylifeacombinationwhichcontainedtwoeswiththreelettersbetweenmightverywellstandforthenameelsieonexaminationifoundthatsuchacombinationformedtheterminationofthemessagewhichwasthreetimesrepeateditwascertainlysomeappealtoelsieinthiswayihadgotmylsandibutwhatappealcoulditbetherewereonlyfourlettersinthewordwhichprecededelsieanditendedinesurelythewordmustbecomeitriedallotherfourlettersendinginebutcouldfindnonetofitthecasesonowiwasinpossessionofcoandmandiwasinapositiontoattackthefirstmessageoncemoredividingitintowordsandputtingdotsforeachsymbolwhichwasstillunknownsotreateditworkedoutinthisfashionmereeslnenowthefirstlettercanonlybeawhichisamostusefuldiscoverysinceitoccursnofewerthanthreetimesinthisshortsentenceandthehisalsoapparentinthesecondwordnowitbecomesamhereaeslaneorfillingintheobviousvacanciesinthenameamhereabeslaneyihadsomanylettersnowthaticouldproceedwithconsiderableconfidencetothesecondmessagewhichworkedoutinthisfashionaelrieshereicouldonlymakesensebyputtingtandgforthemissinglettersandsupposingthatthenamewasthatofsomehouseorinnatwhichthewriterwasstayinginspectormartinandihadlistenedwiththeutmostinteresttothefullandclearaccountofhowmyfriendhadproducedresultswhichhadledtosocompleteacommandoverourdifficultieswhatdidyoudothensiraskedtheinspector"
    
    
    def vigenere_cipher(text,key)
      alphabet_places_hash = {"z"=>25, "y"=>24, "x"=>23, "w"=>22, "v"=>21, "u"=>20, "t"=>19, "s"=>18, "r"=>17, "q"=>16, "p"=>15, "o"=>14, "n"=>13, "m"=>12, "l"=>11, "k"=>10, "j"=>9, "i"=>8, "h"=>7, "g"=>6, "f"=>5, "e"=>4, "d"=>3, "c"=>2, "b"=>1, "a"=>0}
      places_alphabet_hash = {16=>"q", 5=>"f", 22=>"w", 11=>"l", 0=>"a", 17=>"r", 6=>"g", 23=>"x", 12=>"m", 1=>"b", 18=>"s", 7=>"h", 24=>"y", 13=>"n", 2=>"c", 19=>"t", 8=>"i", 25=>"z", 14=>"o", 3=>"d", 20=>"u", 9=>"j", 15=>"p", 4=>"e", 21=>"v", 10=>"k"}
      
      c_text = String.new(text)
    
      i=0
      j=0
      key_size = key.size
      text.each_char do |letter|;
        i=i%key_size;
        
        l_position = alphabet_places_hash[letter]
        k_position = alphabet_places_hash[key[i..i]]
        new_position = (l_position + k_position)%26
        c_text[j..j] = places_alphabet_hash[new_position]
        
        i+=1;
        j+=1;
      end
      
      return c_text
    
    end
    
    def rotator(text,key)
      i=0
      r_text = String.new(text)
      size = text.size
      
      text.each_char do |letter|;
        
        l_position = i
        k_position = key
        new_position = (l_position + k_position)%size
        r_text[new_position..new_position] = letter
        
        i+=1
      end
      
      return r_text
    
    end
    
    def index_of_coincidence(first_text,second_text)
      #English 6.6
      #Random Letters 3.8
      
      matched = 0
      size = [first_text.size, second_text.size].max
      
      size.times do |i|
        if first_text[i..i] == second_text[i..i]
          matched += 1
        end  
      end
      return (matched.to_f/size.to_f)*100
    end
    
    
    def friedmans_key_length_finder(plain_text, number_of_iterations)
      rotated_text = String.new
      key_lengths = []
      number_of_iterations.times do |index|;
        rotated_text = rotator(plain_text, index+1);
        puts "index of coincidence = #{index_of_coincidence(plain_text, rotated_text)} || expected key length = #{index+1}";
        
        key_lengths << [ index_of_coincidence(plain_text, rotated_text) , index+1 ] 
      end
      
      return key_lengths.sort
    end
    
    def touples_finder(plain_text, key_length)
      touples = Hash.new("")
      jump = 0
      size = plain_text.size
      
      key_length.times do |index|
        while(jump < size )
          touples[index] = touples[index] + plain_text[jump..jump]
          jump += key_length
        end
        jump = index + 1
      end
      
      return touples
    end
    
    def characters_frequency_difference(plain_text)
      english_data_frequency = {
        'a'=>8.167, 'b'=>1.492, 'c'=>2.782, 'd'=>4.253, 'e'=>12.702,
        'f'=>2.228, 'g'=>2.015, 'h'=>6.094, 'i'=>6.996, 'j'=>0.153,
        'k'=>0.772, 'l'=>4.025, 'm'=>2.406, 'n'=>6.749, 'o'=>7.507,
        'p'=>1.929, 'q'=>0.095, 'r'=>5.987, 's'=>6.327, 't'=>9.056,
        'u'=>2.758, 'v'=>0.978, 'w'=>2.360, 'x'=>0.150, 'y'=>1.974,
        'z'=>0.074, 'max_val'=>12.702, 'indexofcoincidence'=>0.0667
      }
      
      char_array = plain_text.split("")
      difference_hash = Hash.new(0)
      frequency_hash = frequency_percentage_of_array_elements(char_array)
      
      frequency_hash.each do |frequency_char|
        difference_hash[frequency_char.first] = {:description => "given letter frequency = #{frequency_char.last} || actual english frequency #{english_data_frequency[frequency_char.first]}" , :difference  =>  (english_data_frequency[frequency_char.first] - frequency_char.last).abs}
      end  
        
      return difference_hash  
    
    end
    
    def total_frequency_offset(difference_hash)
      total = 0.0
      difference_hash.each do |char_frequency|
        total += char_frequency.last[:difference]
      end  
    
      return total
    end
    
    def alphabetic_decipher(text,letter)
      alphabet_places_hash = {"z"=>25, "y"=>24, "x"=>23, "w"=>22, "v"=>21, "u"=>20, "t"=>19, "s"=>18, "r"=>17, "q"=>16, "p"=>15, "o"=>14, "n"=>13, "m"=>12, "l"=>11, "k"=>10, "j"=>9, "i"=>8, "h"=>7, "g"=>6, "f"=>5, "e"=>4, "d"=>3, "c"=>2, "b"=>1, "a"=>0}
      places_alphabet_hash = {16=>"q", 5=>"f", 22=>"w", 11=>"l", 0=>"a", 17=>"r", 6=>"g", 23=>"x", 12=>"m", 1=>"b", 18=>"s", 7=>"h", 24=>"y", 13=>"n", 2=>"c", 19=>"t", 8=>"i", 25=>"z", 14=>"o", 3=>"d", 20=>"u", 9=>"j", 15=>"p", 4=>"e", 21=>"v", 10=>"k"}
      
      d_text = String.new(text)
    
      i=0
      replace_char = ""
      k_position = alphabet_places_hash[letter]
      
      text.each_char do |index|
        
        alphabet_places_hash.each do |char|
          l_position = alphabet_places_hash[char.first]
          new_position = (l_position + k_position)%26
          new_char = places_alphabet_hash[new_position]
          if new_char == index
            replace_char = char.first
          end
          
        end  
        d_text[i..i] = replace_char
        
        i+=1
      end
      
      return d_text
    
    end
    
    def vigenere_decipher(text,key)
      alphabet_places_hash = {"z"=>25, "y"=>24, "x"=>23, "w"=>22, "v"=>21, "u"=>20, "t"=>19, "s"=>18, "r"=>17, "q"=>16, "p"=>15, "o"=>14, "n"=>13, "m"=>12, "l"=>11, "k"=>10, "j"=>9, "i"=>8, "h"=>7, "g"=>6, "f"=>5, "e"=>4, "d"=>3, "c"=>2, "b"=>1, "a"=>0}
      places_alphabet_hash = {16=>"q", 5=>"f", 22=>"w", 11=>"l", 0=>"a", 17=>"r", 6=>"g", 23=>"x", 12=>"m", 1=>"b", 18=>"s", 7=>"h", 24=>"y", 13=>"n", 2=>"c", 19=>"t", 8=>"i", 25=>"z", 14=>"o", 3=>"d", 20=>"u", 9=>"j", 15=>"p", 4=>"e", 21=>"v", 10=>"k"}
      
      d_text = String.new(text)
    
      i=0
      j=0
      key_size = key.size
      text.each_char do |letter|;
        i=i%key_size;
        replace_char = ""
        k_position = alphabet_places_hash[key[i..i]]
        
        alphabet_places_hash.each do |char|
          l_position = alphabet_places_hash[char.first]
          new_position = (l_position + k_position)%26
          new_char = places_alphabet_hash[new_position]
          if new_char == letter
            replace_char = char.first
          end
          
        end  
        
        d_text[j..j] = replace_char
        
        i+=1;
        j+=1;
      end
      
      return d_text
    
    end
    
    #"niyevdioyincarbposlvvrpeqfovd" ciphered with key="remarkable"
    #"nvdvvkzeevnpfibwfiriveuvqmflj" ciphered with key="r"
    
    def alphabetic_subtitutions(c_text)
      new_c_text = String.new
      offset_array = []
      "abcdefghijklmnopqrstuvwxyz".each_char do |char|
        new_c_text = alphabetic_decipher(c_text,char)
        #puts new_c_text
        #puts "=================================="
        
        offset = total_frequency_offset(characters_frequency_difference(new_c_text))
        #puts "offset with #{char} = #{offset}"
        offset_array << [ offset , char ]
        #puts "=================================="
      end
      
      return offset_array.sort.last
    end
    
    def vigenere_cracker(c_text, key_range)
      plain_text = String.new
      cipher_text = String.new(c_text)
      puts "applying friedman's key length finding algorithm..."
      puts "==================================================="
      
      key_length = friedmans_key_length_finder(cipher_text,key_range).last
      
      puts "expected key length found: #{key_length}"
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
      
      return plain_text
      
    end
    
    #vigenere_cracker(string, 16 )
    #sub_strings(string)

end
